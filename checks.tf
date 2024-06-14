
# The domains must end with aws.appvia.local
#check "domain_checks" {
#  assert {
#    condition     = alltrue([for domain in keys(var.dns) : can(regex(local.dns_permitted_domains, domain))])
#    error_message = "The domain name must end with aws.appvia.local"
#  }
#}

check "private_domains" {
  assert {
    condition     = length(local.private_hosted_zones) == 0 && length(var.networks) == 0
    error_message = "The private hosted zones should not be defined if no networks are defined"
  }
}
