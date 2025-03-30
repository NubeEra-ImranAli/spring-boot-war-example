provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "build_server" {
  ami           = "ami-084568db4383264d4"  # Ubuntu 20.04 AMI
  instance_type = "t2.micro"
  security_groups = ["sgalltraffic"]  # Reference the existing security group
  key_name      = "mujahed"
  tags = {
    Name = "Build-Server"
  }
}

output "build_server_ip" {
  value = aws_instance.build_server.public_ip
}
