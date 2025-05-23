# ------------------------------
# Create NAT Gateways
# ------------------------------


resource "aws_eip" "nat" {
   count  = length(var.public_subnet_ids)
  domain = "vpc"

  tags = {
    Name = "${var.nat_eip_names[count.index]}-nat-final"
  }
   lifecycle {
    create_before_destroy = true
  }
  
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_ids)
 allocation_id = aws_eip.nat[count.index].id 
  subnet_id     = var.public_subnet_ids[count.index]

  tags = {
    Name = "${var.nat_eip_names[count.index]}-nat-final"
  }
 lifecycle {
    create_before_destroy = true
  }
  
  
}