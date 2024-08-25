pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sivasuribabu/go-web-app-final'
        DOCKER_REGISTRY = 'docker.io'
        GITHUB_REPO = 'SivaSuribabu/go-web-app-jenkins.git'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/SivaSuribabu/go-web-app-jenkins.git'
            }
        }

        stage('Build') {
            steps {
                sh 'go build -o go-web-app-final'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'SonarQubeScanner'
            }
            steps {
                withCredentials([string(credentialsId: 'sonar-cred', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.login=${SONAR_TOKEN}"
                    }
                }
            }
        }

        stage('Trivy Test') {
            steps {
                sh 'trivy fs .'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Scan Docker Image') {
            steps {
                sh "trivy image ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-cred') {
                            docker.image("${DOCKER_IMAGE}:${BUILD_NUMBER}").push()
                        }
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'git-credentials', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    script {
                        sh """
                        sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|' k8s/manifests/deployment.yml
                        git config user.email "your-email@example.com"
                        git config user.name "your-github-username"
                        git add k8s/manifests/deployment.yml
                        git commit -m "Update image tag to ${BUILD_NUMBER}"
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/your-github-username/${GITHUB_REPO}.git
                        """
                    }
                }
            }
        }
    }
}
