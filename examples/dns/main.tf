#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

#tfsec:ignore:AVD-DS-0002
#tfsec:ignore:AVD-DS-0013
#tfsec:ignore:AVD-DS-0015
#tfsec:ignore:AVD-DS-0026
#tfsec:ignore:AVD-AWS-0067
#tfsec:ignore:AVD-AWS-0057
module "app1" {
  source = "../../"

  environment = "Development"
  owner       = "platform"
  product     = "app1"
  region      = "eu-west-2"
  tags        = var.tags
  home_region = "eu-west-2"

  networks = {
    app1 = {
      vpc = {
        enable_transit_gateway = true
        ipam_pool_name         = "development"
        netmask                = 21
      }
      subnets = {
        private = {
          netmask = 24
        }
      }
    },
  }

  dns = {
    "app1.aws.appvia.local" = {
      comment = "Managed by zone created by terraform"
      private = true
      network = "app1"
    },
  }

  transit_gateway = {
    gateway_id = "tgw-0b1b2c3d4e5f6g7h8"
    gateway_routes = {
      "private" = "10.0.0.0/8"
    }
  }

  providers = {
    aws            = aws
    aws.identity   = aws.identity
    aws.network    = aws.network
    aws.tenant     = aws.tenant
    aws.management = aws.management
  }
}

module "app2" {
  source = "../../"

  environment = "Development"
  owner       = "platform"
  product     = "app2"
  region      = "eu-west-2"
  tags        = var.tags
  home_region = "eu-west-2"

  networks = {
    app2 = {
      vpc = {
        ipam_pool_name = "development"
        netmask        = 21
      }
      subnets = {
        private = {
          netmask = 24
        }
      }
    },
  }

  dns = {
    "app2.aws.appvia.local" = {
      comment = "Managed by zone created by terraform"
      private = true
      network = "app2"
    },
  }

  providers = {
    aws            = aws
    aws.identity   = aws.identity
    aws.network    = aws.network
    aws.tenant     = aws.tenant
    aws.management = aws.management
  }
}
