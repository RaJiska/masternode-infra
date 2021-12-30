output "id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.vpc.arn
}

output "public_subnets" {
  description = "List of public subnets associated to the VPC"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of private subnets associated to the VPC"
  value       = aws_subnet.private[*].id
}