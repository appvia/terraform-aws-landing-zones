
## Find the current context 
data "aws_caller_identity" "current" {}

## Find the current session context
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}
