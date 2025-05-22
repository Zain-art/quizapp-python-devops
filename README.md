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
Security Group work as a Firewall TO Control Incomming and OutGoing Traffic on Nodes and Cluster
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
### Docker / Containerization
- Write a basic Python Flask app (e.g., app.py)
- Create a Dockerfile to containerize the app
- Build and run the Docker container locally
- est it on localhost:5000
- Push image to Docker Hub or AWS ECR

- Create a Dockerfile 
```
# -------- Stage 1: Builder --------
FROM python:3.13-slim AS builder

# Set working directory
WORKDIR /app

# Install OS-level dependencies
RUN apt-get update && apt-get install -y build-essential gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install packages
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# -------- Stage 2: Runtime --------
FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Copy dependencies and code from builder
# Copy installed Python packages and application code from builder
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /app /app

RUN mkdir -p /app


# Expose the default Flask port
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]

```
### Run Commands to Create a Dockker Image
```
docker build -t quizapp:latest .
docker run -it -p 5000:5000 quizapp:latest
docker ps  ## to check the docker containers

---
### Deploy Application on Kubernetes
- Create Kubernetes Deployment with 2–3 replicas
- Use podAntiAffinity rules to ensure replicas are on different nodes
- Create a Kubernetes Service and expose using ALB or NLB 

- Create Kubernetes Deployment with 2–3 replicas
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quizapp-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: quizapp
  template:
    metadata:
      labels:
        app: quizapp
    spec:
      containers:
        - name: quizapp
          image: 241533146625.dkr.ecr.us-east-1.amazonaws.com/quizapp-flask:main-58f4916
          ports:
            - containerPort: 5000
          volumeMounts:
            - name: sqlite-storage
              mountPath: /app/data
          env:
            - name: FLASK_ENV
              value: "production"
            - name: SQLALCHEMY_DATABASE_URI
              value: "sqlite:////app/data/db.sqlite"
      volumes:
        - name: sqlite-storage
          persistentVolumeClaim:
            claimName: sqlite-pvc
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - quizapp
                topologyKey: "kubernetes.io/hostname"
```
- Create PV file
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: sqlite-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath:
    path: "/mnt/data/sqlite"
```
- Create PVC file
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sqlite-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```
- Create Service file
```
apiVersion: v1
kind: Service
metadata:
  name: quizapp-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb" # Use NLB (Network Load Balancer)
    # service.beta.kubernetes.io/aws-load-balancer-internal: "false" # Set to "true" if you want internal-only LB
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  selector:
    app: quizapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```
#### Run Kubernetes Commands to Create the Deployment,Service,PV (PersistentVolume) and PVC.
```
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f quiz-deployment.yaml
kubectl apply -f quiz-service.yaml
kubectl get nodes
kubectl get nodes -o wide
kubectl get pods
kubectl get pv
kubectl get pvc
kubectl get svc
kubectl logs podID
kubectl describe pod podID or any other resource.
kubectl delete -f quiz-deployment.yaml
kubectl delete -f pv.yaml
kybectl delete -f pvc.yaml
kubectl delete -f quiz-service.yaml

```
---
### Implement CI / CD
- CI using GitHub Actions:
  - On every push to a branch:
  - Tag image as <BranchName>-<CommitID>
  - Push image to container registry

