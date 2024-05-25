<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.11.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dev_apps"></a> [dev\_apps](#module\_dev\_apps) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | The region to deploy the resources | `string` | `"eu-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | <pre>{<br>  "Environment": "dev"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->