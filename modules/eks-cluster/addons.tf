

# #######################################
# # ADD ONs in EKS CLuster 
# ######################################
# # data "aws_iam_policy_document" "vpc_cni_assume" {
# #   statement {
# #     actions = ["sts:AssumeRoleWithWebIdentity"]

# #     principals {
# #       type        = "Federated"
# #       identifiers = [aws_iam_openid_connect_provider.eks.arn]
# #     }

# #     condition {
# #       test     = "StringEquals"
# #       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
# #       values   = ["system:serviceaccount:kube-system:aws-node"]
# #     }
# #   }
# # }

# # resource "aws_iam_policy" "vpc_cni" {
# #   name = "AmazonEKS_CNI_Policy"
  
# #   policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect = "Allow"
# #         Action = [
# #           "ec2:AssignPrivateIpAddresses",
# #           "ec2:AttachNetworkInterface",
# #           "ec2:CreateNetworkInterface",
# #           "ec2:DeleteNetworkInterface",
# #           "ec2:DescribeInstances",
# #           "ec2:DescribeTags",
# #           "ec2:DescribeNetworkInterfaces",
# #           "ec2:DetachNetworkInterface",
# #           "ec2:ModifyNetworkInterfaceAttribute",
# #           "ec2:UnassignPrivateIpAddresses"
# #         ]
# #         Resource = "*"
# #       },
# #       {
# #         Effect = "Allow"
# #         Action = [
# #           "ec2:CreateTags"
# #         ]
# #         Resource = "arn:aws:ec2:*:*:network-interface/*"
# #         Condition = {
# #           StringEquals = {
# #             "ec2:CreateAction" = "CreateNetworkInterface"
# #           }
# #         }
# #       }
# #     ]
# #   })
# # }

# # resource "aws_iam_role" "vpc_cni_role" {
# #   name = "eks-vpc-cni-role"
# #   assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume.json
# # }

# # resource "aws_iam_role_policy_attachment" "vpc_cni_attach" {
# #   role       = aws_iam_role.vpc_cni_role.name
# #   policy_arn = aws_iam_policy.vpc_cni.arn
# # }



# # # VPC CNI Add-on
# # resource "aws_eks_addon" "vpc_cni" {
# #   cluster_name             = aws_eks_cluster.eks.name
# #   addon_name               = "vpc-cni"
# # #   addon_version            = "v1.19.5-eksbuild.1" # adjust version as needed
# #  resolve_conflicts_on_create = "OVERWRITE"
# #   service_account_role_arn = aws_iam_role.vpc_cni_role.arn
# #    lifecycle {
   
# #     ignore_changes  = [addon_version]
# #   }
# #   tags = {
# #   "eks.amazonaws.com/component" = "vpc-cni"
# #   "eks.amazonaws.com/role-type" = "addon"
# #   "Name" = "eks-vpc-cni-role"
# # }
# # }

# # CoreDNS Add-on
# resource "aws_eks_addon" "coredns" {
#   cluster_name      = aws_eks_cluster.eks.name
#   addon_name        = "coredns"
#   addon_version     = "v1.11.4-eksbuild.10"
#   resolve_conflicts_on_create = "OVERWRITE"
#    lifecycle {
    
#     ignore_changes  = [addon_version]
#   }
# }

# # kube-proxy Add-on
# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name      = aws_eks_cluster.eks.name
#   addon_name        = "kube-proxy"
#   addon_version     = "v1.31.7-eksbuild.7"
#   resolve_conflicts_on_create = "OVERWRITE"
#  lifecycle {
    
#     ignore_changes  = [addon_version]
#   }
# }

# resource "aws_eks_addon" "efs_csi_driver" {
#   cluster_name             = local.cluster_name
#   addon_name               = "aws-efs-csi-driver"
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update  = "OVERWRITE"
#   service_account_role_arn   = aws_iam_role.efs_csi_driver_role.arn 
# }

# # data "aws_iam_policy_document" "efs_csi_assume_role" {
# #   statement {
# #     actions = ["sts:AssumeRoleWithWebIdentity"]
# #     principals {
# #       type        = "Federated"
# #       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"]
# #     }
# #     condition {
# #       test     = "StringEquals"
# #       variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
# #       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
# #     }
# #   }
# # }

# # resource "aws_iam_role" "efs_csi_driver_role_devlast" {
# #   name               = "AmazonEKS_EFS_CSI_DriverRole-devlast-eks"
# #   assume_role_policy = data.aws_iam_policy_document.efs_csi_assume_role.json
# # }

# # resource "aws_iam_role_policy_attachment" "efs_csi_policy_attach" {
# #   role       = aws_iam_role.efs_csi_driver_role.name
# #   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
# # }