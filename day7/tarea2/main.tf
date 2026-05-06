provider "aws" {
  region = "us-east-2"
  shared_credentials_files = ["C:/Users/Usuario/.aws/credentials"]
  profile = "terraform"
}

variable "instance_type" {
  description = "EC2 instance type per environment"
  type        = map(string)
  default = {
    dev        = "t2.micro"
    staging    = "t2.small"
    production = "t2.medium"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type[terraform.workspace]

  tags = {
    Name        = "web-${terraform.workspace}"
    Environment = terraform.workspace
  }
}