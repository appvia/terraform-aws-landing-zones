## Provision any account level CloudWatch subscriptions 
resource "aws_cloudwatch_log_account_policy" "cloudwatch_subscriptions" {
  for_each = try(var.cloudwatch.account_subscriptions, {})

  policy_document    = each.value.policy
  policy_name        = format("lz-subscription-%s", lower(each.key))
  policy_type        = "SUBSCRIPTION_FILTER_POLICY"
  selection_criteria = each.value.selection_criteria
  scope              = "ALL"

  provider = aws.tenant
}
