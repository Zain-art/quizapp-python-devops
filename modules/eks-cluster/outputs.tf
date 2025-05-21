output "private_subnet_ids" {
  value = var.private_subnet_ids
}
output "public_subnet_ids" {
  value = var.public_subnet_ids
}

output "cluster_name" {
  value = var.cluster_name
}

# output "cluster_endpoint" {
#   value = aws_eks_cluster.this.endpoint
# }

# output "cluster_security_group_id" {
#   value = aws_security_group.eks_cluster_sg.id
# }

# output "node_group_name" {
#   value = aws_eks_node_group.this.node_group_name
# }
output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "eks_nodes_sg_id" {
  value = aws_security_group.eks_nodes.id
}