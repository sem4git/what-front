pipeline {
    agent {
        docker {
            image 'node:10.19.0' 
            args '-p 3000:3000 --network host' 
        }
    }
    stages {
        stage('Build') { 
            steps {
                sh 'npm install'
		sh 'npm run build'
            }
        }
	stage('Publish') {
	    steps {
		sh 'npm config set registry http://localhost:8081/repository/what-front/'
		sh 'npm adduser --registry=http://localhost:8081/repository/what-front/'
		sh 'npm publish --registry=http://localhost:8081/repository/what-front/'
	    }
	}
    }
}
