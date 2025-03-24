#!/bin/bash

# ========================
# Jenkins & Nexus 백업 스크립트
# Ubuntu 22.04 LTS + restic
# ========================

# 📍 환경 변수 설정
export RESTIC_REPOSITORY="/mnt/backup/restic-repo"
export RESTIC_PASSWORD="your-restic-password"

# Jenkins/Nexus 경로
JENKINS_HOME="/var/lib/jenkins"
NEXUS_DATA="/opt/sonatype/nexus/nexus-data"

# 백업 태그
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

# 로그
LOG_FILE="/var/log/jenkins_nexus_backup_$TIMESTAMP.log"

# 📁 백업 대상 목록 (workspace 제외 가능)
BACKUP_TARGETS=(
    "$JENKINS_HOME/config.xml"
    "$JENKINS_HOME/credentials.xml"
    "$JENKINS_HOME/jobs"
    "$JENKINS_HOME/plugins"
    "$JENKINS_HOME/secrets"
    "$JENKINS_HOME/users"
    "$NEXUS_DATA/blobs"
    "$NEXUS_DATA/db"
    "$NEXUS_DATA/etc"
    "$NEXUS_DATA/orient"
)

# 🛑 Jenkins & Nexus 중지 (선택)
echo "Stopping Jenkins and Nexus..." | tee -a "$LOG_FILE"
systemctl stop jenkins
systemctl stop nexus

# 📦 백업 실행
echo "Starting backup with restic..." | tee -a "$LOG_FILE"
restic backup "${BACKUP_TARGETS[@]}" \
    --tag "jenkins-nexus" \
    --tag "$TIMESTAMP" \
    --exclude "$JENKINS_HOME/workspace" \
    --exclude "$NEXUS_DATA/tmp" \
    --exclude "$NEXUS_DATA/cache" \
    | tee -a "$LOG_FILE"

# 🔃 Jenkins & Nexus 재시작
echo "Starting Jenkins and Nexus..." | tee -a "$LOG_FILE"
systemctl start jenkins
systemctl start nexus

# ✅ 스냅샷 확인
echo "Latest snapshots:" | tee -a "$LOG_FILE"
restic snapshots --tag "jenkins-nexus" | tee -a "$LOG_FILE"

# 🧹 오래된 백업 자동 정리 (예: 30일 초과 삭제)
echo "Pruning old backups..." | tee -a "$LOG_FILE"
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune | tee -a "$LOG_FILE"

echo "✅ Backup completed at $TIMESTAMP" | tee -a "$LOG_FILE"
