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
        
        stage('Setup key') {
            steps {
                script {
                    sh '''
                    cat <<EOF > ~/.ssh/mujahed.pem
                    -----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAjf10NFvr/coJBYLvb5FjZm0TR6ENHbJImE3AP30ahWPkzNqO
beDyoynx5OyNHboR69ZacNgUAjIepaNKAzCo/k3fgOyZg045+iGNoUespKixJozU
OjY52oSU++rOWz+WGUROtr3AlhggSyGz92Gm8hWe/BAWlt7TUPmOymNt2KxiuvLU
mc1/nHRZwAqGwjDxzA1Tk/nBJKI2gBdq1jf34Tks0boYal3HpbFXgXSs+ODSXRTV
ZTpOuia41D432T72hzyiijHfq1HLU7jXoYEkMklbRwzDQJg+ShAIe2ruiXhZQmGo
vBvY+XowGQoRykbcITAP7c8qhb6a32Yc1M3ftwIDAQABAoIBAD96ZyAdVESytRPM
tKSJOAoLi4oDWyzCjqfgYqk/kcK+pQRcVT6USYVedDEm+/OlQuvPecFnKJLOu1rL
xIPmljaSs/AcVokYSN0lcP8AXxOCAyi73wljQrwJd92j3Lt4ku8a1aHm9RllEdLk
72MSOiOSPPBtdNvgJFLYLtkWWH577jZQT7d7dUNYp8Ugqq2ZiItqHoAU+7nqmOgx
l1p9LVBo/IbuilXRiQ/0iNRuPMAYqVsPVzZb1k9AINiTTMXdj66h809PmwUzDhSC
qu//00VXf15ilnQzVJIVWGk7xt7WkaG+Jb179xrA1bhT+jwoqVyGEsyDbOpiIA3R
XGrbC4ECgYEA4CT0rJaoK9ClSNqGkaQAHnWRtlgL2gHbLlYclG0AfccSZiDzhHwi
O9LTS1onV2hquHcXO9a+03XzlwqSnAEBdgQrqD/GISMPy3ZeqQkAhyh4SoxtJzmz
AuhR2B8FPV+l15R00EYiP859/hhSO37Q9aJHJbnwmFrg6fucl5G1M3cCgYEAoit6
ZQB4ecDnuOK3NGJDQqmqs4oHk0hu6m6eBeYLc07YPnk/kE0obfjcjiRAinwDEWqu
UnZQYd/c+rmZzrRIUq6eAptFCwEqqvvQOv9EJcdce8FypdCVxDLd8gXFozr81exz
4R93s5V1+XYFjV7S4VtBzHJA0gXTzhdMw7UFRcECgYEA1Z/DJd5sp12yuc2z5Yi1
qFILLwuZOAz+1ZmyoW+FwVqC2Z1cGg+pHPUg9jcVOcRFukuedCSGOMm5AGJOOqrm
tpDg/vjRH3HoMtU9AMOYojha9UoDGhhu2T2MC3v9JXJMgDt4XawKJl/qSsrpTNTf
2MvyHS2q9bnflIF+zCJN3Z8CgYAYv+30EDhSzKAQ1XkEY6LEP8SvlfdGAR38ZVl0
qQFCXdwe3L5YtY3gCsUOZHX9LKQDOnbUWv41kcbV9RGGPHl1NPUkjLHi1hC++6Nx
/ZdW9LAmqwVmTQkuYl0BHORm3w/LTkT5LKZGIB9bLSn3w2sHvbezDhTaeM00fNXY
YH4ngQKBgHD36HLJoho+raBtGylLJ0nRJxn8V34L8+/11cu3kCgSBTu+5gToHDvW
7eylIwzt1O1eia3AjVRyjGBlBL4hWgormfih2w2lFIZRSplrN5tdSR244FRRzAPR
sCyUEn7e5s7V9nBRF+PF77zECAoRaRhIBnSKfshSpVbKiDkatXeF
-----END RSA PRIVATE KEY-----
EOF
                    chmod 400 ~/.ssh/mujahed.pem
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
