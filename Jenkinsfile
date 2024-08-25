pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sivasuribabu/go-web-app-final'
        DOCKER_REGISTRY = 'docker.io'
        GITHUB_REPO = 'https://github.com/SivaSuribabu/devsecops-go-web-app-main.git'
    }

    stages {
        stage('Checkout'){
            steps {
		sh 'echo passed'
                //withCredentials([usernamePassword(credentialsId: 'git-credentials', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    git credentialsId: 'git-credentials', url: 'https://github.com/${GITHUB_REPO}.git'
                }
            }
        }

        stage('Build'){
            steps {
                sh 'go build -o go-web-app-final'
            }
        }

        stage('Test'){
            steps {
                sh 'go test ./...'
            }
        }

        stage('Code Quality'){
            environment {
                scannerHome = tool 'SonarQubeScanner'
            }
            steps {
                withSonarQubeEnv('SonarQube'){
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }

        stage('Dependency Check'){
            steps {
                sh 'dependency-check --project go-web-app-final --scan .'
            }
        }

        stage('Package'){
            steps {
                sh 'tar -czf go-web-app-final.tar.gz go-web-app-final'
            }
        }

        stage('Build Docker Image'){
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Image Scanning'){
            steps {
                sh "trivy image ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('Push Docker Image'){
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-creD') {
                            docker.image("${DOCKER_IMAGE}:${BUILD_NUMBER}").push()
                        }
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests'){
            steps {
                withCredentials([usernamePassword(credentialsId: 'git-cred', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    script {
                        sh """
                        sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|' k8s/manifests/deployment.yaml
                        git config user.email "${GIT_USERNAME}"
                        git config user.name "${GIT_USERNAME}"
                        git add k8s/manifests/deployment.yaml
                        git commit -m "Update image tag to ${BUILD_NUMBER}"
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/${GITHUB_REPO}.git
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
