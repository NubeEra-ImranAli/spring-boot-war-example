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
        
        stage('Generate Ansible Inventory') {
            steps {
                script {
                    sh '''
                    
                    echo "[build_server]" > inventory
                    echo "$(terraform output -raw build_server_ip) ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/mujahed.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory

                    echo "[tomcat_server]" >> inventory
                    echo "$(terraform output -raw tomcat_server_ip) ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/mujahed.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory

                    echo "[artifact_server]" >> inventory
                    echo "$(terraform output -raw artifact_server_ip) ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/mujahed.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory
                    '''
                }
            }
        }

        stage('Verify Ansible Connectivity') {
            steps {
                script {
                    sh '''
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
