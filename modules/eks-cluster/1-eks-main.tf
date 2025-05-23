resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}




# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "20.36.0"

#   cluster_name    = "zain-eks-cluster"
#   cluster_version = "1.30"
#   vpc_id          = var.vpc_id
#   subnet_ids      = var.private_subnet_ids

#   cluster_endpoint_public_access = true

#   iam_role_arn = aws_iam_role.eks_cluster_role.arn
# cluster_addons = {
#     coredns = {
#       most_recent = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#     vpc-cni = {
#       most_recent = true
#     }
#      aws-efs-csi-driver = {
#     most_recent = true
#   }
#   }
#   eks_managed_node_groups = {
#     spot_nodes = {
#       desired_size   = 2
#       min_size       = 2
#       max_size       = 4
#       instance_types = ["t3.medium", "t3.medium"]
#       capacity_type  = "SPOT"
#       subnets        = var.private_subnet_ids
#       node_role_arn  = aws_iam_role.eks_node_role.arn
#       security_groups = [aws_security_group.eks_nodes.id]
#     }
#   }

 
#   access_entries = {
#     eks_user_access = {
#       principal_arn = "arn:aws:iam::241533146625:user/eks-user-terraform"
#       type          = "STANDARD"
     
#    policy_associations = {
#       admin = {
#         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#         access_scope = {
#           type = "cluster"
#         }
#       }
#     }
#     }
#   }

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }

