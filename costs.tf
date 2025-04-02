
locals {
  ## Indicates if we should enable the cost anomaly detection monitors
  enable_anomaly_detection = var.cost_anomaly_detection.enable && length(var.cost_anomaly_detection.monitors) > 0

  ## List of cost anomaly detection monitors
  cost_anomaly_monitors = [
    for monitor in var.cost_anomaly_detection.monitors : {
      name              = monitor.name
      monitor_type      = "DIMENSIONAL"
      monitor_dimension = try(monitor.dimension, "SERVICE")
      specification     = try(monitor.specification, null)
      notify = {
        frequency            = try(monitor.frequency, "DAILY")
        threshold_expression = monitor.threshold_expression
      }
    }
  ]
}

## Provision the cost anomaly detection monitors
module "anomaly_detection" {
  count   = local.home_region && local.enable_anomaly_detection ? 1 : 0
  source  = "appvia/anomaly-detection/aws"
  version = "0.3.0"

  enable_notification_creation = false
  enable_sns_topic_creation    = false
  monitors                     = local.cost_anomaly_monitors
  sns_topic_arn                = module.notifications.sns_topic_arn
  tags                         = local.tags

  providers = {
    aws = aws.tenant
  }
}
