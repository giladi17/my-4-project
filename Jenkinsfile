pipeline {
    agent any

    environment {
        APP_SERVER_IP = '34.204.37.170'
        AWS_REGION = 'us-east-1'
        // החלף את הכתובת למטה בכתובת ה-ECR שהודפסה לך מ-Terraform!
        ECR_URL = '066380525112.dkr.ecr.us-east-1.amazonaws.com/devops-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Lint Check') {
            steps {
                dir('app') {
                    sh 'pip3 install flake8'
                    sh 'python3 -m flake8 app.py'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                dir('app') {
                    sh 'pip3 install -r requirements.txt'
                    sh 'python3 -m pytest test_app.py'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh "docker build -t ${ECR_URL}:latest ."
                }
            }
        }

        stage('Push to ECR (Bonus)') {
            steps {
                // התחברות ל-AWS בעזרת פרטי ההזדהות שנכניס לג'נקינס
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    // התחברות ל-ECR ודחיפת התמונה
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                    sh "docker push ${ECR_URL}:latest"
                }
            }
        }

        stage('Deploy (CD)') {
            steps {
                sshagent(credentials: ['app-server-ssh-key']) {
                    // הוספנו כאן את פקודת ההתחברות ל-ECR גם לשרת ה-App כדי שיוכל למשוך את התמונה
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds'
                    ]]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER_IP} "
                            sudo apt update -y && sudo apt install docker.io awscli -y || true
                            AWS_ACCESS_KEY_ID='${AWS_ACCESS_KEY_ID}' AWS_SECRET_ACCESS_KEY='${AWS_SECRET_ACCESS_KEY}' aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${ECR_URL}
                            sudo docker pull ${ECR_URL}:latest
                            sudo docker stop devops-app || true
                            sudo docker rm devops-app || true
                            sudo docker run -d -p 5000:5000 --name devops-app ${ECR_URL}:latest
                            "
                        """
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                sh "sleep 10"
                sh "curl -f http://${APP_SERVER_IP}:5000/ || exit 1"
            }
        }
    }
}