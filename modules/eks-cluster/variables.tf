variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}
variable "region" {
  default = "us-east-1"
  type = string
}
variable "vpc_id" {
  type        = string
  description = "VPC ID for the cluster"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

# variable "eks_role_arn" {
#   type        = string
#   description = "ARN of the IAM role for the EKS cluster"
# }


variable "eks_node_security_group_id" {
  type = string
}

# variable "eks_node_sg_id" {
#   type        = string
#   description = "Security group ID for EKS worker nodes"
#   default     = ""   # optional, can be empty string
# }

# variable "cluster_oidc_issuer_url" {
#   type        = string
#   description = "OIDC issuer URL for the cluster"
#   default     = ""   # optional, can be empty string
# }
