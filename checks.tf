
# The domains must end with aws.appvia.local
#check "domain_checks" {
#  assert {
#    condition     = alltrue([for domain in keys(var.dns) : can(regex(local.dns_permitted_domains, domain))])
#    error_message = "The domain name must end with aws.appvia.local"
#  }
#}

check "validate_tagging" {
  assert {
    condition     = length(var.tags) > 0
    error_message = "The tags must be defined"
  }

  assert {
    condition     = length(local.product) > 0 && length(local.product) <= 12
    error_message = "The product name must be between 1 and 12 characters"
  }

  assert {
    condition     = length(local.environment) > 0 && length(local.environment) <= 14
    error_message = "The environment name must be between 1 and 14 characters"
  }

  assert {
    condition     = length(local.owner) > 0 && length(local.owner) <= 14
    error_message = "The owner name must be between 1 and 14 characters"
  }
}
