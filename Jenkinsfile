pipeline {
	agent any
    stages {
		stage('Build Api') {
			agent any
            steps {
					sh 'npm install'
					sh 'npm run build'
				}
            }
		
		}
}