provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

resource "aws_instance" "ec2example" {
  ami           = "ami-04b70fa74e45c3917" # Replace with an appropriate AMI ID for your region
  instance_type = "t2.micro"

  # User data to configure the instance at launch
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "ExampleInstance"
  }
}

output "instance_ip" {
  value = aws_instance.ec2example.public_ip
}

