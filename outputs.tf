output "arn" {
  description = "The Amazon Resource Name (ARN) of the AWS IAM Role."
  value       = aws_iam_role.main.arn
}

output "name" {
  description = "The name of the AWS IAM Role."
  value       = aws_iam_role.main.name
}
