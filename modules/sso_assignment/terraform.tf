
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      configuration_aliases = [aws.identity]
      source                = "hashicorp/aws"
      version               = "~> 5.0"
    }
  }
}
