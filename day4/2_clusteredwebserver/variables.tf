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