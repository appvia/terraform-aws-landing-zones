locals {
  ## Indicates if we should enable the cost anomaly detection monitors
  enable_aws_config = var.aws_config.enable && length(var.aws_config.compliance_packs) > 0
}

## Provision one of more AWS Config Conformance Packs with in the account
resource "aws_config_conformance_pack" "default" {
  for_each = local.enable_aws_config ? var.aws_config.compliance_packs : {}

  name = each.key

  dynamic "input_parameter" {
    for_each = each.value.parameters

    content {
      parameter_name  = input_parameter.key
      parameter_value = input_parameter.value
    }
  }

  template_body = each.value.template_body
}
