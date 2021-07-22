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
		    sh 'echo "//nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/:username=admin" >> ~/.npmrc'
		    sh 'echo "//nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/:password=zxczxc" >> ~/.npmrc'
		    sh 'echo "//nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/:email=ganzha_as@outlook.com" >> ~/.npmrc'
		    sh 'echo "//nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/:always-auth=true" >> ~/.npmrc'
		    sh 'npm set registry http://nexus-loadb-27omuynaly1z-837220146.us-east-2.elb.amazonaws.com/repository/what-front/'
		    sh 'npm version-tag patch'
		    sh 'npm publish'
	    }
	}
    }
}
