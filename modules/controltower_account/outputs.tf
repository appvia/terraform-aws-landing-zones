
output "account_id" {
  description = "The account ID of the provisioned account"
  value       = try(tolist([for o in aws_servicecatalog_provisioned_product.control_tower_account.outputs : o if o.key == "AccountId"])[0].value, null)
}

output "account_email" {
  description = "The email address associated to the account"
  value       = try(tolist([for o in aws_servicecatalog_provisioned_product.control_tower_account.outputs : o if o.key == "AccountEmail"])[0].value, null)
}

output "arn" {
  description = "The ARN of the provisioned service catalog product"
  value       = aws_servicecatalog_provisioned_product.control_tower_account.arn
}

output "id" {
  description = "The ID of the provisioned service catalog product"
  value       = aws_servicecatalog_provisioned_product.control_tower_account.id
}

output "name" {
  description = "The name of the provisioned service catalog product"
  value       = aws_servicecatalog_provisioned_product.control_tower_account.name
}

output "product_id" {
  description = "The ID of the product used to provision the service catalog product"
  value       = aws_servicecatalog_provisioned_product.control_tower_account.product_id
}

output "provisioning_artifact_id" {
  description = "The ID of the provisioning artifact used to provision the service catalog product"
  value       = aws_servicecatalog_provisioned_product.control_tower_account.provisioning_artifact_id
}

output "provisioning_artifact_name" {
  description = "The name of the provisioning artifact used to provision the service catalog product"
  value       = aws_servicecatalog_provisioned_product.control_tower_account.provisioning_artifact_name
}

output "status" {
  description = "The status of the provisioned service catalog product"
  value       = aws_servicecatalog_provisioned_product.control_tower_account.status
}
