provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-igw"
  }
}

resource "aws_subnet" "example_public_a" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "example-public-a"
  }
}

resource "aws_subnet" "example_public_b" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "example-public-b"
  }
}

resource "aws_subnet" "example_public_c" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "example-public-c"
  }
}

resource "aws_route_table" "example_public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "example-public-rt"
  }
}

resource "aws_route_table_association" "example_public_a" {
  subnet_id      = aws_subnet.example_public_a.id
  route_table_id = aws_route_table.example_public.id
}

resource "aws_route_table_association" "example_public_b" {
  subnet_id      = aws_subnet.example_public_b.id
  route_table_id = aws_route_table.example_public.id
}

resource "aws_route_table_association" "example_public_c" {
  subnet_id      = aws_subnet.example_public_c.id
  route_table_id = aws_route_table.example_public.id
}

resource "aws_launch_template" "example" {
  image_id = "ami-0ff8a91507f77f867"
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > /var/www/html/index.html
  EOF
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id = aws_launch_template.example.id
  }

  min_size = 2
  max_size = 4
  desired_capacity = 2

  vpc_zone_identifier = aws_subnet.mintemir[count.index].id
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name            = "example-lb"
  internal        = false
  security_groups = [aws_security_group.example.id]
  subnets         = [aws_subnet.example_public_a.id, aws_subnet.example_public_b.id, aws_subnet.example_public_c.id]

  listener {
    lb_port           = "80"
    lb_protocol       = "http"
    instance_protocol = "http"
    instance_port     = "80"
  }

  health_check {
    target              = "HTTP:80/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}

resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_alb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_autoscaling_group.example.id
  port             = 80
}
