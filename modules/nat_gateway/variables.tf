variable "public_subnet_ids" {
  type = list(string)
}
variable "default_tags" {
  type = map(string)
}
variable "nat_eip_names" {
  type = list(string)
}