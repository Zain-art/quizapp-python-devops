resource "aws_efs_file_system" "efs" {
  creation_token = "eks-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "eks-efs"
  }
}

# Create a security group for EFS
# resource "aws_security_group" "efs_sg" {
#   name        = "efs-sg"
#   description = "Allow NFS inbound from EKS nodes"
#   vpc_id      = var.vpc_id

#   ingress {
#     protocol    = "tcp"
#     from_port   = 2049
#     to_port     = 2049
#     security_groups = [var.eks_node_security_group_id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "efs-sg"
#   }
# }

# Mount targets in each subnet (usually private subnets where EKS nodes run)
resource "aws_efs_mount_target" "efs_mount_targets" {
  for_each = toset(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_iam_policy" "efs_csi_policy_quiz" {
  name        = "AmazonEKS_EFS_CSI_Driver_Policy-quiz"
  description = "Policy for EFS CSI driver to manage EFS file system"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint",
        "elasticfilesystem:DeleteAccessPoint"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "efs_csi_driver_role" {
  name = "EFS_CSI_Driver_Role-quiz"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "efs_csi_attach" {
  policy_arn = aws_iam_policy.efs_csi_policy_quiz.arn
  role       = aws_iam_role.efs_csi_driver_role.name
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # or use your cluster config
  }
}

# resource "helm_release" "efs_csi_driver" {
#   name       = "aws-efs-csi-drive-quiz"
#   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#   chart      = "aws-efs-csi-driver"
#   version    = "3.0.3"

#   # Optionally set service account role ARN for IRSA
#   set {
#     name  = "controller.serviceAccount.create"
#     value = "true"
#   }
# #   If you want to associate your IAM Role:
#   set {
#     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.efs_csi_driver_role.arn
#   }
# }


# resource "aws_cloudwatch_log_group" "this" {
#   name = "/aws/eks/zain-eks-cluster/cluster"

#   retention_in_days = 7

#   lifecycle {
#     prevent_destroy = false
#     ignore_changes = [name]
#   }
# }




# # resource "aws_security_group" "efs_sg" {
# #   name        = var.efs_security_group_name
# #   description = "Allow NFS"
# #   vpc_id      = var.vpc_id

# #   ingress {
# #     from_port   = 2049
# #     to_port     = 2049
# #     protocol    = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"] # Or restrict to your VPC CIDR block
# #   }

# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   tags = {
# #     Name = "efs-sg"
# #   }
# # }

# # resource "aws_efs_file_system" "efs" {
# #   creation_token = "eks-efs-devlast-eks"
# #   tags = {
# #     Name = "eks-efs-devlast-eks-cluster"
# #   }
# # }

# # resource "aws_efs_mount_target" "efs_mount" {
# #   count          = length(var.private_subnet_ids)
# #   file_system_id = aws_efs_file_system.efs.id
# #   subnet_id      = var.private_subnet_ids[count.index]
# #   security_groups = [aws_security_group.efs_sg.id]
# # }
# # ##########################################
# # # EFS CSI DRIVER ROLE 
# # ##################################


# resource "aws_iam_role" "efs_csi_role" {
#   name               = "AmazonEKS_EFS_CSI_DriverRole"
#   assume_role_policy = data.aws_iam_policy_document.efs_csi_assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "efs_csi_policy_attach" {
#   role       = aws_iam_role.efs_csi_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
# }

# # #######################################
# # # Install EFS using Helm 
# # ###################################

# # provider "helm" {
# #   kubernetes {
# #     config_path = "~/.kube/config"
# #   }
# # }

# # resource "helm_release" "efs_csi_driver" {
# #   name       = "aws-efs-csi-driver"
# #   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
# #   chart      = "aws-efs-csi-driver"
# #   namespace  = "kube-system"
# #   version    = "3.0.0" # or latest stable

# #   set {
# #     name  = "controller.serviceAccount.create"
# #     value = "true"
# #   }

# #   set {
# #     name  = "controller.serviceAccount.name"
# #     value = "efs-csi-controller-sa"
# #   }

# #   set {
# #     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
# #     value = aws_iam_role.efs_csi_role.arn
# #   }
# #   depends_on = [
# #     aws_iam_role.efs_csi_role,
# #     aws_iam_role_policy_attachment.efs_csi_policy_attach
# #   ]
# # }
# # ###############################
# # # Main.tf of efs 
# # ##########################
# # provider "aws" {
# #   region = var.region
# # }

# # data "aws_caller_identity" "current" {}

# # module "efs" {
# #   source = "./efs"
# #   # Include all required inputs from your existing setup
# # }

# # # resource "aws_efs_file_system" "eks" {
# # #   creation_token = "eks"

# # #   performance_mode = "generalPurpose"
# # #   throughput_mode  = "bursting"
# # #   encrypted        = true

# # #   # lifecycle_policy {
# # #   #   transition_to_ia = "AFTER_30_DAYS"
# # #   # }
# # # }

# # # resource "aws_efs_mount_target" "private_subnet_1" {
# # #   file_system_id  = aws_efs_file_system.eks.id
# # #   subnet_id        = var.private_subnet_ids[0]
# # #   security_groups = [var.eks_node_sg_id]
# # # }

# # # resource "aws_efs_mount_target" "private_subnet_2" {
# # #   file_system_id  = aws_efs_file_system.eks.id
# # #   subnet_id       = var.private_subnet_ids[1]
# # #   security_groups = [var.eks_node_sg_id]
# # # }

# # # data "aws_iam_policy_document" "efs_csi_driver" {
# # #   statement {
# # #     actions = ["sts:AssumeRoleWithWebIdentity"]
# # #     effect  = "Allow"

# # #     condition {
# # #       test     = "StringEquals"
# # #       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
# # #       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
# # #     }

# # #     principals {
# # #       identifiers = [aws_iam_openid_connect_provider.eks.arn]
# # #       type        = "Federated"
# # #     }
# # #   }
# # # }

# # # resource "aws_iam_role" "efs_csi_driver" {
# # #   name               = "${aws_eks_cluster.eks.name}-efs-csi-driver"
# # #   assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json
# # # }

# # # resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
# # #   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
# # #   role       = aws_iam_role.efs_csi_driver.name
# # # }

# # # resource "helm_release" "efs_csi_driver" {
# # #   name = "aws-efs-csi-driver"

# # #   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
# # #   chart      = "aws-efs-csi-driver"
# # #   namespace  = "kube-system"
# # #   version    = "3.0.3"

# # #   set {
# # #     name  = "controller.serviceAccount.name"
# # #     value = "efs-csi-controller-sa"
# # #   }

# # #   set {
# # #     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
# # #     value = aws_iam_role.efs_csi_driver.arn
# # #   }

# # #   depends_on = [
# # #     aws_efs_mount_target.private_subnet_1,
# # #     aws_efs_mount_target.private_subnet_2
# # #   ]
# # # }

# # # # Optional since we already init helm provider (just to make it self contained)
# # # data "aws_eks_cluster" "eks_v2" {
# # #   name = aws_eks_cluster.eks.name
# # # }

# # # # Optional since we already init helm provider (just to make it self contained)
# # # data "aws_eks_cluster_auth" "eks_v2" {
# # #   name = aws_eks_cluster.eks.name
# # # }

# # # provider "kubernetes" {
# # #   host                   = data.aws_eks_cluster.eks_v2.endpoint
# # #   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_v2.certificate_authority[0].data)
# # #   token                  = data.aws_eks_cluster_auth.eks_v2.token
# # # }

# # # resource "kubernetes_storage_class_v1" "efs" {
# # #   metadata {
# # #     name = "efs-devlast-quiz"
# # #   }

# # #   storage_provisioner = "efs.csi.aws.com"

# # #   parameters = {
# # #     provisioningMode = "efs-ap"
# # #     fileSystemId     = aws_efs_file_system.eks.id
# # #     directoryPerms   = "700"
# # #   }

# # #   mount_options = ["iam"]

# # #   depends_on = [helm_release.efs_csi_driver]
# # # }

# provider "aws" {
#   region = var.region
# }

# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }
# data "aws_iam_policy_document" "efs_csi_assume_role" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     principals {
#       type        = "Federated"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
#     }
#   }
# }

# resource "aws_iam_role" "efs_csi_role" {
#   name               = "AmazonEKS_EFS_CSI_DriverRole-devlast-eks"
#   assume_role_policy = data.aws_iam_policy_document.efs_csi_assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "efs_csi_policy_attach" {
#   role       = aws_iam_role.efs_csi_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
# }
# data "aws_caller_identity" "current" {}

# # ---------------------------------------------
# # Step 1: EFS Security Group
# # ---------------------------------------------


# # ---------------------------------------------
# # Step 2: Create the EFS File System
# # ---------------------------------------------
# resource "aws_efs_file_system" "efs" {
#   creation_token = "eks-efs"
#   tags = {
#     Name = "eks-efs"
#   }
# }

# # ---------------------------------------------
# # Step 3: Create EFS Mount Targets in All Private Subnets
# # ---------------------------------------------
# resource "aws_efs_mount_target" "efs_mount" {
#   count           = length(var.private_subnet_ids)
#   file_system_id  = aws_efs_file_system.efs.id
#   subnet_id       = var.private_subnet_ids[count.index]
#   security_groups = [aws_security_group.efs_sg.id]
# }

# # ---------------------------------------------
# # Step 4: Create IAM Role for EFS CSI Driver
# # ---------------------------------------------
# data "aws_iam_policy_document" "efs_csi_assume_role" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     principals {
#       type        = "Federated"
#       identifiers = [
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer_url, "https://", "")}"
#       ]
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
#     }
#   }
# }



# # ---------------------------------------------
# # Step 5: Install EFS CSI Driver using Helm
# # ---------------------------------------------
# resource "helm_release" "efs_csi_driver" {
#   name       = "aws-efs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#   chart      = "aws-efs-csi-driver"
#   namespace  = "kube-system"
#   version    = "2.2.0"   # <-- chart version, NOT helm CLI version

#   timeout    = 600       # 10 minutes timeout

#   set {
#     name  = "controller.serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "controller.serviceAccount.name"
#     value = "efs-csi-controller-sa"
#   }

#   set {
#     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.efs_csi_role.arn
#   }

#   depends_on = [
#     aws_iam_role.efs_csi_role,
#     aws_iam_role_policy_attachment.efs_csi_policy_attach
#   ]
# }


