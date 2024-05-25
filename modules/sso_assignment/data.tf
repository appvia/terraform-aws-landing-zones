
## Get all the details on the sso users referenced 
data "aws_identitystore_user" "current" {
  for_each = toset(var.users)

  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

## Get all the details on the sso groups referenced 
data "aws_identitystore_group" "current" {
  for_each = toset(var.groups)

  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "GroupName"
      attribute_value = each.key
    }
  }
}

## Get all the details on the permissionset referenced 
data "aws_ssoadmin_permission_set" "current" {
  instance_arn = var.instance_arn
  name         = var.permissionset
}

