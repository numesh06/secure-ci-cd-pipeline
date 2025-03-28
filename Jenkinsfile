pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'my-ecr-repo'
    }

    stages {
        stage('Checkout Code') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-PAT-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh '''
                    if [ -d "secure-ci-cd-pipeline" ]; then
                        echo "Directory exists, removing it..."
                        rm -rf secure-ci-cd-pipeline
                    fi
                    git clone https://$GIT_USER:$GIT_PASS@github.com/numesh06/secure-ci-cd-pipeline.git
                    '''
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-app .'
            }
        }

        stage('Push to AWS ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    withEnv([
                        'AWS_ACCOUNT_ID=590183674500'
                    ]){
                    sh '''
                    set -e
                    
                    echo "Logging into AWS ECR..."
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                    echo "Tagging and pushing Docker image..."
                    docker tag my-app:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest
                    '''
                    }    
                }
            }
        }
        stage('Deploy to AWS ECS') {
            steps {
                sh 'cd terraform'
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Run OWASP ZAP Security Scan') {
            steps {
                sh 'zap-cli quick-scan --self-contained --api-key=your-key http://your-app-url'
                }
            }
        }
    }    
