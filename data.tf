
## Get the current region
data "aws_region" "current" {}

## Get the current account for the current account
data "aws_caller_identity" "current" {}

## Get all the ipam pools within the network account
data "aws_vpc_ipam_pools" "current" {
  filter {
    name   = "address-family"
    values = ["ipv4"]
  }
}
