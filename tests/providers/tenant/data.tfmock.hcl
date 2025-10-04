
mock_data "aws_region" {
  defaults = {
    name   = "eu-west-2"
    region = "eu-west-2"
  }
}

mock_data "aws_availability_zones" {
  defaults = {
    names = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  }
}

mock_data "aws_vpc_ipam_pools" {
  defaults = {
    ipam_pools = [
      {
        id                             = "ipam-pool-1234567890"
        address_family                 = "ipv4"
        description                    = "test-ipam-pool"
        ipam_pool_id                   = "ipam-pool-1234567890"
        ipam_pool_type                 = "private"
        ipam_pool_cidr                 = "10.0.0.0/16"
        ipam_pool_cidr_allocation      = "static"
        ipam_pool_cidr_allocation_type = "prefix"
      }
    ]
  }
}

mock_data "aws_caller_identity" {
  defaults = {
    account_id = "123456781000"
    arn        = "arn:aws:iam::123456781000:role/role-name"
  }
}

mock_data "aws_partition" {
  defaults = {
    partition = "aws"
  }
}
