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

#tfsec:ignore:AVD-DS-0002
#tfsec:ignore:AVD-DS-0013
#tfsec:ignore:AVD-DS-0015
#tfsec:ignore:AVD-DS-0026
#tfsec:ignore:AVD-AWS-0067
#tfsec:ignore:AVD-AWS-0057
module "dev_apps" {
  source = "../../"

  environment    = "Development"
  owner          = "platform"
  product        = "app1"
  tags           = var.tags
  home_region    = "eu-west-2"
  git_repository = "https://github.com/appvia/example-app.git"

  notifications = {
    email = {
      addresses = ["EMAIL@ADDRESS.COM"]
    }
    slack = {
      webhook_url = "WEBHOOK_URL"
    }
  }

  rbac = {
    platform_engineer = {
      groups = ["my_group"]
    }
  }

  aws_config = {
    enable = true
    compliance_packs = {
      hipaa = {
        template_body = file("${path.module}/assets/hippa.yml")
        parameter_overrides = {
          AccessKeysRotatedParamMaxAccessKeyAge = "45"
        }
      }
    }
  }

  cost_anomaly_detection = {
    monitors = [
      {
        name      = lower("lza-eu-west-2-cost-anomaly-detection")
        frequency = "IMMEDIATE"
        threshold_expression = [
          {
            and = {
              dimension = {
                key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
                match_options = ["GREATER_THAN_OR_EQUAL"]
                values        = ["100"]
              }
            }
          },
          {
            and = {
              dimension = {
                key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
                match_options = ["GREATER_THAN_OR_EQUAL"]
                values        = ["50"]
              }
            }
          }
        ]

        specification = jsonencode({
          "And" : [
            {
              "Dimensions" : {
                "Key" : "REGION"
                "Values" : ["eu-west-2"]
              }
            }
          ]
        })
      }
    ]
  }

  networks = {
    dev = {
      vpc = {
        ipam_pool_name = "development"
        netmask        = 21
      }

      transit_gateway = {
        gateway_id = "tgw-0b1b2c3d4e5f6g7h8"
        gateway_routes = {
          "private" = "10.0.0.0/8"
        }
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
