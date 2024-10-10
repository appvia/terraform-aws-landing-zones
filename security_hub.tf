
## Craft an IAM policy document to allow the lambda function to assume the role 
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    sid     = "AllowLambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

## Craft an IAM policy to push logs to cloudwatch log group 
# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "securityhub_lambda_cloudwatch_logs_policy" {
  statement {
    sid    = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

## Craft an IAM polciy perform access to publish messages to the SNS topic 
data "aws_iam_policy_document" "securityhub_notifications_policy" {
  count = local.enable_security_hub_events ? 1 : 0

  statement {
    sid       = "AllowPublish"
    actions   = ["sns:Publish"]
    effect    = "Allow"
    resources = [module.securityhub_notifications[0].sns_topic_arn]
  }
}

## Create the lambda function package from the source code
data "archive_file" "securityhub_lambda_package" {
  count = local.enable_security_hub_events ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/assets/functions/lambda_function.py"
  output_path = "./builds/securityhub-findings-forwarder.zip"
}

## Provision the notifications to forward the security hub findings to the messaging channel 
module "securityhub_notifications" {
  count   = local.enable_security_hub_events ? 1 : 0
  source  = "appvia/notifications/aws"
  version = "1.0.4"

  allowed_aws_services = ["events.amazonaws.com", "lambda.amazonaws.com"]
  create_sns_topic     = true
  email                = local.security_hub_email_addresses
  slack                = local.security_hub_slack
  sns_topic_name       = local.security_hub_sns_topic_name
  tags                 = local.tags

  providers = {
    aws = aws.tenant
  }
}

## Provision an IAM role for the lambda function to run under 
resource "aws_iam_role" "securityhub_lambda_role" {
  count = local.enable_security_hub_events ? 1 : 0

  name               = local.security_hub_lambda_role_name
  tags               = local.tags
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  provider = aws.tenant
}

## Attach the inline policy to the lambda role 
resource "aws_iam_role_policy" "securityhub_lambda_role_policy" {
  count = local.enable_security_hub_events ? 1 : 0

  name   = "lza-securityhub-lambda-policy"
  policy = data.aws_iam_policy_document.securityhub_notifications_policy[0].json
  role   = aws_iam_role.securityhub_lambda_role[0].name

  provider = aws.tenant
}

## Attach the inline policy to the lambda role 
resource "aws_iam_role_policy" "securityhub_lambda_logs_policy" {
  count = local.enable_security_hub_events ? 1 : 0

  name   = "lza-securityhub-lambda-logs-policy"
  policy = data.aws_iam_policy_document.securityhub_lambda_cloudwatch_logs_policy.json
  role   = aws_iam_role.securityhub_lambda_role[0].name

  provider = aws.tenant
}

## Provision a cloudwatch log group to capture the logs from the lambda function 
# tfsec:ignore:AVD-AWS-0017 (Log Group Customer Key)
resource "aws_cloudwatch_log_group" "securityhub_lambda_log_group" {
  count = local.enable_security_hub_events ? 1 : 0

  log_group_class   = "STANDARD"
  name              = "/aws/lambda/${local.security_hub_lambda_name}"
  retention_in_days = 3
  tags              = local.tags

  provider = aws.tenant
}

## Provision the lamda function to forward the security hub findings to the messaging channel  
# tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "securityhub_lambda_function" {
  count = local.enable_security_hub_events ? 1 : 0

  filename         = "./builds/securityhub-findings-forwarder.zip"
  function_name    = local.security_hub_lambda_name
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.securityhub_lambda_role[0].arn
  runtime          = "python3.12"
  source_code_hash = data.archive_file.securityhub_lambda_package[0].output_base64sha256
  tags             = local.tags
  timeout          = 5

  environment {
    variables = {
      "SNS_TOPIC_ARN" = module.securityhub_notifications[0].sns_topic_arn
    }
  }

  depends_on = [
    data.archive_file.securityhub_lambda_package,
    aws_cloudwatch_log_group.securityhub_lambda_log_group,
  ]

  provider = aws.tenant
}

## Allow eventbridge to invoke the lambda function
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

  name        = local.security_hub_eventbridge_rule_name
  description = "Capture Security Hub findings of a specific severities and publish to the SNS topic (LZA)"
  tags        = local.tags

  event_pattern = jsonencode({
    detail = {
      findings = {
        Compliance = {
          Status = ["FAILED"]
        },
        RecordState = ["ACTIVE"],
        Severity = {
          Label = local.security_hub_severity
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
