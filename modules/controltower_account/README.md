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
| <a name="input_service_catalog_provisioning_artifact_id"></a> [service\_catalog\_provisioning\_artifact\_id](#input\_service\_catalog\_provisioning\_artifact\_id) | The ID of the Service Catalog provisioning artifact to use for account creation | `string` | n/a | yes |
| <a name="input_sso_user_first_name"></a> [sso\_user\_first\_name](#input\_sso\_user\_first\_name) | The first name of the SSO user to create | `string` | n/a | yes |
| <a name="input_sso_user_last_name"></a> [sso\_user\_last\_name](#input\_sso\_user\_last\_name) | The last name of the SSO user to create | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | n/a | yes |
| <a name="input_service_catalog_product_id"></a> [service\_catalog\_product\_id](#input\_service\_catalog\_product\_id) | The ID of the Service Catalog provisioning artifact to use for account creation | `string` | `null` | no |
| <a name="input_service_catalog_product_name"></a> [service\_catalog\_product\_name](#input\_service\_catalog\_product\_name) | The name of the Service Catalog product to use for account creation | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_email"></a> [account\_email](#output\_account\_email) | The email address associated to the account |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account ID of the provisioned account |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the provisioned service catalog product |
| <a name="output_id"></a> [id](#output\_id) | The ID of the provisioned service catalog product |
| <a name="output_name"></a> [name](#output\_name) | The name of the provisioned service catalog product |
| <a name="output_product_id"></a> [product\_id](#output\_product\_id) | The ID of the product used to provision the service catalog product |
| <a name="output_provisioning_artifact_id"></a> [provisioning\_artifact\_id](#output\_provisioning\_artifact\_id) | The ID of the provisioning artifact used to provision the service catalog product |
| <a name="output_provisioning_artifact_name"></a> [provisioning\_artifact\_name](#output\_provisioning\_artifact\_name) | The name of the provisioning artifact used to provision the service catalog product |
| <a name="output_status"></a> [status](#output\_status) | The status of the provisioned service catalog product |
<!-- END_TF_DOCS -->