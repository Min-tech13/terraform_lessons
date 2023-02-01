#______________________________________
#
#
#
#varaible for instance type


# instance_type = "t2-micro"
variable "instance_type" {
  default     = "t2.micro"

}

variable "bucket_count" {
  type    = number
  default = 4
}