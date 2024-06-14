##
## Note, the user facing locals can be found in the settings.<feature>.tf files, these are these
## are the locals which are used to internally and should not be changed by the tenant. 
##

locals {
  ##
  ### Cost and budgeting related locals 
  ##

  ## This the default cost anomaly detection monitors defined within the settings conbined with the 
  ## additional monitors defined by the tenant.
  costs_anomaly_monitors_merged = concat(local.costs_default_anomaly_monitors, try(var.anomaly_detection.monitors, []))

  ## We need to convert the cost anomaly detection monitors into the format expected by the module, internally
  ## iterate over the merged list and create a new list of the required format.
  costs_anomaly_monitors = [
    for monitor in local.costs_anomaly_monitors_merged : {
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

  ## Indicates if cost anomaly detection monitors should be enabled
  enable_anomaly_detection = local.enable_cost_anomaly_detection && length(local.costs_anomaly_monitors) > 0
}
