variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type to use for the launch configuration"
}

variable "server_port" {
  type        = number
  default     = 80
  description = "Port on which the server will listen"
}

variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region where resources will be created"
}

variable "ami" {
  type        = string
  default     = "ami-07062e2a343acc423"
  description = "AMI for AWS EC2 instance (Ubuntu Server 24.04 LTS)"
}
