pipeline {
    agent any
    
    tools {
        // Define tools with the names you set in Global Tool Configuration
        terraform 'ttff'  // This uses the tool with the name 'terraform'
        ansible 'aann'      // This uses the tool with the name 'ansible'
        maven 'mmvvnn'      // This uses the tool with the name 'maven'
    }
    environment {
        AWS_ACCESS_KEY = credentials('AWS_ACCESS')
        AWS_SECRET_KEY = credentials('AWS_SECRET')
        SSH_PRIVATE_KEY_PATH = "~/.ssh/mujahed.pem"  // Path to your private key
        BUILD_SERVER_IP = ''
        TOMCAT_SERVER_IP = ''
        ARTIFACT_SERVER_IP = ''
    }

    stages {
        stage('Checkout Repository') {
            steps {
                git branch: 'master', url: 'https://github.com/NubeEra-ImranAli/spring-boot-war-example.git'
            }
        }

        stage('Setup Terraform') {
            steps {
                script {
                    sh '''
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Fetch Terraform Outputs') {
            steps {
                script {
                    // Set environment variables with the outputs from Terraform
                    env.BUILD_SERVER_IP = sh(script: 'terraform output -raw build_server_ip', returnStdout: true).trim()
                    env.TOMCAT_SERVER_IP = sh(script: 'terraform output -raw tomcat_server_ip', returnStdout: true).trim()
                    env.ARTIFACT_SERVER_IP = sh(script: 'terraform output -raw artifact_server_ip', returnStdout: true).trim()
                    env.BUILD_SERVER_ID = sh(script: 'terraform output -raw build_server_id', returnStdout: true).trim()
                    env.TOMCAT_SERVER_ID = sh(script: 'terraform output -raw tomcat_server_id', returnStdout: true).trim()
                    env.ARTIFACT_SERVER_ID = sh(script: 'terraform output -raw artifact_server_id', returnStdout: true).trim()
                }
            }
        }
        
        stage('Wait for EC2 Instances to be Ready') {
            steps {
                script {
                    // Wait for the EC2 instances to be in a running state
                    def instanceIds = "${env.BUILD_SERVER_ID} ${env.TOMCAT_SERVER_ID} ${env.ARTIFACT_SERVER_ID}"
                    echo "Waiting for EC2 instances to be ready: ${instanceIds}"

                    sh """
                    aws ec2 wait instance-running --instance-ids ${instanceIds}
                    """
                }
            }
        }
        
         stage('Generate Inventory') {
            steps {
                script {
                    // Generate the inventory for all servers (build_server, tomcat_server, artifact_server) using environment variables
                    sh """
                    echo "[build_server]" > inventory
                    echo "${env.BUILD_SERVER_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_PRIVATE_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory

                    echo "[tomcat_server]" >> inventory
                    echo "${env.TOMCAT_SERVER_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_PRIVATE_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory

                    echo "[artifact_server]" >> inventory
                    echo "${env.ARTIFACT_SERVER_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_PRIVATE_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory
                    """
                }
            }
        }

        stage('Verify Ansible Connectivity') {
            steps {
                script {
                    sh '''
                    pwd
                    ansible -i inventory all -m ping
                    '''
                }
            }
        }

        stage('Install Tomcat & Nexus') {
            steps {
                script {
                    sh '''
                    ansible-playbook -i inventory setup.yml
                    '''
                }
            }
        }

        stage('Build Java Application') {
            steps {
                script {
                    sh '''
                    cd spring-boot-war-example
                    mvn clean install
                    '''
                }
            }
        }

        stage('Deploy Java Application') {
            steps {
                script {
                    sh '''
                    scp -i ~/.ssh/mujahed.pemspring-boot-war-example/target/*.war ubuntu@$(terraform output -raw tomcat_server_ip):/opt/apache-tomcat-9.0.99/webapps/
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment Successful!"
        }
        failure {
            echo "Deployment Failed!"
        }
    }
}
