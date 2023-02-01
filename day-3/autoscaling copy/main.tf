provider "aws" {
  region = "us-east-2"
}



//SECURITY_GROUP
resource "aws_security_group" "r-security" {
  name        = "r-security"
  description = "Allow TLS inbound traffic"
   vpc_id      = data.terraform_remote_state.network.outputs.vpc_ids

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

data "aws_ami" "latest_ubuntu" {
 owners           = ["099720109477"]
 most_recent      = true
 filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230115*"]
  }
}

//LAUNCH_TEMPLATE
resource "aws_launch_template" "templete" {
  name = "mityas-template"
  image_id           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"

 network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.r-security.id}"]
  }
  
 
   tags = {
    Name = "mityas-templete11"

  }
user_data = base64encode("#!/bin/bash \n sudo su \n apt update -y \n apt install apache2 -y \n apt install wget -y \n apt install unzip -y \n systemctl enable apache2 \n systemctl start apache2  \n wget https://github.com/ra1mova/portfolio/archive/refs/heads/main.zip \n unzip main.zip \n A \n cd portfolio-main \n mv README.md css/ fetch.html image/ index.html js/ shop.html /var/www/html/ \nnohup python -m SimpleHTTPServer 80 &")
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id = aws_launch_template.templete.id
  }

  min_size = 2
  max_size = 4
  desired_capacity = 2

  vpc_zone_identifier = data.terraform_remote_state.network.outputs.subnet_ids
}
# //loadbalancer
resource "aws_lb" "mintemir" {
  name            = "mintemir-lb"
  internal        = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.r-security.id]
  subnets         = data.terraform_remote_state.network.outputs.subnet_ids
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
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_ids
}


data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../networking/terraform.tfstate"
  }
}