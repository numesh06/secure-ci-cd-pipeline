pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'my-ecr-repo'
        AWS_ACCOUNT_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Checkout Code') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh 'git clone https://$GIT_USER:$GIT_PASS@github.com/your-username/private-repo.git'
                }
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
                sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com'
                sh 'docker tag my-app:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest'
                sh 'docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest'
            }
        }

        stage('Deploy to AWS ECS') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Run OWASP ZAP Security Scan') {
            steps {
                sh 'zap-cli quick-scan --self-contained --api-key=your-key http://your-app-url'
            }
        }
    }
