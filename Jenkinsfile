pipeline {
    agent {
        docker {
            image 'madakaanmisha/node16-docker-agent:latest'
            args '--network=isec6000-assessment2-jenkins_jenkins_network -v isec6000-assessment2-jenkins_jenkins_docker_certs:/certs/client:ro'
        }
    }

    environment {
        DOCKER_IMAGE = 'madakaanmisha/aws-elastic-beanstalk-express-js-sample'
    }

    stages {

        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm ci'
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running dependency vulnerability scan...'

                sh 'npm audit --json > npm-audit.json || true'

                sh 'npm audit --audit-level=high'
            }

            post {
                always {
                    archiveArtifacts artifacts: 'npm-audit.json', allowEmptyArchive: true
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running application tests...'
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'

                sh '''
                    DOCKER_HOST=tcp://docker:2376 \
                    DOCKER_CERT_PATH=/certs/client \
                    DOCKER_TLS_VERIFY=1 \
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                '''

                sh '''
                    DOCKER_HOST=tcp://docker:2376 \
                    DOCKER_CERT_PATH=/certs/client \
                    DOCKER_TLS_VERIFY=1 \
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'madakaanmisha',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | \
                        DOCKER_HOST=tcp://docker:2376 \
                        DOCKER_CERT_PATH=/certs/client \
                        DOCKER_TLS_VERIFY=1 \
                        docker login -u "$DOCKER_USERNAME" --password-stdin

                        DOCKER_HOST=tcp://docker:2376 \
                        DOCKER_CERT_PATH=/certs/client \
                        DOCKER_TLS_VERIFY=1 \
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}

                        DOCKER_HOST=tcp://docker:2376 \
                        DOCKER_CERT_PATH=/certs/client \
                        DOCKER_TLS_VERIFY=1 \
                        docker push ${DOCKER_IMAGE}:latest

                        DOCKER_HOST=tcp://docker:2376 \
                        DOCKER_CERT_PATH=/certs/client \
                        DOCKER_TLS_VERIFY=1 \
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }

        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }
    }
}
