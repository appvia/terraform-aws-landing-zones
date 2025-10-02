#####################################################################################
# Terraform configuration for the GitHub Repository Module Example
# This file defines the required Terraform version and provider constraints
#####################################################################################

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
