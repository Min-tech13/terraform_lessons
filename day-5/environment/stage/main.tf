#----------------------------------------------------------
# My Terraform
#
# Use Our Terraform Module to create AWS VPC Networks
#
# Made by Mintemir Kurbanaliev . January 20222
#----------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

module "vpc-default" {
  source = "../../modules/networking"

  
  env = "stage"
}

module "autoscaling" {
  source = "../../modules/autoscaling"
env = "stage"
instance_count1 = ["fd","dfd"]
vpc_id = module.vpc-default.vpc_id
subnet_ids = module.vpc-default.public_subnet_ids
}
