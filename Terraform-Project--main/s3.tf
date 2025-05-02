resource "aws_s3_bucket" "s3_backend" {
  bucket = "s3-bucket-t0-backend"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}