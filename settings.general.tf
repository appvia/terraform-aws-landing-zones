
locals {
  ## The name of the development environment 
  environment_dev = "Development"
  ## The name of the production environment
  environment_prod = "Production"
  ## The name of the staging environment 
  environment_staging = "Staging"
  ## The name of the testing environment 
  environment_test = "Testing"

  ## The git repository to store the terraform code 
  git_repo = "https://github.com/appvia/terraform-aws-landing-zones"
}