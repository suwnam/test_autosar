// This script is Jenkinsfile
// version: v0.3
// date: 2025-03-28

def runBackupJenkinsSuccess = false
def runBackupNexusSuccess = false

pipeline {
    agent any

    environment {
        REMOTE_USER = 'popcornsar'
        REMOTE_HOST = '192.168.10.28'
        REMOTE_PATH = '/home/popcornsar/remote-files'

        SCRIPT_JBACKUP = 'backup_jenkins.sh'
        SCRIPT_NBACKUP = 'backup_nexus.sh'
        SCRIPT_JCHECK  = 'checklist_jenkins.sh'
        SCRIPT_NCHECK  = 'checklist_nexus.sh'
        SCRIPT_JCLEAN  = 'cleanup_jenkins.sh'
        SCRIPT_NCLEAN  = 'cleanup_nexus.sh'
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
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        env.RESTIC_S3_JENKINS = "${env.RESTIC_REPO_S3}/test_jenkins"
                        env.RESTIC_LO_JENKINS = "${env.RESTIC_REPO_LOCAL}/test_jenkins"
                        runRemoteScripts([SCRIPT_JBACKUP])
                        runBackupJenkinsSuccess = true
                    }
                }
            }
        }

        stage('Run Backup Nexus') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        env.RESTIC_S3_NEXUS = "${env.RESTIC_REPO_S3}/test_nexus"
                        env.RESTIC_LO_NEXUS = "${env.RESTIC_REPO_LOCAL}/test_nexus"
                        // runRemoteScripts([SCRIPT_NBACKUP])
                        runBackupNexusSuccess = true
                    }
                }
            }
        }

        stage('Run Cleanup Jenkins Snapshots') {
            when {
                expression {
                    return runBackupJenkinsSuccess
                }
            }
            steps {
                script {
                    env.RESTIC_S3_JENKINS = "${env.RESTIC_REPO_S3}/test_jenkins"
                    env.RESTIC_LO_JENKINS = "${env.RESTIC_REPO_LOCAL}/test_jenkins"
                    // runRemoteScripts([SCRIPT_JCLEAN])
                }
            }
        }

        stage('Run Cleanup Nexus Snapshots') {
            when {
                expression {
                    return runBackupNexusSuccess
                }
            }
            steps {
                script {
                    env.RESTIC_S3_NEXUS = "${env.RESTIC_REPO_S3}/test_nexus"
                    env.RESTIC_LO_NEXUS = "${env.RESTIC_REPO_LOCAL}/test_nexus"
                    // runRemoteScripts([SCRIPT_NCLEAN])
                }
            }
        }
    }
}

// === ✅ runRemoteScripts 함수: 쉘스크립트에 인자 전달 방식 반영 ===
def runRemoteScripts(scriptList) {
    sshagent (credentials: ['ssh-key']) {
        withCredentials([string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')]) {

            def copyScripts = scriptList.collect { script ->
                "scp -o StrictHostKeyChecking=no ${script} ${env.REMOTE_USER}@${env.REMOTE_HOST}:${env.REMOTE_PATH}/"
            }.join('\n')

            def runScripts = scriptList.collect { script ->
                // ⬇ 쉘스크립트에 S3, Local 인자 전달
                "bash ${env.REMOTE_PATH}/${script} '${env.RESTIC_S3_JENKINS}' '${env.RESTIC_LO_JENKINS}' '${env.RESTIC_S3_NEXUS}' '${env.RESTIC_LO_NEXUS}' || { echo '[!] ${script} failed'; exit 1; }"
            }.join('\n')

            def cleanScripts = scriptList.collect { script ->
                "rm -f ${env.REMOTE_PATH}/${script}"
            }.join('\n')

            sh """
                echo "[*] Copying scripts to remote server"
                ${copyScripts}

                echo "[*] Running scripts on remote server"
                ssh -o StrictHostKeyChecking=no ${env.REMOTE_USER}@${env.REMOTE_HOST} '
                    set -e
                    export RESTIC_PASSWORD="${env.RESTIC_PASSWORD}"

                    ${runScripts}

                    ${cleanScripts}
                '
            """
        }
    }
}
