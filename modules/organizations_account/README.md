<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_email"></a> [account\_email](#input\_account\_email) | The email address of the account to create | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | The name of the account to create | `string` | n/a | yes |
| <a name="input_organizational_unit_id"></a> [organizational\_unit\_id](#input\_organizational\_unit\_id) | The organizational unit id where the account should be created | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_close_on_deletion"></a> [close\_on\_deletion](#input\_close\_on\_deletion) | Whether to close the account when it is deleted from the organization | `bool` | `null` | no |
| <a name="input_enable_iam_billing_access"></a> [enable\_iam\_billing\_access](#input\_enable\_iam\_billing\_access) | Whether to allow IAM users to access billing information | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_arn"></a> [account\_arn](#output\_account\_arn) | The ARN of the account |
| <a name="output_account_email"></a> [account\_email](#output\_account\_email) | The email address of the account |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The ID of the account |
| <a name="output_account_name"></a> [account\_name](#output\_account\_name) | The name of the account |
| <a name="output_account_status"></a> [account\_status](#output\_account\_status) | The status of the account |
<!-- END_TF_DOCS -->