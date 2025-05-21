output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "cluster_name" {
  value = var.cluster_name
}