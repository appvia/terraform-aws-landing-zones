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

  anomaly_detection = {
    enable_default_monitors = false
  }

  networks = {
    app1 = {
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
    "app1.aws.appvia.local" = {
      comment = "Managed by zone created by terraform"
      private = true
      network = "app1"
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

module "app2" {
  source = "../../"

  environment = "Development"
  owner       = "platform"
  product     = "app2"
  region      = "eu-west-2"
  tags        = var.tags

  anomaly_detection = {
    enable_default_monitors = false
  }

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
