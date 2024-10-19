#
## Used to configure the guardduty account settings 
#

## Provision a guardduty detector for this account - currently this is not 
## supporting ipsets, threatintelsets, or publishing findings to s3
#module "guardduty_detector" {
#  count   = var.guardduty.enabled ? 1 : 0
#  source  = "aws-ia/guardduty/aws"
#  version = "0.0.2"
#
#  enable_guardduty             = true
#  enable_s3_protection         = var.guardduty.enable_s3_protection
#  enable_kubernetes_protection = var.guardduty.enable_kubernetes_protection
#  enable_malware_protection    = var.guardduty.enable_malware_protection
#  enable_snapshot_retention    = var.guardduty.enable_snapshot_retention
#  finding_publishing_frequency = var.guardduty.finding_publishing_frequency
#  tags                         = var.tags
#}
