
locals {
  ## Indicates if we should provision notiications for security hub events
  enable_security_hub_events = var.notifications.services.securityhub.enable
}

## Create the lambda function package from the source code
data "archive_file" "securityhub_lambda_package" {
  count = local.enable_security_hub_events ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/assets/functions/lambda_function.py"
  output_path = "./builds/securityhub-findings-forwarder.zip"
}

## Provision an IAM role for the lambda function to use when running
resource "aws_iam_role" "securityhub_lambda_role" {
  count = local.enable_security_hub_events ? 1 : 0

  name = format("%s-%s", var.notifications.services.securityhub.lambda_role_name, local.region)
  tags = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  provider = aws.tenant
}

## Attach the inline policy to the lambda role
resource "aws_iam_role_policy" "securityhub_lambda_role_policy" {
  count = local.enable_security_hub_events ? 1 : 0

  name = format("%s-%s", var.notifications.services.securityhub.lambda_role_name, local.region)
  role = aws_iam_role.securityhub_lambda_role[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowPublish"
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = [module.notifications.sns_topic_arn]
      },
      {
        Sid    = "AllowLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })

  depends_on = [
    aws_iam_role.securityhub_lambda_role,
    module.notifications,
  ]

  provider = aws.tenant
}

## Provision a cloudwatch log group to capture the logs from the lambda function
# tfsec:ignore:AVD-AWS-0017 (Log Group Customer Key)
resource "aws_cloudwatch_log_group" "securityhub_lambda_log_group" {
  count = local.enable_security_hub_events ? 1 : 0

  log_group_class   = "STANDARD"
  name              = format("/aws/lambda/%s", var.notifications.services.securityhub.lambda_role_name)
  retention_in_days = 3
  tags              = local.tags

  provider = aws.tenant
}

## Provision the lamda function to forward the security hub findings to the messaging channel
# tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "securityhub_lambda_function" {
  count = local.enable_security_hub_events ? 1 : 0

  filename         = "./builds/securityhub-findings-forwarder.zip"
  function_name    = format("%s", var.notifications.services.securityhub.lambda_role_name)
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.securityhub_lambda_role[0].arn
  runtime          = "python3.12"
  source_code_hash = data.archive_file.securityhub_lambda_package[0].output_base64sha256
  tags             = local.tags
  timeout          = 5

  environment {
    variables = {
      "DEBUG"         = "false"
      "SNS_TOPIC_ARN" = module.notifications.sns_topic_arn
    }
  }

  depends_on = [
    data.archive_file.securityhub_lambda_package,
    aws_cloudwatch_log_group.securityhub_lambda_log_group,
  ]

  provider = aws.tenant
}

## Configure an eventbridge rule to invoke the lambda function when a security hub
## finding is detected
resource "aws_lambda_permission" "securityhub_event_bridge" {
  count = local.enable_security_hub_events ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.securityhub_lambda_function[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.securityhub_findings[0].arn
  statement_id  = "AllowExecutionFromEventBridge"

  provider = aws.tenant
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

  arn       = aws_lambda_function.securityhub_lambda_function[0].arn
  rule      = aws_cloudwatch_event_rule.securityhub_findings[0].name
  target_id = "security_hub_findings_target"

  provider = aws.tenant
}
