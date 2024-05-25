
# The domains must end with aws.appvia.local
#check "domain_checks" {
#  assert {
#    condition     = alltrue([for domain in keys(var.dns) : can(regex(local.dns_permitted_domains, domain))])
#    error_message = "The domain name must end with aws.appvia.local"
#  }
#}
