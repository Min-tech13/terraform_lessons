//this is outputs
#
#
#
#
#
#
#___________________________________

# data "aws_ami" "latest_ubuntu" {
#  owners           = ["099720109477"]
#  most_recent      = true
#  filter {
#     name   = "name"
#     values = ["amazon/ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }
# }
output target_id{
value = aws_lb_target_group.target.arn
}