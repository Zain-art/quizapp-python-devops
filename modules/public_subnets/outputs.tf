output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

# output "cluster_name" {
#   value = var.cluster_name
# }