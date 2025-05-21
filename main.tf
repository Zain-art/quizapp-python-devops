# ------------------------------
# Root Module - Resource Calls
# ------------------------------

module "vpc" {
  source   = "./modules/vpc"
  # vpc_cidr = var.vpc_cidr_block
  vpc_tag  = local.my_vpc_name
}

module "internet_gateway" {
  source       = "./modules/internet_gateway"
  vpc_id       = module.vpc.vpc_id
  default_tags = local.default_tags
}

module "public_subnets" {
  source             = "./modules/public_subnets"
  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = local.public_subnet_cidrs
  availability_zones = local.availability_zones
  default_tags       = local.default_tags
  cluster_name = var.cluster_name
}

module "nat_gateway" {
  source            = "./modules/nat_gateway"
  public_subnet_ids = module.public_subnets.public_subnet_ids
  default_tags      = local.default_tags
  nat_eip_names     = local.nat_eip_names
}

module "private_subnets" {
  source             = "./modules/private_subnets"
  vpc_id             = module.vpc.vpc_id
  subnet_cidrs       = local.private_subnet_cidrs
  availability_zones = local.availability_zones
  nat_gateway_ids    = module.nat_gateway.nat_gateway_ids
  default_tags       = local.default_tags
  cluster_name = var.cluster_name
}

module "route_tables" {
  source              = "./modules/route_tables"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_eks
  nat_gateway_ids     = module.nat_gateway.nat_gateway_ids
  public_subnet_ids   = module.public_subnets.public_subnet_ids
  private_subnet_ids  = module.private_subnets.private_subnet_ids
  default_tags        = local.default_tags
}
#########################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = "quiz-eks-cluster"
  cluster_version = "1.31"
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids

  cluster_endpoint_public_access = true

  # iam_role_arn = aws_iam_role.eks_cluster_role.arn
cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
     aws-efs-csi-driver = {
    most_recent = true
  }
  }
  eks_managed_node_groups = {
    spot_nodes = {
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      instance_types = ["t3.medium", "t3.medium"]
      capacity_type  = "SPOT"
      subnets        = var.private_subnet_ids
    
    }
  }

 
  access_entries = {
    eks_user_access = {
      principal_arn = "arn:aws:iam::241533146625:user/eks-user-terraform"
      type          = "STANDARD"
     
   policy_associations = {
      admin = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type = "cluster"
        }
      }
    }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

###############################
module "efs" {
  source              = "./modules/eks-cluster"
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  public_subnet_ids = var.public_subnet_ids
  eks_node_security_group_id    = "sg-020ab41ad49f3e243"
  cluster_name = var.cluster_name
}