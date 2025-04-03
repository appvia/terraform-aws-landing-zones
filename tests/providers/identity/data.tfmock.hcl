mock_data "aws_ssoadmin_instances" {
  defaults = {
    instances = [
      {
        id     = "ssoins-1234567890abcdef0"
        name   = "default"
        status = "ACTIVE"
      }
    ]
    arns = [
      "arn:aws:sso:::instance/ssoins-1234567890abcdef0"
    ]
    identity_store_ids = [
      "ssoins-1234567890abcdeft"
    ]
  }
}
