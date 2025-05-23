# ------------------------------
# Create VPC
# ------------------------------
resource "aws_vpc" "my_vpc_eks" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.vpc_tag
}