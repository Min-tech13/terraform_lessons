provider "aws" {
  region = "us-east-1"
}



locals {
    azs = ["us-east-1a","us-east-1b","us-east-1c",]
}

//VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-roza"
  }
}

//SUBNET
resource "aws_subnet" "mintemir" {
  count = 3
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = local.azs[count.index]

  tags = {
    Name = "mitya${count.index}"
  }
}

//INTERNET_GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "mitya-gw"
  }
}

//ROUTE_TABLE
resource "aws_route_table" "route" {
count = 3
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "mitya-route${count.index}"
  }
}

//route_table_association
resource "aws_route_table_association" "a" {
    count = 3
  subnet_id      = aws_subnet.mintemir.*.id[count.index]
  route_table_id = aws_route_table.route.*.id[count.index]
}
//security group
resource "aws_security_group" "r-security" {
  name        = "r-security"
  description = "Allow TLS inbound traffic"
   vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

//LAUNCH_TEMPLATE
resource "aws_launch_template" "templete" {
  name = "mityas-template"
  image_id           = "ami-00874d747dde814fa"
  instance_type = "t2.micro"

 network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.r-security.id}"]
  }
  
 
   tags = {
    Name = "mityas-templete"

  }
user_data = base64encode("#!/bin/bash \n sudo su \n apt update -y \n apt install apache2 -y \n systemctl enable apache2 \n systemctl start apache2   \n echo Hello World! > /var/www/html/ \nnohup python -m SimpleHTTPServer 80 &")
}

//auto scaling group
resource "aws_autoscaling_group" "example" {
  launch_template {
    id = aws_launch_template.templete.id
  }

  min_size = 2
  max_size = 4
  desired_capacity = 2

  vpc_zone_identifier = aws_subnet.mintemir.*.id
  target_group_arns = [aws_lb_target_group.target.arn]
}

# //loadbalancer
resource "aws_lb" "mintemir" {
  name            = "mintemir-lb"
  internal        = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.r-security.id]
  subnets         = aws_subnet.mintemir.*.id
}
//listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.mintemir.arn
  port              = "80"
  protocol          = "HTTP"

    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}
//target group
resource "aws_lb_target_group" "target" {
  name     = "target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

}

terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "TERRAFORM/new/terraform.tfstate"
    region = "us-east-1"
  }
}