# GitHub Repository Module Example

This example demonstrates how to use the `github_repository` module to create and configure GitHub repositories with different settings and use cases.

## Overview

The example includes three different repository configurations:

1. **Basic Repository** - A standard private repository with common settings
2. **Public Repository** - An open source repository with public visibility
3. **Enterprise Repository** - A highly controlled enterprise repository with strict security policies

## Prerequisites

Before using this example, ensure you have:

- Terraform >= 1.0.0 installed
- GitHub provider configured with appropriate permissions
- GitHub organization access
- GitHub personal access token or GitHub App authentication

## Authentication

Configure the GitHub provider in your `providers.tf`:

```hcl
provider "github" {
  owner = "your-organization"  # Use 'owner' instead of deprecated 'organization'
  token = var.github_token     # Use environment variable or variable
}
```

## Usage

### Basic Usage

To create a basic repository:

```hcl
module "my_repository" {
  source = "../../modules/github_repository"

  repository   = "my-project"
  description  = "My awesome project"
}
```

### Advanced Usage

For more control, you can customize various settings:

```hcl
module "my_repository" {
  source = "../../modules/github_repository"

  repository   = "my-advanced-project"
  description  = "Advanced project with custom settings"
  
  # Repository settings
  visibility = "private"
  default_branch = "main"
  
  # Security settings
  vulnerability_alerts = true  # Automatically enabled by default
  
  # Merge settings
  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true
  allow_auto_merge = false
  delete_branch_on_merge = true
  
  # Branch protection
  enforce_branch_protection_for_admins = true
  required_approving_review_count = 2
  dismiss_stale_reviews = true
  prevent_self_review = true
  
  # Status checks
  required_status_checks = [
    "CI / Build and Test",
    "Security / Security Scan"
  ]
  
  # Environments
  repository_environments = ["staging", "production"]
  default_environment_review_users = ["admin-user"]
  default_environment_review_teams = ["platform-team"]
  
  # Collaborators
  repository_collaborators = [
    {
      username   = "developer1"
      permission = "write"
    }
  ]
  
  # Topics
  repository_topics = ["terraform", "aws", "infrastructure"]
}
```

## Examples Included

### 1. Basic Repository

A standard private repository with:

- Private visibility
- Branch protection enabled
- Required status checks
- Environment protection
- Collaborator management
- Repository topics
- Vulnerability alerts enabled
- Signed commits required

### 2. Public Repository

An open source repository with:

- Public visibility
- More permissive merge settings
- Custom status checks for open source
- No environment protection
- Open source topics

### 3. Enterprise Repository

A highly controlled enterprise repository with:

- Private visibility
- Strict branch protection
- Multiple required reviewers
- Comprehensive status checks
- Multiple environments with reviewers
- Bypass allowances for emergencies
- Enterprise-specific topics
- Vulnerability alerts enabled
- Signed commits required
- Self-review prevention

## Variables

The example includes comprehensive variables for customization:

- `github_organization` - GitHub organization name
- `enable_*_repository` - Toggle specific repository examples
- `*_repository_name` - Repository names
- `*_repository_description` - Repository descriptions
- `*_repository_collaborators` - Repository collaborators
- `*_repository_topics` - Repository topics
- `*_repository_environments` - Repository environments
- `*_required_status_checks` - Required status checks
- And many more...

## Outputs

The example provides useful outputs:

- Repository names and URLs
- Repository visibility and default branch
- Environment configurations
- Collaborator lists
- Topic lists
- Summary information

## Running the Example

1. Clone the repository
2. Navigate to the example directory
3. Copy `providers.tf.example` to `providers.tf` and configure
4. Customize variables in `variables.tf` or create a `terraform.tfvars` file
5. Initialize Terraform:

   ```bash
   terraform init
   ```

6. Plan the deployment:

   ```bash
   terraform plan
   ```

7. Apply the configuration:

   ```bash
   terraform apply
   ```

## Customization

### Repository Templates

