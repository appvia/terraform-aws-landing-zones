
## Provision any service control policies (SCPs) that are required for the account 
resource "aws_organizations_policy" "service_control_policies" {
  for_each = var.service_control_policies

  name        = format("lza-custom-%s", lower(each.value.name))
  description = "Service control policy configured by the landing zone automation, for account: ${local.account_id}"
  content     = each.value.policy
  type        = "SERVICE_CONTROL_POLICY"

  provider = aws.management
}
