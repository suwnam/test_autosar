#!/bin/bash

## This script is for restore jenkins
## version: v0.1
## date: 2025-03-04

EXCLUDE_JOB="restore-test-000"

# Restic 저장소 연결 확인
if restic -r "$RESTIC_REPO_JENKINS" snapshots > /dev/null 2>&1; then
    echo "Successfully connected to Restic jenkins repository"
else
    echo "Failed to connect to Restic jenkins repository"
    exit 1
fi

# 최신 스냅샷 ID 가져오기 (&백업 존재 여부 확인)
LATEST_SNAPSHOT_ID=$(restic -r "$RESTIC_REPO_JENKINS" snapshots --json 2>/dev/null | jq -r '.[-1].short_id')

# JSON 오류에 대한 예외처리
if [[ "$LATEST_SNAPSHOT_ID" == "null" || -z "$LATEST_SNAPSHOT_ID" ]]; then
   echo "!!Warning: No snapshot found. exit.."
   exit 1
fi


# 최신 스냅샷으로 복원
restic -r "$RESTIC_REPO_JENKINS" restore "$LATEST_SNAPSHOT_ID" --target / --include "$JENKINS_HOME" --exclude "$EXCLUDE_JOB" --delete
echo "Restore completed successfully"

