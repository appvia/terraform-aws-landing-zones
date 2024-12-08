#
## Used to configure the default settings for the macie service
#

locals {
  ## Indicates if macie is configured
  macie_managed = var.macie != null

  ## Is the administrative account (if defined) for the macie service
  macie_admin_account_id = try(var.macie.admin_account_id, null)

  ## Indicates if we should enable the macie account settings
  enable_macie = local.macie_managed && try(var.macie.enable, false)
  ## Indicates we should try and accept any invitations
  enable_accept_invitation = local.enable_macie && try(var.macie.admin_account_id, null) != null
}

## Configure the macie service for the account
resource "aws_macie2_account" "macie_member" {
  count = local.macie_managed ? 1 : 0

  finding_publishing_frequency = var.macie.frequency
  status                       = local.enable_macie ? "ENABLED" : "PAUSED"

  provider = aws.tenant
}

## Accept the macie invitation
resource "aws_macie2_invitation_accepter" "member" {
  count = local.enable_accept_invitation ? 1 : 0

  administrator_account_id = local.macie_admin_account_id
  depends_on               = [aws_macie2_account.macie_member]
}
