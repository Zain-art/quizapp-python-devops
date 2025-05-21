locals {
 nat_gateway_ids = [
  "nat-099d5f3eb8d02a1a5",
  "nat-0999cbb2d756faadc",
]
vpc_cidr_block     = "10.0.0.0/16"
vpc_id             = "vpc-053fc19cb7e5c3bd4"
private_subnet_ids =  ["subnet-031ac6c50171a6528", "subnet-00780688da342dfe4"]
public_subnet_ids  = ["subnet-06a6ad10916484449", "subnet-013c330a7ccd02e61"]
vpc_tag = tomap({
  "name" = "quiz-vpc-eks"
})
 env                  = "dev"
  region               = "us-east-1"
  eks_name = "quiz-eks-cluster"
  # vpc_cidr_block       = "10.0.0.0/16"
   cluster_name         = "quiz-eks-cluster"
  eks_version      = "1.31"
  name_vpc             = "quiz-vpc"
}