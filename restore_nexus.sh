#!/bin/bash

## This script is for restore nexus
## version: v0.1
## date: 2025-03-04

RESTIC_REPO_NEXUS="s3:s3.ap-northeast-2.amazonaws.com/synetics-backup-test/test_nexus"
NEXUS_HOME="/nexus-data"

# Restic 저장소 연결 확인
if restic -r "$RESTIC_REPO_NEXUS" snapshots > /dev/null 2>&1; then
    echo "Successfully connected to Restic nexus repository"
else
    echo "Failed to connect to Restic nexus repository"
    exit 1
fi

# 최신 스냅샷 ID 가져오기 (&백업 존재 여부 확인)
LATEST_SNAPSHOT_ID=$(restic -r "$RESTIC_REPO_NEXUS" snapshots --json 2>/dev/null | jq -r '.[-1].short_id')

# JSON 오류에 대한 예외처리
if [[ "$LATEST_SNAPSHOT_ID" == "null" || -z "$LATEST_SNAPSHOT_ID" ]]; then
   echo "!!Warning: No snapshot found. exit.."
   exit 1
fi


# 최신 스냅샷으로 복원
restic -r "$RESTIC_REPO_NEXUS" restore "$LATEST_SNAPSHOT_ID" --target / --include "$NEXUS_HOME" --delete
echo "Restore completed successfully"