The module supports GitHub repository templates:

```hcl
enable_repository_template = true
repository_template = "terraform-aws-pipeline-template"
organization_template = "your-organization"
```

### Branch Protection

Configure branch protection rules:

```hcl
enforce_branch_protection_for_admins = true
required_approving_review_count = 2
dismiss_stale_reviews = true
prevent_self_review = true
```

### Status Checks

Define required status checks:

```hcl
required_status_checks = [
  "CI / Build and Test",
  "Security / Security Scan",
  "Code Quality / Lint"
]
```

### Environments

Set up deployment environments:

```hcl
repository_environments = ["staging", "production"]
default_environment_review_users = ["admin-user"]
default_environment_review_teams = ["platform-team"]
```

### Collaborators

Manage repository access:

```hcl
repository_collaborators = [
  {
    username   = "developer1"
    permission = "write"
  },
  {
    username   = "admin-user"
    permission = "admin"
  }
]
```

## Security Features

This module implements comprehensive security features:

### Automatic Security Features

- **Vulnerability Alerts**: Automatically enabled for all repositories
- **Signed Commits**: Required for all changes to protected branches
- **Branch Protection**: Enforced for all repositories with configurable rules

### Configurable Security Features

- **Required Reviews**: Set minimum number of reviewers for pull requests
- **Status Checks**: Require specific CI/CD checks before merging
- **Environment Protection**: Protect deployment environments with reviewers
- **Self-Review Prevention**: Prevent users from approving their own changes
- **Bypass Allowances**: Configure emergency access for critical situations

### Access Control

- **Collaborator Management**: Granular permission control (read, write, admin)
- **Team-based Access**: Support for team-based collaboration
- **Review Dismissal**: Control who can dismiss reviews and when

## Security Considerations

- Use least privilege principle for collaborators
- Enable branch protection for all repositories
- Require status checks for all changes
- Use environment protection for production deployments
- Regularly review and audit repository access
- Enable vulnerability alerts for security scanning
- Use signed commits for enhanced security
- Configure appropriate bypass allowances for emergencies

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Ensure your GitHub token has the necessary permissions
   - Required scopes: `repo`, `admin:org`, `admin:repo_hook`
   - For organizations: `admin:org_hook` scope may be needed

2. **Organization Access**: Verify you have admin access to the organization
   - Check that your token has organization admin permissions
   - Ensure the organization allows repository creation

3. **Repository Name Conflicts**: Ensure repository names are unique within the organization
   - Repository names must be unique within the organization
   - Check for existing repositories with the same name

4. **Status Check Names**: Verify status check names match exactly with your CI/CD setup
   - Status check names are case-sensitive
   - Ensure your CI/CD system is configured with the exact same names

5. **Branch Protection Issues**: Common branch protection problems
   - Ensure the default branch exists before applying branch protection
   - Check that required status checks are properly configured in your CI/CD

6. **Environment Protection**: Issues with environment configuration
   - Ensure environment names don't conflict with existing environments
   - Verify reviewer users/teams exist in the organization

7. **Collaborator Permissions**: Problems with collaborator access
   - Ensure collaborator usernames are correct and exist
   - Check that permission levels are valid (read, write, admin)

### Debugging

Enable Terraform debug logging:

```bash
export TF_LOG=DEBUG
terraform apply
```

## Contributing

When contributing to this example:

1. Follow the existing code style
2. Add comprehensive comments
3. Update documentation
4. Test with different configurations
5. Ensure all examples are functional

## License

This example is part of the terraform-aws-landing-zones project and follows the same license terms.

<!-- BEGIN_TF_DOCS -->
## Providers

