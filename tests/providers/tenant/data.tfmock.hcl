
mock_data "aws_region" {
  defaults = {
    name   = "eu-west-2"
    region = "eu-west-2"
  }
}

mock_data "aws_caller_identity" {
  defaults = {
    account_id = "123456781000"
    arn        = "arn:aws:iam::123456781000:role/role-name"
  }
}

mock_data "aws_partition" {
  defaults = {
    partition = "aws"
  }
}
