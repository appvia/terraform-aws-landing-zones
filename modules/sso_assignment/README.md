<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_account_assignment.groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_account_assignment.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_identitystore_group.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_user.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_ssoadmin_permission_set.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_permission_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_identity_store_id"></a> [identity\_store\_id](#input\_identity\_store\_id) | The ID for the identity store | `string` | n/a | yes |
| <a name="input_instance_arn"></a> [instance\_arn](#input\_instance\_arn) | The ARN for the identity center instance | `string` | n/a | yes |
| <a name="input_permissionset"></a> [permissionset](#input\_permissionset) | The name of the permissionset to assign | `string` | n/a | yes |
| <a name="input_target"></a> [target](#input\_target) | The list of targets (accounts) to assign the permissionset | `string` | n/a | yes |
| <a name="input_groups"></a> [groups](#input\_groups) | The list of groups to assign the permissionset | `list(string)` | `null` | no |
| <a name="input_users"></a> [users](#input\_users) | The list of users to assign the permissionset | `list(string)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->