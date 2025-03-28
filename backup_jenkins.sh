#!/bin/bash

# 백업 함수 정의
restic_backup() {
    local repo_type=$1

    # 저장소 분기
    if [ "$repo_type" == "s3" ]; then
        export RESTIC_REPO_JENKINS="$RESTIC_S3_JENKINS"
    elif [ "$repo_type" == "local" ]; then
        export RESTIC_REPO_JENKINS="$RESTIC_LO_JENKINS"
    else
        echo "[-] Invalid repository type. Choose 's3' or 'local'."
        return 1
    fi

    echo "=== Starting Jenkins backup to [$repo_type] at [$RESTIC_REPO_JENKINS] ==="

    BACKUP_DIR="/home/popcornsar/DevOps/01_Jenkins/jenkins_home"
    EXCLUDE_DIR="$BACKUP_DIR/workspace"

    # 저장소 연결 확인
    if ! restic -r "$RESTIC_REPO_JENKINS" snapshots > /dev/null 2>&1; then
        echo "[-] Failed to connect to Restic repository: $RESTIC_REPO_JENKINS"
        return 1
    fi
    echo "[+] Connected to Restic repository"

    # 가장 최근 스냅샷 ID 확인
    LATEST_SNAPSHOT_ID=$(restic -r "$RESTIC_REPO_JENKINS" snapshots --json 2>/dev/null | jq -r '.[-1].short_id')
    if [[ "$LATEST_SNAPSHOT_ID" == "null" || -z "$LATEST_SNAPSHOT_ID" ]]; then
        LATEST_SNAPSHOT_ID=""
    fi

    CURRENT_DAY=$(date +%u)
    if [ -z "$LATEST_SNAPSHOT_ID" ]; then
        backup_type="initialFullBackup"
        echo "[*] No previous snapshot found → Full backup"
    elif [ "$CURRENT_DAY" -eq 7 ]; then
        backup_type="fullBackup"
        echo "[*] Sunday detected → Full backup"
    else
        backup_type="incBackup"
        echo "[*] Incremental backup"
    fi

    BACKUP_DATE=$(date +%y%m%d)
    BACKUP_TAG="jenkins-$backup_type-$BACKUP_DATE"

    echo "[*] Executing restic backup with tag: $BACKUP_TAG"

    case "$backup_type" in
        initialFullBackup | incBackup)
            BACKUP_OUTPUT=$(RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "$RESTIC_REPO_JENKINS" backup "$BACKUP_DIR" --tag "$BACKUP_TAG" --exclude "$EXCLUDE_DIR" 2>&1)
            ;;
        fullBackup)
            BACKUP_OUTPUT=$(RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "$RESTIC_REPO_JENKINS" backup --force "$BACKUP_DIR" --tag "$BACKUP_TAG" --exclude "$EXCLUDE_DIR" 2>&1)
            ;;
        *)
            echo "[-] Unknown backup type: $backup_type"
            return 1
            ;;
    esac

    if [ $? -ne 0 ]; then
        echo "[-] Restic backup failed:"
        echo "$BACKUP_OUTPUT"
        return 1
    fi

    NEW_SNAPSHOT_ID=$(restic -r "$RESTIC_REPO_JENKINS" snapshots --json 2>/dev/null | jq -r '.[-1].short_id')
    if [ -z "$NEW_SNAPSHOT_ID" ]; then
        echo "[-] Snapshot creation failed"
        return 1
    fi

    echo "[+] Backup completed: Type=$backup_type, Snapshot=$NEW_SNAPSHOT_ID"

    # diff 출력 (증분 백업일 경우)
    if [ "$backup_type" = "incBackup" ] && [ -n "$LATEST_SNAPSHOT_ID" ]; then
        echo "[*] Showing diff from $LATEST_SNAPSHOT_ID to $NEW_SNAPSHOT_ID"
        restic -r "$RESTIC_REPO_JENKINS" diff "$LATEST_SNAPSHOT_ID" "$NEW_SNAPSHOT_ID" || echo "[-] Diff failed"
    fi

    # 스냅샷 정보 출력
    echo "=================================================================================="
    restic -r "$RESTIC_REPO_JENKINS" snapshots "$NEW_SNAPSHOT_ID"
    echo "=================================================================================="
}

# 실제 실행
restic_backup "s3"
restic_backup "local"

