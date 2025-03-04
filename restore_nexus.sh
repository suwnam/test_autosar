#!/bin/bash

## This script is for restore nexus inside a Docker container
## version: v0.1
## date: 2025-03-04

# 환경 변수 설정
export NEXUS_CONTAINER_NAME="nexus_stg"  # 넥서스 컨테이너 이름
export RESTIC_REPO_NEXUS="$RESTIC_REPO/test_nexus"
export NEXUS_HOME="/nexus-data"  # 넥서스 데이터 저장 경로

# Nexus 컨테이너 내부에서 Restic 복원 실행
docker exec -t -e RESTIC_PASSWORD="$RESTIC_PASSWORD" -e RESTIC_REPO_NEXUS="$RESTIC_REPO_NEXUS" -e NEXUS_HOME="$NEXUS_HOME" "$NEXUS_CONTAINER_NAME" bash -c "

# Restic 저장소 연결 확인
if restic -r \$RESTIC_REPO_NEXUS snapshots > /dev/null 2>&1; then
    echo \"Successfully connected to Restic nexus repository\"
else
    echo \"Failed to connect to Restic nexus repository\"
    exit 1
fi

# 최신 스냅샷 ID 가져오기 (&첫 백업 여부 확인)
LATEST_SNAPSHOT_ID=\$(restic -r \$RESTIC_REPO_NEXUS snapshots --json 2>/dev/null | jq -r '.[-1].short_id')

# JSON 오류에 대한 예외처리
if [[ \"\$LATEST_SNAPSHOT_ID\" == \"null\" || -z \"\$LATEST_SNAPSHOT_ID\" ]]; then
    echo \"NO snapshot found. exit...\"
    exit 1
fi

# 최신 스냅샷으로 복원
echo \"Restoring snapshot ID: \$LATEST_SNAPSHOT_ID...\"
restic -r \$RESTIC_REPO_NEXUS restore \"\$LATEST_SNAPSHOT_ID\" --target / --include \"\$NEXUS_HOME\" --delete


echo "Restore completed successfully"
"
