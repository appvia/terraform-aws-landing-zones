#
## Used to configure the default settings for the macie service 
# 

locals {
  ## Indicates if we should enable the macie account settings
  enable_macie = var.macie.enabled
}

## Configure the macie service for the account 
resource "aws_macie2_account" "macie_member" {
  count = local.enable_macie ? 1 : 0

  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = var.macie.enabled ? "ENABLED" : "PAUSED"

  provider = aws.tenant
}
