![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform <NAME>

## Description

Add a description of the module here

## Usage

Add example usage here

```hcl
module "example" {
  source  = "appvia/<NAME>/aws"
  version = "0.0.1"

  # insert variables here
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_base_role_name"></a> [iam\_base\_role\_name](#output\_iam\_base\_role\_name) | The base name of the IAM role you are using to run this module |
| <a name="output_iam_identity_role_name"></a> [iam\_identity\_role\_name](#output\_iam\_identity\_role\_name) | The name of the IAM role you should use to interact with the identity account |
| <a name="output_iam_network_role_name"></a> [iam\_network\_role\_name](#output\_iam\_network\_role\_name) | The name of the IAM role you should use to interact with the connectivity account |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role you are using to run this module |
<!-- END_TF_DOCS -->
