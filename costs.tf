
## Provision the cost anomaly detection monitors 
module "anomaly_detection" {
  count   = local.enable_anomaly_detection ? 1 : 0
  source  = "appvia/anomaly-detection/aws"
  version = "0.2.1"

  enable_notification_creation = false
  enable_sns_topic_creation    = false
  notifications                = {}
  monitors                     = local.costs_anomaly_monitors
  sns_topic_arn                = module.notifications.sns_topic_arn
  tags                         = local.tags

  providers = {
    aws = aws.tenant
  }
}
