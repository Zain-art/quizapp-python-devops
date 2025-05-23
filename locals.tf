# ------------------------------
# Reusable Local Values
# ------------------------------


locals {
  env                  = "dev1"
  region               = "us-east-1"
  
  vpc_cidr_block       = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.7.0/24", "10.0.8.0/24"]
  private_subnet_cidrs = ["10.0.17.0/24", "10.0.18.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  cluster_name         = "final-eks-cluster"
  eks_version          = "1.31"
  name_vpc             = "final-vpc"
  nat_eip_names = [
    "nat-eip-vpc-1-final",
    "nat-eip-vpc-2-final"

  ]
  my_vpc_name = {
    name = "final-vpc"
  }
  # Environment = "dev1"
  ManagedBy = "Terraform1"

  default_tags = {
    name_vpc    = "final-vpc"
    Project     = "quizapp-flask"
    Environment = "dev1"
    ManagedBy   = "Terraform"
  }

  vpc_id = "vpc-053fc19cb7e5c3bd4"
  # vpc_id             = "vpc-053fc19cb7e5c3bd4"
  private_subnet_ids = ["subnet-031ac6c50171a6528", "subnet-00780688da342dfe4"]
  public_subnet_ids  = ["subnet-06a6ad10916484449", "subnet-013c330a7ccd02e61"]

}

