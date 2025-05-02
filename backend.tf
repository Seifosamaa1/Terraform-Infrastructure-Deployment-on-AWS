terraform {
  backend "s3" {
    bucket         = "s3-bucket-t0-backend"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    #dynamodb_table = "terraform-lock"  
  }
}

