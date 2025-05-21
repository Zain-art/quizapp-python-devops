# terraform {
#   backend "s3" {
#     region = "us-east-1"
#     bucket = "eks-k8s-tf-backed"
#     key = "network-module/terraform.tfstate"
#   }
# }
terraform {
  backend "s3" {
    bucket         = "zain-terraform-backend"
    key            = "vpc/terraform.tfstate-vpc"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-vpc"
    encrypt        = true
  }
}

# terraform {
#   backend "s3" {
#     bucket         = "zain-terraform-backend"
#     key            = "vpc/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
# create-s3-dynamodb.tf
# resource "aws_s3_bucket" "tf_state" {
#   bucket = "zain-terraform-backend"
#   force_destroy = true
# }

# resource "aws_dynamodb_table" "tf_locks" {
#   name         = "terraform-locks-vpc"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }