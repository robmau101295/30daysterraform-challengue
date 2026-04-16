provider "aws" {
  region = "us-east-2"
  shared_credentials_files = ["C:/Users/Usuario/.aws/credentials"]
  profile = "terraform"
}

resource "aws_security_group" "tf-sg" {
  name = "tf-sg"
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


resource "aws_launch_template" "tf-ws-template" {
    name = "tf-ws-template"
    image_id = "ami-0fb653ca2d3203ac1" 
    instance_type = var.instance_type
    
    vpc_security_group_ids = [aws_security_group.tf-sg.id]
    
      user_data = base64encode(<<-EOF
                                #!/bin/bash
                                echo "Hello, World" > index.html
                                nohup busybox httpd -f -p ${var.server_port} &
                                EOF
                                )
    lifecycle {
        create_before_destroy = true
    }

    tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "terraform-webserver"
      Env  = "lab"
    }
  }
}

resource "aws_autoscaling_group" "webservers" {
    name = "terraform-webservers"
    max_size = 10
    min_size = 2
    desired_capacity = 2
    launch_template {
    id      = aws_launch_template.tf-ws-template.id
    version = "$Latest"
    }   
    vpc_zone_identifier = data.aws_subnets.default.ids
    
    target_group_arns = [aws_lb_target_group.alb-tg-ws.arn]
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "tf-webserver"
        propagate_at_launch = true
    }
}

###LOAD BALANCER
resource "aws_lb" "alb-ws" {
  name               = "alb-ws"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups     = [aws_security_group.tf-sg.id]
}

resource "aws_lb_listener" "alb-listener-ws" {
  load_balancer_arn = aws_lb.alb-ws.arn
  port              = var.server_port
  protocol          = "HTTP"

 # By default, return a simple 404 page
 default_action {
    type = "fixed-response"
    fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code = 404
    }
 }
}

resource "aws_lb_target_group" "alb-tg-ws" {
  name     = "alb-tg-ws"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "alb-listener-rule-ws" {
 listener_arn = aws_lb_listener.alb-listener-ws.arn
 priority = 100
 condition {
    path_pattern {
        values = ["*"]
    }
 }
 action {
 type = "forward"
 target_group_arn = aws_lb_target_group.alb-tg-ws.arn
 }
}


#### DATA SOURCES

data "aws_vpc" "default" {
 default = true
}

data "aws_subnets" "default" {
 filter {
 name = "vpc-id"
 values = [data.aws_vpc.default.id]
 }
}

##OUTPUTS

output "alb_dns_name" {
 value = aws_lb.alb-ws.dns_name
 description = "The domain name of the load balancer"
}
