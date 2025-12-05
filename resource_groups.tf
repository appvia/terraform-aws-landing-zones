#
## Description: related to the provisioning of resource groups in a cloud environment.
#

## Provision the resource groups
resource "aws_resourcegroups_group" "resource_groups" {
  for_each = var.resource_groups

  name        = each.key
  description = each.value.description
  tags        = merge(local.tags, { "Name" = each.key })
  dynamic "resource_query" {
    for_each = each.value.resource_query != null ? [1] : []

    content {
      type  = try(each.value.type, "TAG_FILTERS_1_0")
      query = each.value.resource_query
    }
  }

  dynamic "resource_query" {
    for_each = each.value.query != null ? [1] : []

    content {
      type = "TAG_FILTERS_1_0"
      query = jsonencode(yamldecode(templatefile("${path.module}/assets/resource_group_query.json.tmpl", {
        resource_type_filters = each.value.query.resource_type_filters
        tag_filters           = each.value.query.tag_filters
      })))
    }
  }

  dynamic "configuration" {
    for_each = each.value.configuration != null ? [1] : []

    content {
      type = each.value.configuration.type

      dynamic "parameters" {
        for_each = toset(each.value.configuration.parameters)

        content {
          name   = parameters.value.name
          values = parameters.value.values
        }
      }
    }
  }

  provider = aws.tenant
}
