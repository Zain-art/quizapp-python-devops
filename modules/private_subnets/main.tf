# ------------------------------
# Create Private Subnets + Route Tables
# ------------------------------
resource "aws_subnet" "private" {
  count             = length(var.subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.default_tags, {
    Name = "private-sb-final-${count.index + 1}"
     "kubernetes.io/role/internal-elb"                      = 1
    "kubernetes.io/cluster/final-eks-cluster" = "shared"
  })
   lifecycle {
    create_before_destroy = true
  }
  
} 

# resource "aws_route_table" "private" {
#   count  = length(var.nat_gateway_ids)
#   vpc_id = var.vpc_id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = var.nat_gateway_ids[count.index]
#   }

#   tags = merge(var.default_tags, {
#     Name = "private-rt-${count.index + 1}"
#   })
# }

# resource "aws_route_table_association" "private" {
#   count          = length(var.nat_gateway_ids)
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private[count.index].id
# }
