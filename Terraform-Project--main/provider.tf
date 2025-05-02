terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "5.36.0"
}
}
}

provider "aws" {
region = "us-east-1"
access_key = "xxxxxxxxxxxxxxxxxxx"
secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}