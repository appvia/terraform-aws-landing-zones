
mock_data "aws_organizations_organization" {
  defaults = {
    roots = [
      {
        id = "r-1234567890abcdef0"
      }
    ]
  }
}
