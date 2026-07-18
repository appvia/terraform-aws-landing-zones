
terraform {
  ## Note 1.3.0 is the floor as the module uses optional() with defaults in its type constraints
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0, < 7.0.0"
      configuration_aliases = [
        aws.network,
      ]
    }
  }
}
