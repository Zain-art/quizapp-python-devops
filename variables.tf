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
  type    = string
 
}
# variable "eks_node_security_group_id" {
#   type    = string
#   default = "sg-020ab41ad49f3e243"
# }

