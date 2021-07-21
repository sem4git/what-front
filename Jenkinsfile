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
                sh 'npm install --no-package-lock'
		sh 'npm run build'
            }
        }
	stage('SonarQube Analysis') { 
		agent {
        docker {
            image 'openjdk' 
            args '-p 3000:3000 --network host' 
        }
    }
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
