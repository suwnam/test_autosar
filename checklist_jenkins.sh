#!/bin/bash

## This script is for checking primary backup files/dirs in Jenkins repo
## version: v0.1
## date: 2025-03-24

JENKINS_HOME="/home/popcornsar/DevOps/01_Jenkins/jenkins_home"

# 스냅샷의 tag 가져오기
BACKUP_DATE=$(date +%y%m%d)
tags=$(restic -r "$RESTIC_REPO_JENKINS" snapshots latest --json | jq -r '.[-1].tags[]')

# 오늘자 스냅샷 여부 확인
if echo "$tags" | grep -q "^$BACKUP_DATE$"; then
  echo "(+) found today snapshots."
else
  echo "(-) No today snapshots found. exit..."
  exit 1
fi

echo "(+) Target snapshot ID: $snapshot_id"
echo "==========================="

# Primary Jenkins file lists
jenkins_paths=(
  "$JENKINS_HOME/config.xml"
  "$JENKINS_HOME/credentials.xml"
  "$JENKINS_HOME/jobs"
  "$JENKINS_HOME/plugins"
  "$JENKINS_HOME/secrets"
  "$JENKINS_HOME/users"
  "$JENKINS_HOME/nodes"
  "$JENKINS_HOME/identity.key.enc"
)

# Check latest snapshots have primary files
check_paths() {
  local label=$1
  shift
  local paths=("$@")

  echo "[+] Checking if exists $label..."
  for path in "${paths[@]}"; do
    if restic -r $RESTIC_REPO_JENKINS ls "$snapshot_id" | grep -q "$path"; then
      echo "(+) SUCCESS : $path"
    else
      echo "(-) FAIL : $path"
    fi
  done
  echo
}

check_paths "Jenkins" "${jenkins_paths[@]}"
