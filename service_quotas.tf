locals {
  # Compile a map of the service quotas using the service code and quota code as the key
  service_quotas = {
    for quota in var.service_quotas : "${quota.service_code}-${quota.quota_code}" => {
      service_code = quota.service_code
      quota_code   = quota.quota_code
      value        = quota.value
    }
  }
}

## Provision the service quotas within the account
resource "aws_servicequotas_service_quota" "service_quotas" {
  for_each = local.service_quotas

  service_code = each.value.service_code
  quota_code   = each.value.quota_code
  value        = each.value.value

  provider = aws.tenant
}
