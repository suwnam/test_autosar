#!/bin/bash

## This script is for checking primary backup files/dirs in Nexus repo
## version: v0.1
## date: 2025-03-24

#RESTIC_REPO_NEXUS=$RESTIC_REPO/test_nexus
BACKUP_DIR="/home/popcornsar/DevOps/03_Nexus/nexus-data"

# 스냅샷의 tag 가져오기
BACKUP_DATE=$(date +%y%m%d)

snapshot_id=$(restic -r "$RESTIC_REPO_NEXUS" snapshots latest --json | jq -r '.[-1].short_id')
tags=$(restic -r "$RESTIC_REPO_NEXUS" snapshots $snapshot_id --json | jq -r '.[-1].tags[]')

# 오늘자 스냅샷 여부 확인
if [[ "$tags" == *"$BACKUP_DATE"* ]]; then
  echo "[+] found today snapshots."
else
  echo "[-] No today snapshots found. exit..."
  exit 1
fi

echo "[*] Target snapshot ID: $snapshot_id"
echo "==========================="

# Primary Nexus file lists
nexus_paths=(
  "$BACKUP_DIR/blobs"
  "$BACKUP_DIR/db"
  "$BACKUP_DIR/etc"
#  "$BACKUP_DIR/orient"
)

# Check latest snapshots have primary files
check_paths() {
  local label=$1
  shift
  local paths=("$@")

  echo "[*] Checking if exists $label..."
  for path in "${paths[@]}"; do
    if restic -r $RESTIC_REPO_NEXUS ls "$snapshot_id" | grep -q "$path"; then
      echo "[+] SUCCESS : $path"
    else
      echo "[-] FAIL : $path"
    fi
  done
  echo
}

check_paths "Nexus_primary_files" "${nexus_paths[@]}"
