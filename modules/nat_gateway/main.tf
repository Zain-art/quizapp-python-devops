# ------------------------------
# Create NAT Gateways
# ------------------------------
# resource "aws_eip" "nat" {
#   count  = length(var.public_subnet_ids)
#   domain = "vpc"
#   tags = merge(var.default_tags, {
#     Name = var.nat_eip_names[count.index]
#   })
# }

# resource "aws_nat_gateway" "nat" {
#   count         = length(var.public_subnet_ids)
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = var.public_subnet_ids[count.index]

#   tags = merge(var.default_tags, {
#     Name = "nat-gateway-${count.index + 1}"
#   })
# }


resource "aws_eip" "nat" {
   count  = length(var.public_subnet_ids)
  domain = "vpc"

  tags = {
    Name = "${var.nat_eip_names[count.index]}-nat-quiz"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_ids)
 allocation_id = aws_eip.nat[count.index].id 
  subnet_id     = var.public_subnet_ids[count.index]

  tags = {
    Name = "${var.nat_eip_names[count.index]}-nat-quiz"
  }

  # depends_on = [aws_internet_gateway.igw]
}