// This script is Jenkinsfile
// version: v0.2.1
// date: 2025-03-24


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
                sh "chmod +x ./*sh"
            }
        }

        stage('Run Backup Jenkins') {
            steps {
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
                }
            }
        }

        stage('Run Backup Nexus') {
            steps {
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
                }
            }
        }

        stage('Run Cleanup Jenkins Snapshots') {
            steps {
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
                }
            }
        }

        stage('Run Cleanup Nexus Snapshots') {
            steps {
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
                }
            }
        }
    }
}
