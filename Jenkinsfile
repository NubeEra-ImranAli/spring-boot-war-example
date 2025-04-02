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
        
         stage('Generate Inventory') {
            steps {
                script {
                    // Generate the inventory for all servers (build_server, tomcat_server, artifact_server)
                    sh """
                    // echo "[build_server]" > inventory
                    // echo "\$(terraform output -raw build_server_ip) ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_PRIVATE_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory


                    echo "[build_server]" > inventory
                     echo "\$(terraform output -raw build_server_ip) ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_PRIVATE_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory
 
                     echo "[tomcat_server]" >> inventory
                     echo "\$(terraform output -raw tomcat_server_ip) ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_PRIVATE_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory
 
                     echo "[artifact_server]" >> inventory
                     echo "\$(terraform output -raw artifact_server_ip) ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_PRIVATE_KEY_PATH} ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory
                    """
                }
            }
        }

        stage('Verify Ansible Connectivity') {
            steps {
                script {
                    // Get the IP addresses of the EC2 instances created by Terraform
                    def buildServerIp = sh(script: "terraform output -raw build_server_ip", returnStdout: true).trim()
                    def tomcatServerIp = sh(script: "terraform output -raw tomcat_server_ip", returnStdout: true).trim()
                    def artifactServerIp = sh(script: "terraform output -raw artifact_server_ip", returnStdout: true).trim()
        
                    // Define the servers and their IPs in a map
                    def servers = [
                        "build_server": buildServerIp,
                        "tomcat_server": tomcatServerIp,
                        "artifact_server": artifactServerIp
                    ]
        
                    // Check if all servers are up and reachable
                    def retries = 0
                    def maxRetries = 30 // Maximum number of retries (e.g., 30 attempts)
                    def waitTime = 10    // Wait time between retries (in seconds)
        
                    def reachableServers = [:]
                    servers.each { serverName, ip ->
                        reachableServers[serverName] = false
                    }
        
                    while (reachableServers.containsValue(false) && retries < maxRetries) {
                        servers.each { serverName, ip ->
                            if (!reachableServers[serverName]) {
                                // Ping the EC2 instance to check if it's available
                                def result = sh(script: "ping -c 1 -w 5 ${ip}", returnStatus: true)
                                
                                if (result == 0) {
                                    echo "${serverName} (${ip}) is reachable."
                                    reachableServers[serverName] = true
                                } else {
                                    echo "${serverName} (${ip}) is not reachable yet. Retrying."
                                }
                            }
                        }
        
                        if (reachableServers.containsValue(false)) {
                            retries++
                            echo "Attempt ${retries}/${maxRetries} failed. Waiting for all servers to be reachable."
                            sleep(waitTime)
                        }
                    }
        
                    if (reachableServers.containsValue(false)) {
                        error "Some EC2 instances are not reachable after ${maxRetries} attempts."
                    }
        
                    // Once all instances are reachable, run the Ansible ping
                    echo "All servers are reachable. Running Ansible Ping..."
                    sh """
                    ansible -i inventory all -m ping
                    """
                }
            }
        }

        // stage('Install Tomcat & Nexus') {
        //     steps {
        //         script {
        //             sh '''
        //             ansible-playbook -i inventory setup.yml
        //             '''
        //         }
        //     }
        // }

        // stage('Build Java Application') {
        //     steps {
        //         script {
        //             sh '''
        //             cd spring-boot-war-example
        //             mvn clean install
        //             '''
        //         }
        //     }
        // }

        // stage('Deploy Java Application') {
        //     steps {
        //         script {
        //             sh '''
        //             scp -i ~/.ssh/mujahed.pem spring-boot-war-example/target/*.war ubuntu@$(terraform output -raw tomcat_server_ip):/opt/apache-tomcat-9.0.99/webapps/
        //             '''
        //         }
        //     }
        // }
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
