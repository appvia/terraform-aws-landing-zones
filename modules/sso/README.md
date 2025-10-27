<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The account ID to assign the permissionset | `string` | n/a | yes |
| <a name="input_identity_store_id"></a> [identity\_store\_id](#input\_identity\_store\_id) | The identity store ID for the identity center instance | `string` | n/a | yes |
| <a name="input_instance_arn"></a> [instance\_arn](#input\_instance\_arn) | The ARN for the identity center instance | `string` | n/a | yes |
| <a name="input_permission_set_name"></a> [permission\_set\_name](#input\_permission\_set\_name) | The name of the permissionset to assign | `string` | n/a | yes |
| <a name="input_groups"></a> [groups](#input\_groups) | The list of groups to assign the permissionset | `list(string)` | `null` | no |
| <a name="input_users"></a> [users](#input\_users) | The list of users to assign the permissionset | `list(string)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->