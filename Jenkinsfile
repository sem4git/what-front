pipeline {
        agent {
		label 'docker-dotnet'
	}	
    stages {
        
        stage('Build') { 
            steps {
		sh 'npm run build'
            }
        }
	stage('SonarQube Analysis') {
	environment {
            scannerHome = tool 'SonarScanner'
			}
            steps {
		withSonarQubeEnv('sonar') {
		sh "${scannerHome}/bin/sonar-scanner"
		}
            }
        }
	stage('Publish') {
	    steps {
		sh 'npm config set registry http://nexus-loadb-6puu3e2x3dzt-1303686621.us-east-2.elb.amazonaws.com/repository/what-front/'
		sh 'npm adduser --registry=http://nexus-loadb-6puu3e2x3dzt-1303686621.us-east-2.elb.amazonaws.com/repository/what-front/'
		sh 'npm publish --http://nexus-loadb-6puu3e2x3dzt-1303686621.us-east-2.elb.amazonaws.com/repository/what-front/'
	    }
	}
    }
}
