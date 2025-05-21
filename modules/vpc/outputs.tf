output "vpc_id" {
  value = aws_vpc.my_vpc_eks.id
}

output "vpc_tag" {
  value = aws_vpc.my_vpc_eks.tags_all
}