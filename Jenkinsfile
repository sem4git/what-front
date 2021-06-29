pipeline {
	agent any
    stages {
		stage('Build Api') {
			agent {
				docker {
					image 'node:latest'
				}
			}
            steps {
					sh 'npm run build'
				}
            }
		
		}
}