pipeline {
    agent {
        docker {
            image 'node:14.15.0' 
            args '-p 3000:3000' 
        }
    }
    stages {
        stage('Build') { 
            steps {
                sh 'npm install'
				sh 'npm run build'
            }
        }
    }
}