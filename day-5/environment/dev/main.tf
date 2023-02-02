#----------------------------------------------------------
# My Terraform
#
# Use Our Terraform Module to create AWS VPC Networks
#
# Made Mintemir. Summer 2019
#----------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

module "vpc-default" {
  source = "../../modules/networking"

  
  
}


module "autoscaling-default" {
  source = "../../modules/autoscaling"
  vpc_id     =  module.vpc-default.vpc_id
  subnet_ids  =  module.vpc-default.public_subnet_ids
  env = stage
  
}

#====================================================
# output "vpc_id" {
#   value = module.vpc-default.vpc_id

# }

# output "public_subnet_ids" {
#   value = module.vpc-default.public_subnet_ids
# }


