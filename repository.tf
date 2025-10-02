locals {
  ## Indicates if we should enable the EKS cluster
  enable_infrastructure_repository = var.infrastructure_repository != null ? true : false
  ## Indicates we should create a permissions boundary for the repository
  enable_permissions_boundary = local.enable_infrastructure_repository ? (var.infrastructure_repository.permissions_boundary != null ? true : false) : false
  ## Indictaes we should create a policy from the permissions boundary
  enable_permissions_boundary_policy = local.enable_permissions_boundary ? var.infrastructure_repository.permissions_boundary.policy != null ? true : false : false
  ## The infrastructure repository configuration
  repository = var.infrastructure_repository
}

## Provision a prefixed permissions boundary for the repository
resource "aws_iam_policy" "permissions_boundary" {
  count = local.enable_permissions_boundary_policy ? 1 : 0

  name_prefix = format("%s-boundary-", lower(local.repository.name))
  description = format("Permissions boundary for the %s repository.", local.repository.name)
  path        = "/"
  policy      = try(local.repository.permissions_boundary.policy, null)
  tags        = local.tags
}

## Provision a repository for this landing zone, and enable the repository permissions 
## to configure and provision the infrastructure with the said account.
module "repository_permissions" {
  count   = local.enable_infrastructure_repository ? 1 : 0
  source  = "appvia/oidc/aws//modules/role"
  version = "1.3.10"

  name                    = local.repository.name
  account_id              = local.account_id
  description             = format("Used to configure and provision the infrastructure with the %s landing zone.", local.repository.name)
  permission_boundary_arn = local.enable_permissions_boundary ? coalesce(try(local.repository.permissions_boundary.arn, null), try(aws_iam_policy.permissions_boundary[0].arn, null), null) : null
  read_only_policy_arns   = try(local.repository.permissions.read_only_policy_arns, null)
  read_write_policy_arns  = try(local.repository.permissions.read_write_policy_arns, null)
  region                  = local.region
  repository              = local.repository.name
  tags                    = var.tags

  depends_on = [aws_iam_policy.permissions_boundary]

  providers = {
    aws = aws.tenant
  }
}

## Provision a Github repository for this landing zone, if required.
module "github_repository" {
  count  = local.enable_infrastructure_repository && try(local.repository.create, false) ? 1 : 0
  source = "./modules/github_repository"

  repository     = local.repository.name
  description    = format("Infrastructure repository for the %s landing zone.", local.repository.name)
  default_branch = try(local.repository.default_branch, "main")
  visibility     = local.repository.visibility

  # Template settings
  enable_repository_template = try(local.repository.template, null) != null ? true : false
  organization_template      = try(local.repository.template.owner, null)
  repository_template        = try(local.repository.template.repository, null)

  # Branch rules 
  allow_auto_merge       = try(local.repository.allow_auto_merge, false)
  allow_merge_commit     = try(local.repository.allow_merge_commit, true)
  allow_rebase_merge     = try(local.repository.allow_rebase_merge, true)
  allow_squash_merge     = try(local.repository.allow_squash_merge, true)
  delete_branch_on_merge = true

  # Branch protection
  dismiss_stale_reviews                = try(local.repository.dismiss_stale_reviews, true)
  dismissal_users                      = try(local.repository.dismissal_users, [])
  enforce_branch_protection_for_admins = try(local.repository.branch_protection.enforce_branch_protection_for_admins, true)
  prevent_self_review                  = try(local.repository.prevent_self_review, true)
  required_approving_review_count      = try(local.repository.branch_protection.required_approving_review_count, 2)
}
