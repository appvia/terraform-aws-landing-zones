## Related to the provisioning the iam profiles

locals {
  ## A map of instance_profile -> iam permission_arn
  instance_profiles = local.home_region ? flatten([
    for name, profile in var.iam_instance_profiles : [
      for policy_arn in profile.permission_arns : {
        name           = name
        path           = profile.path
        permission_arn = policy_arn
      }
    ]
  ]) : []

  instance_profiles_map = local.home_region ? merge({
    for x in local.instance_profiles : format("%s-%s", x.name, x.permission_arn) => {
      permission_arn = x.permission_arn
      role_name      = x.name
    }
  }) : {}
}

## Provision one of more IAM profiles
resource "aws_iam_role" "instance_profiles" {
  for_each = var.iam_instance_profiles

  name = each.value.name
  path = each.value.path
  tags = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  provider = aws.tenant
}

## Provision the instance profile for us
resource "aws_iam_instance_profile" "instance_profiles" {
  for_each = var.iam_instance_profiles

  name = each.value.name
  role = aws_iam_role.instance_profiles[each.key].name
  tags = local.tags

  provider = aws.tenant
}

## Associate the permissions with each of the instance roles
resource "aws_iam_role_policy_attachment" "instance_profiles" {
  for_each = local.instance_profiles_map

  policy_arn = each.value.permission_arn
  role       = aws_iam_role.instance_profiles[each.value.role_name].id

  provider = aws.tenant
}
