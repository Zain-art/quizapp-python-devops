# ------------------------------
# Public Route Table
# ------------------------------
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

 route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = merge(var.default_tags, {
    Name = "public-route-table-quiz"
  })
 
  

  
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# ------------------------------
# Private Route Tables with NAT
# ------------------------------
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_ids)
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[count.index]
  }

  tags = merge(var.default_tags, {
    Name = "private-route-table-quiz-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id
}
