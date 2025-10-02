<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_repository"></a> [repository](#input\_repository) | The name of the repository to provision | `string` | n/a | yes |
| <a name="input_allow_auto_merge"></a> [allow\_auto\_merge](#input\_allow\_auto\_merge) | Allow auto merges within repositories | `bool` | `false` | no |
| <a name="input_allow_merge_commit"></a> [allow\_merge\_commit](#input\_allow\_merge\_commit) | Allow merge commits within repositories | `bool` | `true` | no |
| <a name="input_allow_rebase_merge"></a> [allow\_rebase\_merge](#input\_allow\_rebase\_merge) | Allow rebase merges within repositories | `bool` | `true` | no |
| <a name="input_allow_squash_merge"></a> [allow\_squash\_merge](#input\_allow\_squash\_merge) | Allow squash merges within repositories | `bool` | `true` | no |
| <a name="input_bypass_pull_request_allowances_apps"></a> [bypass\_pull\_request\_allowances\_apps](#input\_bypass\_pull\_request\_allowances\_apps) | The apps to bypass pull request allowances | `list(string)` | `[]` | no |
| <a name="input_bypass_pull_request_allowances_teams"></a> [bypass\_pull\_request\_allowances\_teams](#input\_bypass\_pull\_request\_allowances\_teams) | The teams to bypass pull request allowances | `list(string)` | `[]` | no |
| <a name="input_bypass_pull_request_allowances_users"></a> [bypass\_pull\_request\_allowances\_users](#input\_bypass\_pull\_request\_allowances\_users) | The users to bypass pull request allowances | `list(string)` | `[]` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | The default branch of the repository to provision | `string` | `"main"` | no |
| <a name="input_default_environment_review_teams"></a> [default\_environment\_review\_teams](#input\_default\_environment\_review\_teams) | The teams reviewers to apply to the production environment | `list(string)` | `[]` | no |
| <a name="input_default_environment_review_users"></a> [default\_environment\_review\_users](#input\_default\_environment\_review\_users) | The user reviewers to apply to the production environment | `list(string)` | `[]` | no |
| <a name="input_delete_branch_on_merge"></a> [delete\_branch\_on\_merge](#input\_delete\_branch\_on\_merge) | The delete branch on merge of the repository to provision | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the repository to provision | `string` | `"Terraform AWS Pipeline"` | no |
| <a name="input_dismiss_stale_reviews"></a> [dismiss\_stale\_reviews](#input\_dismiss\_stale\_reviews) | Indicates a review will be dismissed if it becomes stale | `bool` | `true` | no |
| <a name="input_dismissal_apps"></a> [dismissal\_apps](#input\_dismissal\_apps) | The apps to dismiss reviews | `list(string)` | `[]` | no |
| <a name="input_dismissal_teams"></a> [dismissal\_teams](#input\_dismissal\_teams) | The teams to dismiss reviews | `list(string)` | `[]` | no |
| <a name="input_dismissal_users"></a> [dismissal\_users](#input\_dismissal\_users) | The users to dismiss reviews | `list(string)` | `[]` | no |
| <a name="input_enable_repository_template"></a> [enable\_repository\_template](#input\_enable\_repository\_template) | The enable repository template of the repository to provision | `bool` | `true` | no |
| <a name="input_enforce_branch_protection_for_admins"></a> [enforce\_branch\_protection\_for\_admins](#input\_enforce\_branch\_protection\_for\_admins) | Indicates the branch protection is enforced for admins | `bool` | `true` | no |
| <a name="input_organization_template"></a> [organization\_template](#input\_organization\_template) | The organization template of the repository to provision | `string` | `"appvia"` | no |
| <a name="input_prevent_self_review"></a> [prevent\_self\_review](#input\_prevent\_self\_review) | Indicates a user cannot approve their own pull requests | `bool` | `true` | no |
| <a name="input_repository_collaborators"></a> [repository\_collaborators](#input\_repository\_collaborators) | The GitHub user or organization to create the repositories under | <pre>list(object({<br/>    username   = string<br/>    permission = optional(string, "write")<br/>  }))</pre> | `[]` | no |
| <a name="input_repository_environments"></a> [repository\_environments](#input\_repository\_environments) | The production environment to use within repositories | `list(string)` | <pre>[<br/>  "production"<br/>]</pre> | no |
| <a name="input_repository_template"></a> [repository\_template](#input\_repository\_template) | The repository template of the repository to provision | `string` | `"terraform-aws-pipeline-template"` | no |
| <a name="input_repository_topics"></a> [repository\_topics](#input\_repository\_topics) | The topics to apply to the repositories | `list(string)` | <pre>[<br/>  "aws",<br/>  "terraform",<br/>  "landing-zone"<br/>]</pre> | no |
| <a name="input_required_approving_review_count"></a> [required\_approving\_review\_count](#input\_required\_approving\_review\_count) | The number of approving reviews required | `number` | `1` | no |
| <a name="input_required_status_checks"></a> [required\_status\_checks](#input\_required\_status\_checks) | The status checks to require within repositories | `list(string)` | <pre>[<br/>  "Terraform / Terraform Plan and Apply / Commitlint",<br/>  "Terraform / Terraform Plan and Apply / Terraform Format",<br/>  "Terraform / Terraform Plan and Apply / Terraform Lint",<br/>  "Terraform / Terraform Plan and Apply / Terraform Plan",<br/>  "Terraform / Terraform Plan and Apply / Terraform Security",<br/>  "Terraform / Terraform Plan and Apply / Terraform Validate"<br/>]</pre> | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | The visibility of the repository to provision | `string` | `"private"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->