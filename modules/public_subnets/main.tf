# ------------------------------
# Create Public Subnets
# ------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = var.vpc_id 
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.default_tags, {
    Name = "public-sb-final-${count.index + 1}"
     "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/final-eks-cluster" = "shared"
  })
   lifecycle {
    create_before_destroy = true
  }
}