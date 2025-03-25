// This script is Jenkinsfile
// version: v0.2.4
// date: 2025-03-25

pipeline {
    agent any

    environment {
        REMOTE_USER = 'popcornsar'
        REMOTE_HOST = '192.168.10.28'
        REMOTE_PATH = '/home/popcornsar/remote-files'

        SCRIPT_JBACKUP = 'backup_jenkins.sh'
        SCRIPT_NBACKUP = 'backup_nexus.sh'

        SCRIPT_JCHECK = 'checklist_jenkins.sh'
        SCRIPT_NCHECK = 'checklist_nexus.sh'

        SCRIPT_JCLEAN = 'cleanup_jenkins.sh'
        SCRIPT_NCLEAN = 'cleanup_nexus.sh'
    }

    stages {
        stage('Prepare Execution') {
            steps {
                sh 'chmod +x ./*sh'
            }
        }

        stage('Run Backup Jenkins') {
            steps {
                script {
                    env.RESTIC_REPO_JENKINS = "${env.RESTIC_REPO}/test_jenkins"
                    runRemoteScripts([SCRIPT_JBACKUP, SCRIPT_JCHECK])
                }
            }
        }

        stage('Run Backup Nexus') {
            steps {
                script {
                    env.RESTIC_REPO_NEXUS = "${env.RESTIC_REPO}/test_nexus"
                    runRemoteScripts([SCRIPT_NBACKUP, SCRIPT_NCHECK])
                }
            }
        }

        stage('Run Cleanup Jenkins Snapshots') {
            steps {
                script {
                    env.RESTIC_REPO_JENKINS = "${env.RESTIC_REPO}/test_jenkins"
                    runRemoteScripts([SCRIPT_JCLEAN])
                }
            }
        }

        stage('Run Cleanup Nexus Snapshots') {
            steps {
                script {
                    env.RESTIC_REPO_NEXUS = "${env.RESTIC_REPO}/test_nexus"
                    runRemoteScripts([SCRIPT_NCLEAN])
                }
            }
        }
    }
}

def runRemoteScripts(scriptList) {
    sshagent (credentials: ['ssh-key']) {
        withCredentials([string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')]) {

            // 스크립트 복사 명령 구성
            def copyScripts = scriptList.collect { script ->
                "scp -o StrictHostKeyChecking=no ${script} ${env.REMOTE_USER}@${env.REMOTE_HOST}:${env.REMOTE_PATH}/"
            }.join('\n')

            // 각 스크립트를 실행하고 실패 감지
            def runScripts = scriptList.collect { script ->
                "bash ${env.REMOTE_PATH}/${script} || { echo '[!] ${script} failed'; exit 1; }"
            }.join('\n')

            // 실행 후 스크립트 삭제
            def cleanScripts = scriptList.collect { script ->
                "rm -f ${env.REMOTE_PATH}/${script}"
            }.join('\n')

            // 실행 전체 블록: RESTIC 변수는 쉘 안에서 처리
            sh '''#!/bin/bash
                echo "[*] Copying scripts to remote server"
                ''' + copyScripts + '''

                echo "[*] Running scripts on remote server"
                ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST '
                    set -e

                    export RESTIC_REPO="''' + env.RESTIC_REPO + '''"
                    export RESTIC_REPO_JENKINS="''' + (env.RESTIC_REPO_JENKINS ?: "") + '''"
                    export RESTIC_REPO_NEXUS="''' + (env.RESTIC_REPO_NEXUS ?: "") + '''"
                    export RESTIC_PASSWORD="$RESTIC_PASSWORD"

                    ''' + runScripts + '''

                    ''' + cleanScripts + '''
                '
            '''
        }
    }
}

