//# i am writing jenkns file for go language applicaftion  , i am using declarative pipeline syntax, i am using jenkins pipeline to build go language application,
pipeline{
    agent any
    environment {
        PATH = "/usr/local/go/bin:${PATH}"
    }
    
    stages{
        stage('Checkout code stage'){
            steps{
                sh 'echo passed'
                //checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/SivaSuribabu/go-web-app-jenkins.git']])
         }
        }

        stage('Install Depenencies'){
            steps{
                sh 'echo Installing Dependencies'
                sh 'go mod download'
            }
        }
        stage('Build Application'){
            steps{
                sh 'echo Building Application'
                sh'go version'
                sh 'go build -o go-web-app-jenkins .'
            }
        }

        stage('Run Tests'){
            steps{
                sh 'echo Running Tests'
                sh 'go test ./...'
            }
        }

        stage('Build and Push Docker Image') {
            environment {
                DOCKER_IMAGE = "sivasuribabu/go-web-app-jenkins:${BUILD_NUMBER}"
                // DOCKERFILE_LOCATION = "java-maven-sonar-argocd-helm-k8s/spring-boot-app/Dockerfile."
                REGISTRY_CREDENTIALS = credentials('docker-cred')
            }
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
                    dockerImage.push()
                    }
                }
             } 
        }

    }  
}