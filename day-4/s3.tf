resource "aws_s3_bucket" "bucket_folder" {
  bucket = "bucket-folder"
}

resource "aws_s3_bucket" "random_buckets" {
  count = var.bucket_count == 4 ? var.bucket_count : 0

  bucket = "demo-${random_string.bucket_name[count.index].result}"

  versioning {
    enabled = true
  }
}

resource "random_string" "bucket_name" {
  count = var.bucket_count
  length  = 8
  special = false
  upper   = false
}




