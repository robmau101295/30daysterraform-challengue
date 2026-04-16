# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_credentials_files = ["C:/Users/Usuario/.aws/credentials"]
  profile = "terraform"
}

resource "aws_instance" "webserver" {
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "terraform-test"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              echo "Mi primer deploy en terraform!!" > /var/www/html/index.html
              systemctl enable apache2
              systemctl start apache2
              EOF

  user_data_replace_on_change = true
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
