pipeline {
    agent any
    
    environment {
        SKIP_STAGE = true // I don't have a convenient stage environment that differs to test in
        SKIP_PROD = true // Ditto
    }

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

        stage('Approval - Stage') {
            steps {
                script {
                    input message: 'Proceed to the Stage environment?',
                    ok: 'Approve'
                }
            }
        }

        stage('Stage') {
            when {
                expression { 
                    return env.SKIP_STAGE != 'true'
                }
            }
            environment {
                // Same keys used here, but ideally would split them out
                AWS_ACCESS_KEY_ID = credentials('jenkins-agent-aws-access-key')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-agent-aws-secret-key')
            }
            steps {
                sh 'terraform init -backend-config=environments/stage.backendconfig'
                sh 'terraform plan -out=tfplan -var-file=environments/stage.tfvars'
                sh 'terraform apply tfplan'
            }
        }

        stage('Approval - Prod') {
            steps {
                script {
                    input message: 'Proceed to the Prod environment?',
                    ok: 'Approve'
                }
            }
        }

        stage('Prod') {
            when {
                expression { 
                    return env.SKIP_PROD != 'true'
                }
            }
            environment {
                // Same keys used here, but ideally would split them out
                AWS_ACCESS_KEY_ID = credentials('jenkins-agent-aws-access-key')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-agent-aws-secret-key')
            }
            steps {
                sh 'terraform init -backend-config=environments/prod.backendconfig'
                sh 'terraform plan -out=tfplan -var-file=environments/prod.tfvars'
                sh 'terraform apply -auto-approve tfplan'
            }
        }

    }
}
