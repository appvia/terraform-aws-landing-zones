#
## Used to configure the default settings for the macie service
#

locals {
  ## Indicates if macie is configured
  macie_managed = var.macie != null

  ## Indicates if we should enable the macie account settings
  enable_macie = local.macie_managed && try(var.macie.enable, false)
}

## Configure the macie service for the account
resource "aws_macie2_account" "macie_member" {
  count = local.macie_managed ? 1 : 0

  finding_publishing_frequency = var.macie.frequency
  status                       = local.enable_macie ? "ENABLED" : "PAUSED"

  provider = aws.tenant
}
