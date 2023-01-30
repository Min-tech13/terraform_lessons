output subnet_ids {
  value = aws_subnet.mintemir.*.id
}

output "vpc_ids" {
  value = aws_vpc.vpc.id
}