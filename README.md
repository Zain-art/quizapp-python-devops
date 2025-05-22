## This documentation details the design, deployment, and automation of a Flask-based QuizApp running on an AWS Elastic Kubernetes Service (EKS) cluster. The infrastructure is provisioned with Terraform, and a complete CI/CD pipeline is implemented using GitHub Actions and Argo CD.

- Document Version: v1.0.0
 ## Table of Contents
1. [Scope](#scope)  
2. [Intended Audience](#intended-audience)  
3. [Key Definitions](#key-definitions)  
4. [Module 1 - Set up Networking in AWS using Terraform](#module-1)  
5. [Module 2 - Create an EKS Kubernetes Cluster](#module-2)  
6. [Module 3 - Docker / Containerization](#module-3)  
7. [Module 4 - Deploy Application on Kubernetes](#module-4)  
8. [Module 5 - Implement CI/CD](#module-5)  
9. [Module 6 - Implement IaC - Terraform](#module-6)  
10. [FAQs](#faqs)  
11. [Additional Resources](#additional-resources)  

### Key Points
- Flask-based QuizApp is containerized and deployed on AWS EKS.
- Infrastructure is provisioned using Terraform (VPC, EKS, ECR).
- CI/CD pipeline built using GitHub Actions with Docker image tagging format: branch_name:commitID
- Docker image pushed to AWS ECR and deployed using Argo CD with auto-sync enabled

## Scope <a name="scope"></a>
This guide provides a step-by-step approach to building a production-ready AWS EKS environment with full CI/CD automation.  

**Included:**  
- Terraform-managed networking (VPC, NAT/Internet Gateways)  
- Cost-optimized EKS cluster with Spot Instances  
- Dockerized Python Flask app deployment  
- GitOps-driven CI/CD using GitHub Actions + Argo CD  

**Excluded:**  
- Application code deep dives  
- Advanced Kubernetes tuning
  
## Intended Audience <a name="intended-audience"></a>
- **DevOps Engineers** automating cloud deployments  
- **Developers** seeking Kubernetes deployment skills  
- **Cloud Architects** designing scalable infrastructures


## Key Definitions <a name="key-definitions"></a>
| Term               | Definition                                                                 |
|---------------------|---------------------------------------------------------------------------|
| **VPC**             | Isolated virtual network for AWS resources                                |
| **EKS**             | Managed Kubernetes service by AWS                                        |
| **podAntiAffinity** | Kubernetes rule to distribute pods across nodes                          |
| **Argo CD**         | GitOps tool for declarative Kubernetes deployments                        |  

**Prerequisites:**  
- AWS CLI + Terraform installed  
- Basic Kubernetes/Docker knowledge
- ArgoCD installed on your local system or linux/window
  
### Architecture Overview




## Infrastructure Setup (Terraform)
- VPC with public and private subnets across 2 AZs
- Internet Gateway and NAT Gateway
- EKS Cluster with private worker nodes
- ECR repository for Docker images

### Steps:
#### 1. Clone Terraform Repository

- [Github Repo : https://github.com/Zain-art/quizapp-python-devops.git](https://github.com/Zain-art/quizapp-python-devops.git)

###  - Set up Networking in AWS using Terraform with isolated files and subfolders in the main folder

- Create a custom VPC
- Set up two public and two private subnets across AZs
- Define separate route tables for public and private subnets
- Attach an Internet Gateway to the public subnets
- Provision NAT Gateway in public subnet for private subnet access
- Use Terraform modules for reusability
  
- 1 First Create a provider:
 ```
# Terraform and Provider Version

terraform {
  required_version = ">= 1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


```
- 2 Create a variables.tf file
 ```
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}
variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}
variable "cluster_name" {
  type = string
  default = "quiz-eks-cluster"
}
variable "eks_node_security_group_id" {
  type = string
  default = "sg-020ab41ad49f3e243"
}
```
- 3 Create a local file for storing values in the main root folder:
```

locals {
  env                  = "dev1"
  region               = "us-east-1"
  eks_name = "quiz-eks-cluster"
  vpc_cidr_block       = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.5.0/24", "10.0.6.0/24"]
  private_subnet_cidrs = ["10.0.15.0/24", "10.0.16.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  cluster_name         = "quiz-eks-cluster"
  eks_version      = "1.31"
  name_vpc             = "quiz-vpc"
  nat_eip_names = [
    "nat-eip-vpc-1-qiuz",
    "nat-eip-vpc-2-quiz"

  ]
  my_vpc_name = {
    name = "quiz-vpc"
  }
  # Environment = "dev1"
  ManagedBy = "Terraform1"

  default_tags = {
    name_vpc             = "quiz-vpc"
    Project     = "quizapp-flask"
    Environment = "dev1"
    ManagedBy   = "Terraform"
  }

 vpc_id = "vpc-053fc19cb7e5c3bd4"
# vpc_id             = "vpc-053fc19cb7e5c3bd4"
private_subnet_ids =  ["subnet-031ac6c50171a6528", "subnet-00780688da342dfe4"]
public_subnet_ids  = ["subnet-06a6ad10916484449", "subnet-013c330a7ccd02e61"]

}
```
- 4 Create a custom VPC
```

resource "aws_vpc" "my_vpc_eks" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.vpc_tag
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "vpc_tag" {
  type = map(string)
}

output "vpc_id" {
  value = aws_vpc.my_vpc_eks.id
}

output "vpc_tag" {
  value = aws_vpc.my_vpc_eks.tags_all
}
```
- 5 Create a backend.tf file for storing the remote state management and state lock file in S3 bucket.
```
terraform {
  backend "s3" {
    bucket         = "zain-terraform-backend"
    key            = "vpc/terraform.tfstate-vpc"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-vpc"
    encrypt        = true
  }
}
 resource "aws_dynamodb_table" "tf_locks" {
   name         = "terraform-locks-vpc"
   billing_mode = "PAY_PER_REQUEST"
   hash_key     = "LockID"
   attribute {
     name = "LockID"
     type = "S"
   }
}
```
---
- 6 Create a 2 public subnets in VPC:
```
resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = var.vpc_id 
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.default_tags, {
    Name = "public-sb-quiz-${count.index + 1}"
     "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/quiz-eks-cluster" = "shared"
  })
}


variable "vpc_id" {}
variable "subnet_cidrs" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
variable "default_tags" {
  type = map(string)
}


variable "cluster_name" {
  type = string
}
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

```
---
- 7 Create a 2  private subnets in same VPC:
```
resource "aws_subnet" "private" {
  count             = length(var.subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.default_tags, {
    Name = "private-sb-quiz-${count.index + 1}"
     "kubernetes.io/role/internal-elb"                      = 1
    "kubernetes.io/cluster/quiz-eks-cluster" = "shared"
  })
} 

variable "vpc_id" {}
variable "subnet_cidrs" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
variable "nat_gateway_ids" {
  type = list(string)
}
variable "default_tags" {
  type = map(string)
}
variable "cluster_name" {
  type = string
}

```
---
- 8 Create a NAT Gateway for private subnets:
```
resource "aws_eip" "nat" {
   count  = length(var.public_subnet_ids)
  domain = "vpc"

  tags = {
    Name = "${var.nat_eip_names[count.index]}-nat-quiz"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_ids)
 allocation_id = aws_eip.nat[count.index].id 
  subnet_id     = var.public_subnet_ids[count.index]

  tags = {
    Name = "${var.nat_eip_names[count.index]}-nat-quiz"
  }

 
}
  
variable "public_subnet_ids" {
  type = list(string)
}
variable "default_tags" {
  type = map(string)
}
variable "nat_eip_names" {
  type = list(string)
}
```
---
- 9 Create a Internet Gateway for public subnets:
```
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags   = var.default_tags
}

variable "vpc_id" {}
variable "default_tags" {
    type = map(string)
}
```
---
- AFter copy code you would be run these fome Terraform commands to create a VPC:
####  Configure Backend and Initialize
```
terraform init
terraform fmt
terraform plan
terraform apply
```
---
## After Creating successfully VPC you can create EKS Cluster using Terraform:
- Create an EKS Kubernetes Cluster.
- Use EC2 Spot Instances to save cost.
- Distribute nodes across AZs for High Availability
- Define node IAM roles and permissions carefully

- 1 Create an EKS Kubernetes Cluster.
```

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
##---------------------------------##
# Node group IAM role and policy
resource "aws_iam_role" "nodes" {
  name = "${local.env}${local.eks_name}-eks-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# This policy now includes AssumeRoleForPodIdentity for the Pod Identity Agent
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}
##---------------------##
EKS ADD manager to give the Full Access to EKS Cluster
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_admin" {
  name = "${local.env}-${local.eks_name}-eks-admin"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "eks_admin" {
  name = "AmazonEKSAdminPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_iam_user" "manager" {
  name = "manager"
}

resource "aws_iam_policy" "eks_assume_admin" {
  name = "AmazonEKSAssumeAdminPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "${aws_iam_role.eks_admin.arn}"
        }
    ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "manager" {
  user       = aws_iam_user.manager.name
  policy_arn = aws_iam_policy.eks_assume_admin.arn
}

---------------------------
eks-cluster/local.tf
locals {
 nat_gateway_ids = [
  "nat-099d5f3eb8d02a1a5",
  "nat-0999cbb2d756faadc",
]
vpc_cidr_block     = "10.0.0.0/16"
vpc_id             = "vpc-053fc19cb7e5c3bd4"
private_subnet_ids =  ["subnet-031ac6c50171a6528", "subnet-00780688da342dfe4"]
public_subnet_ids  = ["subnet-06a6ad10916484449", "subnet-013c330a7ccd02e61"]
vpc_tag = tomap({
  "name" = "quiz-vpc-eks"
})
 env                  = "dev"
  region               = "us-east-1"
  eks_name = "quiz-eks-cluster"
  # vpc_cidr_block       = "10.0.0.0/16"
   cluster_name         = "quiz-eks-cluster"
  eks_version      = "1.31"
  name_vpc             = "quiz-vpc"
}
------------------------
Security Group work as a Firewall TO Incomming and OutGoing Traffic on Nodes
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

-------------------
variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}
variable "region" {
  default = "us-east-1"
  type = string
}
variable "vpc_id" {
  type        = string
  description = "VPC ID for the cluster"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}



variable "eks_node_security_group_id" {
  type = string
}



```




