
output "account_arn" {
  description = "The ARN of the account"
  value       = aws_organizations_account.account.arn
}

output "account_id" {
  description = "The ID of the account"
  value       = aws_organizations_account.account.id
}

output "account_status" {
  description = "The status of the account"
  value       = aws_organizations_account.account.status
}

output "account_name" {
  description = "The name of the account"
  value       = aws_organizations_account.account.name
}

output "account_email" {
  description = "The email address of the account"
  value       = aws_organizations_account.account.email
}
