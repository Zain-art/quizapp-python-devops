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

### Module 1 - Set up Networking in AWS using Terraform with isolated files and subfolders in the main folder
- First Create a provider:
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
- Create a variables.tf file
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
- Create a local file for storing values in the main root folder:
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
- Create a custom VPC
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
- Create a backend.tf file for storing the remote state management and state lock file in S3 bucket.
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
- Create a 2 public subnets in VPC:
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
- Create a 2  private subnets in same VPC:
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
- Create a NAT Gateway for private subnets:
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
- Create a Internet Gateway for public subnets:
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
#### 2. Configure Backend and Initialize
```
terraform init
terraform plan
terraform apply
```

---



