## This documentation details the design, deployment, and automation of a Flask-based QuizApp running on an AWS Elastic Kubernetes Service (EKS) cluster. The infrastructure is provisioned with Terraform, and a complete CI/CD pipeline is implemented using GitHub Actions and Argo CD.

- Document Version: v1.0.0
  
### Key Points
- Flask-based QuizApp is containerized and deployed on AWS EKS.
- Infrastructure is provisioned using Terraform (VPC, EKS, ECR).
- CI/CD pipeline built using GitHub Actions with Docker image tagging format: branch_name:commitID
- Docker image pushed to AWS ECR and deployed using Argo CD with auto-sync enabled

### Scope
This documentation focuses on setting up a complete DevOps pipeline in AWS:

- Covered: Networking, Kubernetes with EKS, Docker, CI/CD using GitHub Actions and Argo CD, Terraform modules

- Not Covered: Flask application development in-depth, Kubernetes performance tuning, Cost optimization

### Intended Audience
- DevOps Engineer
- Experience: Intermediate with AWS, Docker, Kubernetes, and CI/CD tools

### Architecture Overview

[GitHub] → [GitHub Actions] → [Docker Image → ECR] → [Argo CD → EKS Cluster → Pods]
                     ↓
               [Terraform Infrastructure: VPC, EKS, ECR]


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
#### Outputs:
- VPC Networking endpoints like vpc id,public subnets id,private subnets id,igw,nat gateway.
  
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

---

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

---

## Intended Audience <a name="intended-audience"></a>
- **DevOps Engineers** automating cloud deployments  
- **Developers** seeking Kubernetes deployment skills  
- **Cloud Architects** designing scalable infrastructures  

**Prerequisites:**  
- AWS CLI + Terraform installed  
- Basic Kubernetes/Docker knowledge  

---

## Key Definitions <a name="key-definitions"></a>
| Term               | Definition                                                                 |
|---------------------|---------------------------------------------------------------------------|
| **VPC**             | Isolated virtual network for AWS resources                                |
| **EKS**             | Managed Kubernetes service by AWS                                        |
| **podAntiAffinity** | Kubernetes rule to distribute pods across nodes                          |
| **Argo CD**         | GitOps tool for declarative Kubernetes deployments                        |

