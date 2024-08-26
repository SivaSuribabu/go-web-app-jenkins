//# i am writing jenkns file for go language applicaftion  , i am using declarative pipeline syntax, i am using jenkins pipeline to build go language application,
pipeline{
    agent any
    environment {
        PATH = "/usr/local/go/bin:${PATH}"
    }
    
    stages{
        stage('Checkout code'){
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
                sh 'go build -o main .'
            }
        }

        stage('Run Tests'){
            steps{
                sh 'echo Running Tests'
                sh 'go test ./...'
            }
        }

        stage('Static Code Analysis') {
      environment {
        SONAR_URL = "http://172.17.0.1 :9000/"
      }
      steps {
        withCredentials([string(credentialsId: 'sonar-cred', variable: 'SONAR_AUTH_TOKEN')]) {
          sh 'sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
        }
      }
    }
    }
}