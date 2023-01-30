# output instance_ids {
    
#     value = aws_instance.day_4_instance.*.id
# }

output "instance_ids" {
  value = {
    for k, v in aws_instance.day_4_instance: k => v.id
  }
}

# output "instance_ids" {
#   value = {
#     for instance in aws_instance.day_4_instance : instance.value.id => instance.value.id
#   }
# }
