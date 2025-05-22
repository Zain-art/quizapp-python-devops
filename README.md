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

**Prerequisites:**  
- AWS CLI + Terraform installed  
- Basic Kubernetes/Docker knowledge
  
### Architecture Overview




## Infrastructure Setup (Terraform)
- VPC with public and private subnets across 2 AZs
- Internet Gateway and NAT Gateway
- EKS Cluster with private worker nodes
- ECR repository for Docker images

### Steps:
#### 1. Clone Terraform Repository

- [Github Repo : https://github.com/Zain-art/quizapp-python-devops.git](https://github.com/Zain-art/quizapp-python-devops.git)
#### 2. Configure Backend and Initialize
```
terraform init
terraform plan
terraform apply
```
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
  

---

  

---



---

## Key Definitions <a name="key-definitions"></a>
| Term               | Definition                                                                 |
|---------------------|---------------------------------------------------------------------------|
| **VPC**             | Isolated virtual network for AWS resources                                |
| **EKS**             | Managed Kubernetes service by AWS                                        |
| **podAntiAffinity** | Kubernetes rule to distribute pods across nodes                          |
| **Argo CD**         | GitOps tool for declarative Kubernetes deployments                        |

