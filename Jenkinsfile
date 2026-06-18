pipeline {
    agent any

    parameters {
        string(name: 'THREADS', defaultValue: '1')
        string(name: 'RAMPUP', defaultValue: '30')
        string(name: 'DURATION', defaultValue: '60')
        string(name: 'URL', defaultValue: 'http://5.42.97.48:8080')
        string(name: 'THROUGHPUT', defaultValue: '1')
        string(name: 'TEST_PLAN', defaultValue: 'Test_Plan1somnenie.jmx')
    }

    environment {
        SSH_HOST = 'egromov@213.226.127.198'
        REMOTE_DIR = "/home/egromov/jmeter-runs/build-${BUILD_NUMBER}"
    }

    stages {
        stage('Prepare remote dir') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {
                    sh '''
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                            mkdir -p ${REMOTE_DIR}
                            rm -rf ${REMOTE_DIR}/*
                        "
                    '''
                }
            }
        }

        stage('Upload project') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {
                    sh '''
                        scp -i ${SSH_KEY} \
                            -o StrictHostKeyChecking=no \
                            -r test-plans properties scripts data \
                            ${SSH_HOST}:${REMOTE_DIR}/
                    '''
                }
            }
        }

        stage('Run JMeter') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {
                    sh '''
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                            cd ${REMOTE_DIR}
                            chmod +x scripts/run_jmeter.sh
                            ./scripts/run_jmeter.sh \
                                ${TEST_PLAN} \
                                ${THREADS} \
                                ${RAMPUP} \
                                ${DURATION} \
                                ${URL} \
                                ${THROUGHPUT}
                        "
                    '''
                }
            }
        }
    }

    post {
    always {
        withCredentials([
            sshUserPrivateKey(
                credentialsId: 'host-ssh-key',
                keyFileVariable: 'SSH_KEY'
            )
        ]) {
            sh '''
                ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                    pkill -TERM -f '[j]meter-runs/build-${BUILD_NUMBER}' || true
                    sleep 5
                    pkill -KILL -f '[j]meter-runs/build-${BUILD_NUMBER}' || true
                " || true

                mkdir -p results

                scp -i ${SSH_KEY} \
                    -o StrictHostKeyChecking=no \
                    -r ${SSH_HOST}:${REMOTE_DIR}/results/* \
                    results/ || true
            '''
        }

        archiveArtifacts(
            artifacts: 'results/**/*',
            allowEmptyArchive: true
        )
    }
}