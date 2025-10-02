locals {
  ## Indicates if we should enable the repository template
  enable_repository_template = var.organization_template != null && var.repository_template != null ? true : false
}
