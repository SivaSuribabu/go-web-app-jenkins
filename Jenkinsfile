pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sivasuribabu/go-web-app-final'
        DOCKER_REGISTRY = 'docker.io'
        GITHUB_REPO = 'SivaSuribabu/go-web-app-jenkins'
    }

    stages {
        stage('Checkout'){
            steps {
                sh 'echo passed'
                //withCredentials([string(credentialsId: 'git-cred', variable: 'GIT_TOKEN')]) {
                    //sh 'git clone https://${GIT_TOKEN}@github.com/${GITHUB_REPO}.git'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'go build -o go-web-app-final'
            }
        }

        stage('Test') {
            steps {
                sh 'go test ./...'
            }
        }

        stage('Code Quality') {
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

        stage('Dependency Check') {
            steps {
                sh 'trivy fs --exit-code 0 --severity HIGH,CRITICAL .'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Image Scanning') {
            steps {
                sh "trivy image ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                withCredentials([string(credentialsId: 'git-cred', variable: 'GIT_TOKEN')]) {
                    script {
                        sh """
                        sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|' k8s/manifests/deployment.yaml
                        git config user.email "sivaduribabupenkey@gmail.com"
                        git config user.name "sivasuribabu"
                        git add k8s/manifests/deployment.yaml
                        git commit -m "Update image tag to ${BUILD_NUMBER}"
                        git push https://${GIT_TOKEN}@github.com/${GITHUB_REPO}.git
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            emailext (
                subject: "Build Successful: ${BUILD_NUMBER}",
                body: "The build was successful. Build number: ${BUILD_NUMBER}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
