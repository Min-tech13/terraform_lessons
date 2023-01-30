data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../day-3/networking/terraform.tfstate"
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

data "terraform_remote_state" "target" {
  backend = "local"
  config = {
    path = "../day-3/autoscaling/terraform.tfstate"
  }
}