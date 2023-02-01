resource "aws_instance" "day_4_instance" {
  for_each          =  toset(data.terraform_remote_state.network.outputs.subnet_ids)

  subnet_id         =  each.key#data.terraform_remote_state.network.outputs.subnet_ids
  ami               =  data.aws_ami.latest_ubuntu.id
  instance_type     =  var.instance_type 

  


}



resource "aws_lb_target_group" "target" {
  name     = "target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_ids
}
#attaching target group to vm 
#Attach them to target group using aws_lb_target_group_attachment resource
resource "aws_lb_target_group_attachment" "tg_vm" {
  for_each         = aws_instance.day_4_instance
  target_group_arn = aws_lb_target_group.target.arn
  target_id        = each.value.id
  port             = 80


}

