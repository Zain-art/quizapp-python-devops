resource "aws_security_group" "eks_cluster" {
  name        = "${local.cluster_name}-sg-quiz-eks"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = merge({
    Name                                      = "quiz-eks-cluster"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  })
}

resource "aws_security_group" "eks_nodes" {
  name        = "eks-nodes-sg-quiz-eks"
  description = "EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "quiz-eks-nodes-sg"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}
# resource "aws_security_group" "eks_cluster_sg" {
#   name        = "${var.cluster_name}-sg-quiz"
#   description = "EKS cluster security group"
#   vpc_id      = var.vpc_id

#   # Example inbound rule for worker nodes
#   ingress {
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = var.eks_node_sg_id != "" ? [var.eks_node_sg_id] : []
#     description     = "Allow worker nodes to communicate with cluster"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#     tags = merge({
#     Name                                      = "quiz-eks-cluster"
#     "kubernetes.io/role/internal-elb"        = "1"
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#   })
# }
# 📡 Allow control plane to communicate with worker nodes
resource "aws_security_group_rule" "control_plane_to_nodes_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "EKS control plane to node group"
}

# 🔁 Allow nodes to communicate with each other
resource "aws_security_group_rule" "node_to_node_all" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Node to node communication"
}

# 🌐 Allow internet access (for pulling container images, updates, etc.)
resource "aws_security_group_rule" "node_allow_https_out" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow HTTPS egress"
}

# 🧪 Optional: Allow SSH to nodes (for debugging)
resource "aws_security_group_rule" "ssh_access_to_nodes" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["154.192.0.41/32"]  # Replace with your IP if needed
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow SSH from your IP"
}

# 🌍 Allow outbound from nodes to internet
resource "aws_security_group_rule" "all_outbound_from_nodes" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow all outbound traffic"
}

# resource "aws_security_group" "efs_sg" {
#   name        = var.efs_security_group_name
#   description = "Allow NFS"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 2049
#     to_port     = 2049
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Replace with your VPC CIDR like ["10.0.0.0/16"]
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
resource "aws_security_group" "efs_sg" {
  name   = "efs-sg-devlast"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks       = ["10.0.0.0/8"]
#   security_group_id = aws_security_group.eks_nodes.id
    security_groups = [aws_security_group.eks_nodes.id] # Allow from workder nodes
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "efs-sg-devlast-eks-efs"
  }
}
# resource "aws_security_group_rule" "allow_elb_to_nodes_http" {
#   type                     = "ingress"
#   from_port                = 80
#   to_port                  = 80
#   protocol                 = "tcp"
# #   source_security_group_id = aws_security_group.elb_sg.id  # If you create or know ELB SG
#   security_group_id        = aws_security_group.eks_nodes.id
#   description              = "Allow ELB to nodes HTTP"
# }