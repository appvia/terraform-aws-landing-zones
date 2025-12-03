#
## Configuration related to the SSM service
##

## Configure the SSM service setting to block public sharing
resource "aws_ssm_service_setting" "ssm_service_setting_block_public_sharing" {
  region        = local.region
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = var.ssm.enable_block_public_sharing ? "Enable" : "Disable"

  provider = aws.tenant
}
