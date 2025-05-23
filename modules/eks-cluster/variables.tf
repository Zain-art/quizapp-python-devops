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



variable "eks_node_security_group_id" {
  type = string
}
