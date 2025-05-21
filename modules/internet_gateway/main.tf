# ------------------------------
# Create Internet Gateway
# ------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags   = var.default_tags
}