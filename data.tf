
## Get the SSO Instance
data "aws_ssoadmin_instances" "current" {
  provider = aws.identity
}

## Get the current account id for the tenant account
data "aws_caller_identity" "tenant" {
  provider = aws.tenant
}

## Get the current region
data "aws_region" "tenant" {
  provider = aws.tenant
}

## Get the current account for the current account
data "aws_caller_identity" "current" {
}

## Get the organization
data "aws_organizations_organization" "current" {
  provider = aws.management
}

## Get all the accounts within the organization
data "aws_organizations_organizational_unit_descendant_accounts" "current" {
  parent_id = data.aws_organizations_organization.current.roots[0].id

  provider = aws.management
}

## Get all the ipam pools within the network account
data "aws_vpc_ipam_pools" "current" {
  filter {
    name   = "address-family"
    values = ["ipv4"]
  }

  provider = aws.network
}
