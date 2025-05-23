locals {
 
vpc_id                     = "vpc-0e73f751ccb452cd2"
private_subnet_ids         = ["subnet-0b0e26d730f36962c", "subnet-047b57447d684e83c"]
public_subnet_ids          = ["subnet-03edefbca6e6dfd4e", "subnet-078cffd6ff2b1cace"]
vpc_tag = tomap({
  "name" = "quiz-vpc-eks"
})
 env                  = "dev"
  region               = "us-east-1"
  

   cluster_name         = "final-eks-cluster"
  eks_version      = "1.31"
  name_vpc             = "quiz-vpc"
}