#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

## What would be nice to manage for a tenant 
# - Networks and connectivity 
# - DNS zones 
# - Shared Private Endpoints 
# - Private Link Services 
# - Firewall rules 
# - RBAC assignments 


#module "shared_services_rbac" {
#  source = "../../modules/sso_roles"
#
#  roles = {
#    platform_engineer = {
#      users  = ["my_user"]
#      groups = ["my_group"]
#    }
#  }
#
#  providers = {
#    aws = aws
#  }
#}

#tfsec:ignore:AVD-DS-0002
#tfsec:ignore:AVD-DS-0013
#tfsec:ignore:AVD-DS-0015
#tfsec:ignore:AVD-DS-0026
#tfsec:ignore:AVD-AWS-0067
#tfsec:ignore:AVD-AWS-0057
module "dev_apps" {
  source = "../../"

  environment = "Development"
  owner       = "platform"
  product     = "app1"
  region      = "eu-west-2"
  tags        = var.tags

  notifications = {
    email = {
      addresses = [""]
    }
    slack = {
      webhook_url = ""
    }
  }

  rbac = {
    platform_engineer = {
      groups = ["my_group"]
    }
  }

  anomaly_detection = {
    enable_default_monitors = true
    monitors                = []
  }

  networks = {
    dev = {
      vpc = {
        ipam_pool_name = "development"
        netmask        = 21
      }
      subnets = {
        public = {
          netmask = 24
        }
        private = {
          netmask = 24
        }
        database = {
          netmask = 24
        }
      }
    },
  }

  dns = {
    "team.aws.appvia.local" = {
      comment = "Managed by zone created by terraform"
      private = true
      network = "dev"
    },
  }


  providers = {
    aws            = aws
    aws.identity   = aws.identity
    aws.network    = aws.network
    aws.management = aws.management
    aws.tenant     = aws.tenant
  }
}
