pipeline {
    agent {
        docker {
            image 'madakaanmisha/node16-docker-agent:latest' 
            args '-v isec6000-assessment2-jenkins_jenkins_docker_certs:/certs/client:ro'
        }
    }

    environment {
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_CERT_PATH = '/certs/client'
        DOCKER_TLS_VERIFY = '1'
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
            sh 'npm audit --audit-level=high'
        }
    }

    stage('Run Tests') {
        steps {
            echo 'Running application tests...'
            sh 'npm test'
        }
    }

        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm ci'
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running dependency vulnerability scan...'
                sh 'npm audit --audit-level=high'
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
                sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
                sh 'docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'madakaanmisha',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest
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
