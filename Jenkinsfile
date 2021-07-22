pipeline {
        agent {
		label 'docker-dotnet'
	}	
    stages {
        
        stage('Build') { 
            steps {
		    sh 'npm install --no-package-lock'
		sh 'npm run build'
            }
        }
	stage('Publish') {
	    steps {
		    sh 'echo "//nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/:_authToken=NpmToken.42aa5c17-73f4-399f-8e8a-d65d99417f9f" >> ~/.npmrc'
		    sh 'npm set registry http://nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/'
		    sh 'npm publish'
	    }
	}
    }
}
