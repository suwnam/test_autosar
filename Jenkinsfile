// This script is Jenkinsfile
<<<<<<< HEAD
// version: v0.2.4
// date: 2025-03-25
=======
// version: v0.2.1
// date: 2025-03-24

>>>>>>> origin/v.0.2

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
<<<<<<< HEAD
=======

>>>>>>> origin/v.0.2
    }

    stages {
        stage('Prepare Execution') {
            steps {
<<<<<<< HEAD
                sh 'chmod +x ./*sh'
=======
                sh "chmod +x ./*sh"
>>>>>>> origin/v.0.2
            }
        }

        stage('Run Backup Jenkins') {
            steps {
<<<<<<< HEAD
                script {
                    env.RESTIC_REPO_JENKINS = "${env.RESTIC_REPO}/test_jenkins"
                    runRemoteScripts([SCRIPT_JBACKUP, SCRIPT_JCHECK])
=======
                sshagent (credentials: ['ssh-key']) {
                    withCredentials([
                        string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')
                    ]) {
                        sh '''
                            echo "[*] Copying Jenkins backup script to remote server"
                            scp -o StrictHostKeyChecking=no $SCRIPT_JBACKUP $SCRIPT_JCHECK $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

                            echo "[*] Running Jenkins backup script on remote server"
                            ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "
                                export RESTIC_REPO='$RESTIC_REPO' &&
                                export RESTIC_PASSWORD='$RESTIC_PASSWORD' &&
                                bash $REMOTE_PATH/$SCRIPT_JBACKUP
                                bash $REMOTE_PATH/$SCRIPT_JCHECK
                                rm -f $REMOTE_PATH/$SCRIPT_JBACKUP $REMOTE_PATH/$SCRIPT_JCHECK
                            "
                        '''       
                    }
>>>>>>> origin/v.0.2
                }
            }
        }

        stage('Run Backup Nexus') {
            steps {
<<<<<<< HEAD
                script {
                    env.RESTIC_REPO_NEXUS = "${env.RESTIC_REPO}/test_nexus"
                    runRemoteScripts([SCRIPT_NBACKUP, SCRIPT_NCHECK])
=======
                sshagent (credentials: ['ssh-key']) {
                    withCredentials([
                        string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')
                    ]) {
                        sh '''
                            echo "[*] Copying Nexus backup script to remote server"
                            scp -o StrictHostKeyChecking=no $SCRIPT_NBACKUP $SCRIPT_NCHECK $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

                            echo "[*] Running Nexus backup script on remote server"
                            ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "
                                export RESTIC_REPO='$RESTIC_REPO' &&
                                export RESTIC_PASSWORD='$RESTIC_PASSWORD' &&
                                bash $REMOTE_PATH/$SCRIPT_NBACKUP
                                bash $REMOTE_PATH/$SCRIPT_NCHECK
                                rm -f $REMOTE_PATH/$SCRIPT_NBACKUP $REMOTE_PATH/$SCRIPT_NCHECK
                            "
                        '''       
                    }
>>>>>>> origin/v.0.2
                }
            }
        }

        stage('Run Cleanup Jenkins Snapshots') {
            steps {
<<<<<<< HEAD
                script {
                    env.RESTIC_REPO_JENKINS = "${env.RESTIC_REPO}/test_jenkins"
                    runRemoteScripts([SCRIPT_JCLEAN])
=======
                sshagent (credentials: ['ssh-key']) {
                    withCredentials([
                        string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')
                    ]) {
                        sh '''
                            echo "[*] Copying Jenkins Cleanup script to remote server"
                            scp -o StrictHostKeyChecking=no $SCRIPT_JCLEAN $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

                            echo "[*] Running Jenkins Cleanup script on remote server"
                            ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "
                                export RESTIC_REPO='$RESTIC_REPO' &&
                                export RESTIC_PASSWORD='$RESTIC_PASSWORD' &&
                                bash $REMOTE_PATH/$SCRIPT_JCLEAN
                                rm -f $REMOTE_PATH/$SCRIPT_JCLEAN
                            "
                        '''       
                    }
>>>>>>> origin/v.0.2
                }
            }
        }

        stage('Run Cleanup Nexus Snapshots') {
            steps {
<<<<<<< HEAD
                script {
                    env.RESTIC_REPO_NEXUS = "${env.RESTIC_REPO}/test_nexus"
                    runRemoteScripts([SCRIPT_NCLEAN])
=======
                sshagent (credentials: ['ssh-key']) {
                    withCredentials([
                        string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')
                    ]) {
                        sh '''
                            echo "[*] Copying Nexus Cleanup script to remote server"
                            scp -o StrictHostKeyChecking=no $SCRIPT_NCLEAN $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

                            echo "[*] Running Nexus Cleanup script on remote server"
                            ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "
                                export RESTIC_REPO='$RESTIC_REPO' &&
                                export RESTIC_PASSWORD='$RESTIC_PASSWORD' &&
                                bash $REMOTE_PATH/$SCRIPT_NCLEAN
                                rm -f $REMOTE_PATH/$SCRIPT_NCLEAN
                            "
                        '''       
                    }
>>>>>>> origin/v.0.2
                }
            }
        }
    }
}
<<<<<<< HEAD

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
                    export RESTIC_REPO_JENKINS="${env.RESTIC_REPO_JENKINS}"
                    export RESTIC_REPO_NEXUS="${env.RESTIC_REPO_NEXUS}"
                    export RESTIC_PASSWORD="${env.RESTIC_PASSWORD}"

                    ${runScripts}

                    ${cleanScripts}
                '
            """
        }
    }
}

=======
>>>>>>> origin/v.0.2
