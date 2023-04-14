pipeline {
    agent any

    stages {
        stage('Validation') {
            // Use Dev environment for validation
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-agent-aws-access-key')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-agent-aws-secret-key')
            }
            steps {
                sh 'terraform init -backend-config=environments/dev.backendconfig'
                sh 'terraform validate'
            }
        }

        stage('Dev') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-agent-aws-access-key')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-agent-aws-secret-key')
            }
            steps {
                sh 'terraform plan -out=tfplan -var-file=environments/dev.tfvars'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
