output "arn" {
  description = "ARN of the role"
  value       = aws_iam_role.role.arn
}

output "name" {
  description = "Name of the role"
  value       = aws_iam_role.role.name
}