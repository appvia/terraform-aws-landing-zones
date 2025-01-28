
locals {
  ## Indicates if we should provision notiications for security hub events
  enable_security_hub_events = var.notifications.services.securityhub.enable
}

## Provision the event bridge rule to capture security hub findings, of a specific severities
resource "aws_cloudwatch_event_rule" "securityhub_findings" {
  count = local.enable_security_hub_events ? 1 : 0

  name        = format("%s-%s", var.notifications.services.securityhub.eventbridge_rule_name, local.region)
  description = "Capture Security Hub findings of a specific severities and publish to the SNS topic"
  tags        = local.tags

  event_pattern = jsonencode({
    detail = {
      findings = {
        Compliance = {
          Status = ["FAILED"]
        },
        RecordState = ["ACTIVE"],
        Severity = {
          Label = var.notifications.services.securityhub.severity
        },
        Workflow = {
          Status = ["NEW"]
        }
      }
    },
    detail-type = ["Security Hub Findings - Imported"],
    source      = ["aws.securityhub"]
  })

  provider = aws.tenant
}

## Provision a target to the event bridge rule, to publish messages to the SNS topic
resource "aws_cloudwatch_event_target" "security_hub_findings_target" {
  count = local.enable_security_hub_events ? 1 : 0

  arn  = module.notifications.sns_topic_arn
  rule = aws_cloudwatch_event_rule.securityhub_findings[0].name

  provider = aws.tenant

  depends_on = [
    module.notifications,
  ]
}
