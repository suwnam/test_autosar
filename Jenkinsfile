// This script is Jenkinsfile
// version: v0.3
// date: 2025-03-28

// 백업 성공 여부를 저장할 전역 변수
def runBackupJenkinsSuccess = false
def runBackupNexusSuccess = false

pipeline {
    agent any

    environment {
        // 원격 접속 정보
        REMOTE_USER = 'popcornsar'
        REMOTE_HOST = '192.168.10.28'
        REMOTE_PATH = '/home/popcornsar/remote-files'

        // 사용할 스크립트 파일명
        SCRIPT_JBACKUP = 'backup_jenkins.sh'
        SCRIPT_NBACKUP = 'backup_nexus.sh'
        SCRIPT_JCHECK  = 'checklist_jenkins.sh'
        SCRIPT_NCHECK  = 'checklist_nexus.sh'
        SCRIPT_JCLEAN  = 'cleanup_jenkins.sh'
        SCRIPT_NCLEAN  = 'cleanup_nexus.sh'
    }

    stages {
        // 모든 쉘 스크립트 실행 권한 부여
        stage('Prepare Execution') {
            steps {
                sh 'chmod +x ./*sh'
            }
        }

        // Jenkins 백업 실행: 실패해도 다음 스테이지로 진행하되, 실패로 표시
        stage('Run Backup Jenkins') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        env.RESTIC_S3_JENKINS = "${env.RESTIC_REPO_S3}/test_jenkins"
			env.RESTIC_LO_JENKINS = "${env.RESTIC_REPO_LOCAL}/test_jenkins"
                        runRemoteScripts([SCRIPT_JBACKUP, SCRIPT_JCHECK])
                        runBackupJenkinsSuccess = true
                    }
                }
            }
        }

        // Nexus 백업 실행: 실패해도 다음 스테이지로 진행하되, 실패로 표시
        stage('Run Backup Nexus') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        env.RESTIC_S3_NEXUS = "${env.RESTIC_REPO_S3}/test_nexus"
			env.RESTIC_LO_NEXUS = "${env.RESTIC_REPO_LOCAL}/test_nexus"
//                        runRemoteScripts([SCRIPT_NBACKUP, SCRIPT_NCHECK])
                        runBackupNexusSuccess = true
                    }
                }
            }
        }

        // Jenkins 스냅샷 클린업: 백업이 성공한 경우에만 실행됨
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
//                    runRemoteScripts([SCRIPT_JCLEAN])
                }
            }
        }

        // Nexus 스냅샷 클린업: 백업이 성공한 경우에만 실행됨
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
 //                   runRemoteScripts([SCRIPT_NCLEAN])
                }
            }
        }
    }
}

// 공통 함수: 원격 서버에 스크립트 전송 → 실행 → 삭제까지 수행
def runRemoteScripts(scriptList) {
    sshagent (credentials: ['ssh-key']) {
        withCredentials([string(credentialsId: 'RESTIC_PASSWORD', variable: 'RESTIC_PASSWORD')]) {
            
            // 1. 각 스크립트를 원격서버에 복사
            def copyScripts = scriptList.collect { script ->
                "scp -o StrictHostKeyChecking=no ${script} ${env.REMOTE_USER}@${env.REMOTE_HOST}:${env.REMOTE_PATH}/"
            }.join('\n')

            // 2. 각 스크립트를 원격 서버에서 실행 (실패 시 에러 출력)
            def runScripts = scriptList.collect { script ->
                "bash ${env.REMOTE_PATH}/${script} || { echo '[!] ${script} failed'; exit 1; }"
            }.join('\n')

            // 3. 실행 후 원격 서버에서 스크립트 삭제
            def cleanScripts = scriptList.collect { script ->
                "rm -f ${env.REMOTE_PATH}/${script}"
            }.join('\n')

            // 전체 원격 실행 프로세스
            sh """
                echo "[*] Copying scripts to remote server"
                ${copyScripts}

                echo "[*] Running scripts on remote server"
                ssh -o StrictHostKeyChecking=no ${env.REMOTE_USER}@${env.REMOTE_HOST} '
                    set -e  // 중간에 오류 나면 전체 종료
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

