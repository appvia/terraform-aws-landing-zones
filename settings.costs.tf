
locals {
  ## Indicates if we should provision a cost anomaly detection monitor for the accounts 
  enable_cost_anomaly_detection = true

  ## The default cost anomaly detection monitors which should be configured in all accounts. Tenants 
  ## should add notification configuration to these monitors if they want to receive notifications; 
  ## They also have the permission to view, add and mark any anomalies as expected if required.
  costs_default_anomaly_monitors = [
    {
      name = "default-monitor-${local.region}"
      threshold_expression = [
        {
          and = {
            dimension = {
              key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
              match_options = ["GREATER_THAN_OR_EQUAL"]
              values        = ["50"]
            }
          }
        }
      ]

      specification = jsonencode({
        "And" : [
          {
            "Dimensions" : {
              "Key" : "REGION"
              "Values" : [local.region]
            }
          }
        ]
      })
    }
  ]
}