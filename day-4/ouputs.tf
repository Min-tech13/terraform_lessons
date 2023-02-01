

output "instance_ids" {
  value = {
    for k, v in aws_instance.day_4_instance: k => v.id
  }
}

#this chakes just bucket name id
output "resource_code" {
  value = random_string.bucket_name.*.id
}