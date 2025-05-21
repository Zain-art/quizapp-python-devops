// {
//     └── VPC-EKS-EFS-tf/
//     ├── .terraform.lock.hcl
//     ├── 0-locals.tf
//     ├── 1-variables.tf
//     ├── 2-versions.tf
//     ├── 3-providers.tf
//     ├── 4-outputs.tf
//     ├── backend.tf
//     ├── main.tf
//     // ├── terraform.tfstate
//     ├── eks-cluster-module/
//     │   ├── 1-eks-main.tf
//     │   ├── 2-nodes-group-eks.tf
//     ├── 0-locals.tf
//     ├── 1-variables.tf
//     ├── 2-versions.tf
//     ├── 3-providers.tf
//     ├── 4-outputs.tf
//     │ 
//     ├── network-module/
//     │   ├── vpc/
//     │   │   ├── main.tf
//     │   │   ├── outputs.tf
//     │   │   └── variables.tf
//     │   ├── route_tables/
//     │   │   ├── main.tf
//     │   │   ├── outputs.tf
//     │   │   └── variables.tf
//     │   ├── public_subnets/
//     │   │   ├── main.tf
//     │   │   ├── outputs.tf
//     │   │   └── variables.tf
//     │   ├── private_subnets/
//     │   │   ├── main.tf
//     │   │   ├── outputs.tf
//     │   │   └── variables.tf
//     │   ├── nat_gateway/
//     │   │   ├── main.tf
//     │   │   ├── outputs.tf
//     │   │   └── variables.tf
//     │   └── internet_gateway/
//     │       ├── main.tf
//     │       ├── outputs.tf
//     │       └── variables.tf
    