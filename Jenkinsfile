// This script is Jenkinsfile
// version: v0.2.2
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
                    runRemoteScripts([SCRIPT_JBACKUP, SCRIPT_JCHECK])
                }
            }
        }

        stage('Run Backup Nexus') {
            steps {
                script {
                    runRemoteScripts([SCRIPT_NBACKUP, SCRIPT_NCHECK])
                }
            }
        }

        stage('Run Cleanup Jenkins Snapshots') {
            steps {
                script {
                    runRemoteScripts([SCRIPT_JCLEAN])
                }
            }
        }

        stage('Run Cleanup Nexus Snapshots') {
            steps {
                script {
                    runRemoteScripts([SCRIPT_NCLEAN])
                }
            }
        }
    }
}

def runRemoteScripts(scriptList) {
    sshagent (credentials: ['ssh-key']) {
        withCredentials([string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')]) {
            def copyScripts = scriptList.collect { script ->
                "scp -o StrictHostKeyChecking=no ${script} ${env.REMOTE_USER}@${env.REMOTE_HOST}:${env.REMOTE_PATH}/"
            }.join('\n')

            def runScripts = scriptList.collect { script ->
                "bash ${env.REMOTE_PATH}/${script} || { echo '[!] ${script} failed'; exit 1; }"
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
                    export RESTIC_REPO="${env.RESTIC_REPO}"
                    export RESTIC_PASSWORD="${env.RESTIC_PASSWORD}"

                    ${runScripts}

                    ${cleanScripts}
                '
            """
        }
    }
}

