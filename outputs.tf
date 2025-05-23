# ------------------------------
# Output Values
# ------------------------------
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.public_subnets.public_subnet_ids
}

output "private_subnets" {
  value = module.private_subnets.private_subnet_ids
}
output "nat_gateway_ids" {
  value = module.nat_gateway.nat_gateway_ids

}
output "igw_eks" {
  value = module.internet_gateway.igw_eks
}
output "vpc_tag" {
  value = module.vpc.vpc_tag
}
output "cluster_name" {
  value = var.cluster_name
}
# output "efs_sg_id" {
#   value = module.eks_cluster.efs_sg_id
# }
# output "cluster_role_arn" {
#   value = module.eks_cluster.eks_cluster_role_arn
# }

# output "node_role_arn" {
#   value = module.eks_cluster.eks_node_role_arn
# }

# output "node_sg_id" {
#   value = module.eks_cluster.eks_nodes_sg_id
# }