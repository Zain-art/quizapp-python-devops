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
# variable "cluster_name" {
#   type = string
# }