No providers.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_basic_repository_collaborators"></a> [basic\_repository\_collaborators](#input\_basic\_repository\_collaborators) | Collaborators for the basic repository | <pre>list(object({<br/>    username   = string<br/>    permission = optional(string, "write")<br/>  }))</pre> | <pre>[<br/>  {<br/>    "permission": "write",<br/>    "username": "developer1"<br/>  },<br/>  {<br/>    "permission": "write",<br/>    "username": "developer2"<br/>  }<br/>]</pre> | no |
| <a name="input_basic_repository_environments"></a> [basic\_repository\_environments](#input\_basic\_repository\_environments) | Environments for the basic repository | `list(string)` | <pre>[<br/>  "staging",<br/>  "production"<br/>]</pre> | no |
| <a name="input_basic_repository_name"></a> [basic\_repository\_name](#input\_basic\_repository\_name) | Name for the basic repository | `string` | `"my-terraform-project"` | no |
| <a name="input_basic_repository_topics"></a> [basic\_repository\_topics](#input\_basic\_repository\_topics) | Topics for the basic repository | `list(string)` | <pre>[<br/>  "terraform",<br/>  "aws",<br/>  "infrastructure",<br/>  "iac"<br/>]</pre> | no |
| <a name="input_enable_basic_repository"></a> [enable\_basic\_repository](#input\_enable\_basic\_repository) | Whether to create the basic repository example | `bool` | `true` | no |
| <a name="input_enable_enterprise_repository"></a> [enable\_enterprise\_repository](#input\_enable\_enterprise\_repository) | Whether to create the enterprise repository example | `bool` | `false` | no |
| <a name="input_enable_public_repository"></a> [enable\_public\_repository](#input\_enable\_public\_repository) | Whether to create the public repository example | `bool` | `false` | no |
| <a name="input_enterprise_repository_collaborators"></a> [enterprise\_repository\_collaborators](#input\_enterprise\_repository\_collaborators) | Collaborators for the enterprise repository | <pre>list(object({<br/>    username   = string<br/>    permission = optional(string, "write")<br/>  }))</pre> | <pre>[<br/>  {<br/>    "permission": "admin",<br/>    "username": "senior-dev1"<br/>  },<br/>  {<br/>    "permission": "admin",<br/>    "username": "senior-dev2"<br/>  },<br/>  {<br/>    "permission": "write",<br/>    "username": "junior-dev1"<br/>  },<br/>  {<br/>    "permission": "write",<br/>    "username": "junior-dev2"<br/>  }<br/>]</pre> | no |
| <a name="input_enterprise_repository_environments"></a> [enterprise\_repository\_environments](#input\_enterprise\_repository\_environments) | Environments for the enterprise repository | `list(string)` | <pre>[<br/>  "dev",<br/>  "staging",<br/>  "production"<br/>]</pre> | no |
| <a name="input_enterprise_repository_name"></a> [enterprise\_repository\_name](#input\_enterprise\_repository\_name) | Name for the enterprise repository | `string` | `"enterprise-critical-system"` | no |
| <a name="input_enterprise_repository_topics"></a> [enterprise\_repository\_topics](#input\_enterprise\_repository\_topics) | Topics for the enterprise repository | `list(string)` | <pre>[<br/>  "enterprise",<br/>  "terraform",<br/>  "aws",<br/>  "critical",<br/>  "compliance"<br/>]</pre> | no |
| <a name="input_enterprise_required_approving_review_count"></a> [enterprise\_required\_approving\_review\_count](#input\_enterprise\_required\_approving\_review\_count) | Required approving review count for the enterprise repository | `number` | `3` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | The GitHub organization where repositories will be created | `string` | `"my-organization"` | no |
| <a name="input_public_repository_name"></a> [public\_repository\_name](#input\_public\_repository\_name) | Name for the public repository | `string` | `"my-open-source-project"` | no |
| <a name="input_public_repository_topics"></a> [public\_repository\_topics](#input\_public\_repository\_topics) | Topics for the public repository | `list(string)` | <pre>[<br/>  "open-source",<br/>  "terraform",<br/>  "aws",<br/>  "community"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_repository_names"></a> [all\_repository\_names](#output\_all\_repository\_names) | List of all created repository names |
| <a name="output_all_repository_urls"></a> [all\_repository\_urls](#output\_all\_repository\_urls) | List of all created repository URLs |
| <a name="output_basic_repository_collaborators"></a> [basic\_repository\_collaborators](#output\_basic\_repository\_collaborators) | The collaborators of the basic repository |
| <a name="output_basic_repository_default_branch"></a> [basic\_repository\_default\_branch](#output\_basic\_repository\_default\_branch) | The default branch of the basic repository |
| <a name="output_basic_repository_environments"></a> [basic\_repository\_environments](#output\_basic\_repository\_environments) | The environments configured for the basic repository |
| <a name="output_basic_repository_name"></a> [basic\_repository\_name](#output\_basic\_repository\_name) | The name of the basic repository |
| <a name="output_basic_repository_ssh_url"></a> [basic\_repository\_ssh\_url](#output\_basic\_repository\_ssh\_url) | The SSH URL of the basic repository |
| <a name="output_basic_repository_topics"></a> [basic\_repository\_topics](#output\_basic\_repository\_topics) | The topics of the basic repository |
| <a name="output_basic_repository_url"></a> [basic\_repository\_url](#output\_basic\_repository\_url) | The URL of the basic repository |
| <a name="output_basic_repository_visibility"></a> [basic\_repository\_visibility](#output\_basic\_repository\_visibility) | The visibility of the basic repository |
| <a name="output_enterprise_repository_collaborators"></a> [enterprise\_repository\_collaborators](#output\_enterprise\_repository\_collaborators) | The collaborators of the enterprise repository |
| <a name="output_enterprise_repository_default_branch"></a> [enterprise\_repository\_default\_branch](#output\_enterprise\_repository\_default\_branch) | The default branch of the enterprise repository |
| <a name="output_enterprise_repository_environments"></a> [enterprise\_repository\_environments](#output\_enterprise\_repository\_environments) | The environments configured for the enterprise repository |
| <a name="output_enterprise_repository_name"></a> [enterprise\_repository\_name](#output\_enterprise\_repository\_name) | The name of the enterprise repository |
| <a name="output_enterprise_repository_required_approving_review_count"></a> [enterprise\_repository\_required\_approving\_review\_count](#output\_enterprise\_repository\_required\_approving\_review\_count) | The required approving review count for the enterprise repository |
| <a name="output_enterprise_repository_ssh_url"></a> [enterprise\_repository\_ssh\_url](#output\_enterprise\_repository\_ssh\_url) | The SSH URL of the enterprise repository |
| <a name="output_enterprise_repository_topics"></a> [enterprise\_repository\_topics](#output\_enterprise\_repository\_topics) | The topics of the enterprise repository |
| <a name="output_enterprise_repository_url"></a> [enterprise\_repository\_url](#output\_enterprise\_repository\_url) | The URL of the enterprise repository |
| <a name="output_enterprise_repository_visibility"></a> [enterprise\_repository\_visibility](#output\_enterprise\_repository\_visibility) | The visibility of the enterprise repository |
| <a name="output_public_repository_default_branch"></a> [public\_repository\_default\_branch](#output\_public\_repository\_default\_branch) | The default branch of the public repository |
| <a name="output_public_repository_name"></a> [public\_repository\_name](#output\_public\_repository\_name) | The name of the public repository |
| <a name="output_public_repository_ssh_url"></a> [public\_repository\_ssh\_url](#output\_public\_repository\_ssh\_url) | The SSH URL of the public repository |
| <a name="output_public_repository_topics"></a> [public\_repository\_topics](#output\_public\_repository\_topics) | The topics of the public repository |
| <a name="output_public_repository_url"></a> [public\_repository\_url](#output\_public\_repository\_url) | The URL of the public repository |
| <a name="output_public_repository_visibility"></a> [public\_repository\_visibility](#output\_public\_repository\_visibility) | The visibility of the public repository |
| <a name="output_repository_count"></a> [repository\_count](#output\_repository\_count) | Total number of repositories created |
<!-- END_TF_DOCS -->