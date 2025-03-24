// This script is Jenkinsfile
// version: v0.2
// date: 2025-03-17


pipeline {
    agent any

    environment {
        REMOTE_USER = 'popcornsar'
        REMOTE_HOST = '192.168.10.28'
        REMOTE_PATH = '/home/popcornsar/remote-files'

        SCRIPT_JBACKUP = 'backup_jenkins.sh'
        SCRIPT_NBACKUP = 'backup_nexus.sh'

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
                            echo "[+] Copying Jenkins backup script to remote server"
                            scp -o StrictHostKeyChecking=no $SCRIPT_JBACKUP $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

                            echo "[+] Running Jenkins backup script on remote server"
                            ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "
                                export RESTIC_REPO='$RESTIC_REPO' &&
                                export RESTIC_PASSWORD='$RESTIC_PASSWORD' &&
                                bash $REMOTE_PATH/$SCRIPT_JBACKUP
                                rm -f $REMOTE_PATH/$SCRIPT_JBACKUP
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
                            echo "[+] Copying Nexus backup script to remote server"
                            scp -o StrictHostKeyChecking=no $SCRIPT_NBACKUP $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

                            echo "[+] Running Nexus backup script on remote server"
                            ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "
                                export RESTIC_REPO='$RESTIC_REPO' &&
                                export RESTIC_PASSWORD='$RESTIC_PASSWORD' &&
                                bash $REMOTE_PATH/$SCRIPT_NBACKUP
                                rm -f $REMOTE_PATH/$SCRIPT_NBACKUP
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
                            echo "[+] Copying Jenkins Cleanup script to remote server"
                            scp -o StrictHostKeyChecking=no $SCRIPT_JCLEAN $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

                            echo "[+] Running Jenkins Cleanup script on remote server"
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
                            echo "[+] Copying Nexus Cleanup script to remote server"
                            scp -o StrictHostKeyChecking=no $SCRIPT_NCLEAN $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/

                            echo "[+] Running Nexus Cleanup script on remote server"
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
