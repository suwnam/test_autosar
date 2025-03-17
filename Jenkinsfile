// This script is Jenkinsfile

// version: v0.1

// date: 2025-02-28







pipeline {

    agent any



    environment {


        RESTIC_REPO_JENKINS = "${RESTIC_REPO}/test_jenkins"

        RESTIC_REPO_NEXUS = "${RESTIC_REPO}/test_nexus"

        

        SCRIPT_JBACKUP="backup_jenkins.sh"

        SCRIPT_NBACKUP="backup_nexus.sh"

        

        SCRIPT_JCLEAN="cleanup_jenkins.sh"

        SCRIPT_NCLEAN="cleanup_nexus.sh"

    }



    stages {

        stage('Prepare Backup') {

            steps {

                script {

                    echo "Ensuring restore script has execute permissions..."

                    sh "chmod +x ./*.sh"

                }

            }

        }



        stage('Backup Jenkins') {

            steps {

                withCredentials([string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')]) {

                    script {

                        echo "Running Jenkins backup script..."

                        catchError {

                            sh './${SCRIPT_JBACKUP}'

                        }

                    }

                }

            }

        }



        stage('Backup Nexus') {

            steps {

                withCredentials([string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')]) {

                    script {

                        echo "Running Nexus backup script..."

                        catchError {

                            sh './${SCRIPT_NBACKUP}'

                        }

                    }

                }

            }

        }

        

        stage('Cleanup Jenkins Snapshots') {

            steps {

                withCredentials([string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')]) {

                    script {

                        echo "Running jenkins snapshot cleanup script..."

                        catchError {

                            sh './${SCRIPT_JCLEAN}'

                        }

                    }

                }    

            }    

        }

        

        stage('Cleanup Nexus Snapshots') {

            steps {

                withCredentials([string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')]) {

                    script {

                        echo "Running nexus snapshot cleanup script..."

                        catchError{

                            sh './${SCRIPT_NCLEAN}'

                        }

                    }    

                }

            }    

        }  

    }

}

