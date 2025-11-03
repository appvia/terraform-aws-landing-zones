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
  version = "2.0.2"

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
  count   = local.enable_infrastructure_repository && try(local.repository.create, false) ? 1 : 0
  source  = "appvia/repository/github"
  version = "1.1.3"

  repository                  = local.repository.name
  description                 = try(local.repository.description, format("Infrastructure repository for the %s landing zone.", local.repository.name))
  allow_auto_merge            = try(local.repository.allow_auto_merge, false)
  allow_merge_commit          = try(local.repository.allow_merge_commit, true)
  allow_rebase_merge          = try(local.repository.allow_rebase_merge, true)
  allow_squash_merge          = try(local.repository.allow_squash_merge, true)
  branch_protection           = try(local.repository.branch_protection, null)
  default_branch              = try(local.repository.default_branch, "main")
  enable_archived             = try(local.repository.enable_archived, false)
  enable_discussions          = try(local.repository.enable_discussions, false)
  enable_downloads            = try(local.repository.enable_downloads, false)
  enable_issues               = try(local.repository.enable_issues, true)
  enable_projects             = try(local.repository.enable_projects, false)
  enable_vulnerability_alerts = try(local.repository.enable_vulnerability_alerts, null)
  enable_wiki                 = try(local.repository.enable_wiki, false)
  homepage_url                = try(local.repository.homepage_url, null)
  topics                      = try(local.repository.topics, ["aws", "terraform", "landing-zone"])
  visibility                  = try(local.repository.visibility, "private")

  # Template settings
  template = var.infrastructure_repository.template != null ? {
    owner                = try(var.infrastructure_repository.template.owner, null)
    repository           = try(var.infrastructure_repository.template.repository, null)
    include_all_branches = try(var.infrastructure_repository.template.include_all_branches, null)
  } : null
}
