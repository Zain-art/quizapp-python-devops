# ------------------------------
# Input Variables
# ------------------------------
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}
variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}
variable "cluster_name" {
  type = string
  default = "quiz-eks-cluster"
}
variable "eks_node_security_group_id" {
  type = string
  default = "sg-020ab41ad49f3e243"
}

# variable "defaultva_tags" {
#   type = map(string)
# }
# variable "node_role_arn" {
#   description = "ARN of the existing EKS node IAM role"
#   type        = string
# }
# variable "cluster_role_arn" {
#   description = "ARN of the existing EKS node IAM role"
#   type        = string
# }
# variable "vpc_cidr_block" {
#   description = "this is cird block of vpc"
#   type        = string
# }

# variable "cluster_oidc_issuer_url" {}
# # variable "efs_security_group_name" {
# #   default = "efs-sg-devlast-eks-clustet"
# # }

# variable "eks_node_sg_id" {
#   type = string
# }
