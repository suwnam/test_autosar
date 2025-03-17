'#!/bin/bash

## This script is for backup jenknis repository
## version: v0.2
## date: 2025-03-17

BACKUP_DIR="/home/swnam/Jenkins/jenkins_home"
EXCLUDE_DIR=$JENKINS_HOME/workspace

# Restic 저장소 연결 확인
if restic -r $RESTIC_REPO_JENKINS snapshots > /dev/null 2>&1; then
    echo "Successfully connected to Restic jenkins repository"
else
    echo "Failed to connect to Restic jenkins repository"
    exit 1
fi

# 최신 스냅샷 ID 가져오기 (&첫 백업 여부 확인)
LATEST_SNAPSHOT_ID=$(restic -r "$RESTIC_REPO_JENKINS" snapshots --json 2>/dev/null | jq -r '.[-1].short_id')

# JSON 오류에 대한 예외처리
if [[ "$LATEST_SNAPSHOT_ID" == "null" || -z "$LATEST_SNAPSHOT_ID" ]]; then
    LATEST_SNAPSHOT_ID=""
fi

# 백업 유형 결정
CURRENT_DAY=$(date +%u)

if [ -z "$LATEST_SNAPSHOT_ID" ]; then
    echo "No previous snapshots found. Performing initial FULL backup..."
    backup_type="initialFullBackup"
elif [ "$CURRENT_DAY" -eq 0 ] || [ "$CURRENT_DAY" -eq 7 ]; then
    echo "Performing scheduled FULL backup on Sunday..."
    backup_type="fullBackup"
else
    echo "Performing INCREMENTAL backup..."
    backup_type="incBackup"
fi

echo "Backup type: $backup_type"

# 백업 태그
BACKUP_DATE=$(date +%y%m%d)
BACKUP_TAG="jenkins-$backup_type-$BACKUP_DATE"

# 백업 태그별 증분/전체 백업 수행
case "$backup_type" in
    "initialFullBackup")
        BACKUP_OUTPUT=$(restic -r "$RESTIC_REPO_JENKINS" backup "$BACKUP_DIR" --tag "$BACKUP_TAG" --exclude "$EXCLUDE_DIR" 2>&1)
        ;;
    "fullBackup")
        BACKUP_OUTPUT=$(restic -r "$RESTIC_REPO_JENKINS" backup --force "$BACKUP_DIR" --tag "$BACKUP_TAG" --exclude "$EXCLUDE_DIR" 2>&1)
        ;;
    "incBackup")
        BACKUP_OUTPUT=$(restic -r "$RESTIC_REPO_JENKINS" backup "$BACKUP_DIR" --tag "$BACKUP_TAG" --exclude "$EXCLUDE_DIR" 2>&1)
        ;;
    *)
        echo "Error: Unknown backup type $backup_type"
        exit 1
        ;;
esac

# 백업 실행 결과 확인
if [ $? -ne 0 ]; then
    echo "Error: Restic backup failed!"
    echo "$BACKUP_OUTPUT"
    exit 1
fi

# 새로 생성된 스냅샷 ID 추출
NEW_SNAPSHOT_ID=$(restic -r "$RESTIC_REPO_JENKINS" snapshots --json 2>/dev/null | jq -r '.[-1].short_id')

# 스냅샷 생성 여부 확인
if [ -z "$NEW_SNAPSHOT_ID" ]; then
    echo "Error: Snapshot creation failed. No snapshot ID found."
    exit 1
fi

# 백업 완료 메시지 출력
echo "Backup completed successfully: Type=$backup_type, Snapshot ID = $NEW_SNAPSHOT_ID"

# 증분 백업 실행 시 최신 스냅샷과 비교하여 변경된 파일 출력
if [ "$backup_type" = "incBackup" ] && [ -n "$LATEST_SNAPSHOT_ID" ]; then
    echo "Comparing changes with the latest snapshot..."
    restic -r "$RESTIC_REPO_JENKINS" diff "$LATEST_SNAPSHOT_ID" "$NEW_SNAPSHOT_ID" || { echo "Warning: Failed to compare snapshots"; }
else
    echo "No previous snapshot found or performing full backup."
fi

# 생성된 스냅샷 정보 출력
echo "     ID           TIME                HOST                 TAGS               Paths     "
echo "________________________________________________________________________________________ "
restic -r "$RESTIC_REPO_JENKINS" snapshots "$NEW_SNAPSHOT_ID" 
echo "________________________________________________________________________________________ "