```
name: CI/CD Pipeline for Flask Quiz App with AWS ECR # this is github action name

on:
  push:
    branches:
      - main
    paths:
      - 'QuizApp-Flask/**'
      - '.github/workflows/**'    # Trigger on push if any changes do in these dir/CICD file
  pull_request:
    branches:
      - main  # Also run for PRs
permissions:
  contents: write  # Required to push changes to repo
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      # Step 1: Checkout the code from GitHub
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Required to get full git history for metadata
      # Step 2: Configure AWS credentials from GitHub Secrets
      - name: Configure AWS of my credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}
      # Step 3: Log in to Amazon ECR using AWS credentials
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      # Step 4: Extract branch name and short commit SHA for Docker tag
      - name: Extract Git metadata
        id: git-meta
        run: |
          echo "branch_name=${GITHUB_REF#refs/heads/}" >> $GITHUB_OUTPUT
          echo "short_sha=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT
      # Step 5: Display image tag in logs
      - name: Show Docker image tag
        run: |
          echo "Docker Image Tag: ${{ steps.git-meta.outputs.branch_name }}-${{ steps.git-meta.outputs.short_sha }}"
      # Step 6: Build and push Docker image to Amazon ECR
      - name: Build and push Docker image to Amazon ECR
        uses: docker/build-push-action@v4
        with:
          context: ./QuizApp-Flask
          file: ./QuizApp-Flask/Dockerfile
          push: true
          tags: ${{ secrets.ECR_REPOSITORY }}:${{ steps.git-meta.outputs.branch_name }}-${{ steps.git-meta.outputs.short_sha }}
      # Step 7: Update the Kubernetes deployment YAML with the new image tag
      - name: Update deployment manifest with new image tag
        run: |
          ls -l k8s-manifest/quiz-deployment.yaml 
          sed -i "s|image: .*|image: ${{ secrets.ECR_REPOSITORY }}:${{ steps.git-meta.outputs.branch_name }}-${{ steps.git-meta.outputs.short_sha }}|" k8s-manifest/quiz-deployment.yaml
      # Step 8: Commit and push the updated manifest to Git (triggers ArgoCD GitOps)
      - name: Commit updated manifest
        run: |
          git config --global user.name "github-actions"
          git config --global user.email "github-actions@github.com"
          git pull origin ${{ github.ref_name }}  # Ensure local is up-to-date
          if git diff --quiet; then
            echo "No changes to commit."
          else
            git add k8s-manifest/quiz-deployment.yaml
            git commit -m "ci: update image to ${{ steps.git-meta.outputs.branch_name }}-${{ steps.git-meta.outputs.short_sha }}"
            git push https://x-access-token:${{ secrets.GT_TOKEN }}@github.com/${{ github.repository }}.git HEAD:${{ github.ref_name }}
          fi
      # Step 9: Manually trigger ArgoCD sync (if auto-sync is disabled)
      # - name: Sync ArgoCD application
      #   env:
      #     ARGOCD_AUTH_TOKEN: ${{ secrets.ARGOCD_AUTH_TOKEN }}
      #     ARGOCD_SERVER: ${{ secrets.ARGOCD_SERVER }}
      #   run: |
      #     curl -k -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN" \
      #          -X POST "$ARGOCD_SERVER/api/v1/applications/quiz-app/sync"


```
- CD using Argo CD:
  - Install Argo CD in local system or EKS Cluster or EC2 Instance.
  - Configure Git repository for app manifests
  - Auto-sync and deploy updated images on each commit

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
 kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
argocd login localhost:8080 --username admin --password admin123
argocd account generate-token --account admin
kubectl -n argocd port-forward svc/argocd-server 8080:443
kubectl get svc -n argocd

```
---
### Implement IaC - Terraform
- Create reusable Terraform modules: vpc/, eks/
- Set up remote state in S3 with DynamoDB for state locking

```

terraform {
  backend "s3" {
    bucket         = "zain-terraform-backend"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "terraform-locks-vpc"
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

  tags = {
    Name = "Terraform Lock Table"
  }
}

```
### Additional Resources
- [AWS EKS Official Doc Kubernetes Basics]([AWS EKS Official Doc Kubernetes Basics](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html)
- [AWS Kubernetes versions on standard support](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions-standard.html)
- [View Amazon EKS platform versions for each Kubernetes version](https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html)
- [Connect kubectl to an EKS cluster by creating a kubeconfig file](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
- [Manage compute resources by using nodes](https://docs.aws.amazon.com/eks/latest/userguide/eks-compute.html)
- [Create a managed node group for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html)
- [Maintain nodes yourself with self-managed nodes](https://docs.aws.amazon.com/eks/latest/userguide/worker.html)
- [Terraform module to create Amazon Elastic Kubernetes (EKS) resources with Latest Version](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [AWS VPC Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Create an EKS Cluster Using Terraform](https://medium.com/@rvisingh1221/create-an-eks-cluster-using-terraform-329b9dde068f)
- [Create Amazon EKS Cluster within its VPC using Terraform](https://platformwale.blog/2023/07/15/create-amazon-eks-cluster-within-its-vpc-using-terraform/)

---
### Additional Topics:
#### What is terraform taint?
  The terraform taint command marks a resource for destruction and recreation during the next terraform apply.
#### What is the kubernetes.io/cluster/<cluster-name> tag?
 “This subnet is allowed to be used by the EKS cluster named <cluster-name>.
 It’s required by EKS and the AWS Load Balancer Controller (or default service-controller) to determine which subnets to use when 
 provisioning:

 LoadBalancers

 NodeGroups

 ENIs (Elastic Network Interfaces)
- Minimum Required Tags for LoadBalancer Support:
  1  For public subnets:
"kubernetes.io/role/elb"                      = "1"
"kubernetes.io/cluster/final-eks-cluster"     = "shared"
2 For private subnets:
  "kubernetes.io/role/internal-elb"             = "1"
"kubernetes.io/cluster/final-eks-cluster"     = "shared"


