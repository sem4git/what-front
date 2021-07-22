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
		    sh 'echo "//nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/:_authToken=$npm_token" >> ~/.npmrc'
		    sh 'npm set registry http://nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/'
		    sh 'npm publish'
	    }
	}
	stage('terraform publish') {
	    steps {
		    sh 'ls -la'
		    sh 'cd terraform/front/ | terraform init | terraform plan'
		    sh 'ls -la'
		    sh 'terraform init'
		    sh 'terraform plan'
	    }
	}
    }
}
