![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform <NAME>

## Description

Add a description of the module here

## Usage

Add example usage here

```hcl
module "example" {
  source  = "appvia/<NAME>/aws"
  version = "0.0.1"

  # insert variables here
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_aws.identity"></a> [aws.identity](#provider\_aws.identity) | >= 5.0.0 |
| <a name="provider_aws.network"></a> [aws.network](#provider\_aws.network) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_anomaly_detection"></a> [anomaly\_detection](#module\_anomaly\_detection) | appvia/anomaly-detection/aws | 0.2.0 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | 3.0.0 |
| <a name="module_networks"></a> [networks](#module\_networks) | appvia/network/aws | 0.3.0 |
| <a name="module_notifications"></a> [notifications](#module\_notifications) | appvia/notifications/aws | 0.1.4 |
| <a name="module_tagging"></a> [tagging](#module\_tagging) | appvia/tagging/null | 0.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_networkfirewall_rule_group.firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_route53_zone.zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_route53_zone_association.central_dns_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret.slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssoadmin_instances.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_vpc_ipam_pools.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_ipam_pools) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment in which to provision resources | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the product, and injected into all resource tags | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | The name of the product to provision resources and inject into all resource tags | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region we are provisioning the resources for the landing zone | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A collection of tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_anomaly_detection"></a> [anomaly\_detection](#input\_anomaly\_detection) | A collection of anomaly detection rules to apply to the environment | <pre>object({<br>    enable_default_monitors = optional(bool, true)<br>    # A flag indicating if the default monitors should be enabled <br>    monitors = optional(list(object({<br>      name = string<br>      # The name of the anomaly detection rule <br>      threshold_expression = optional(any, [<br>        {<br>          and = {<br>            dimension = {<br>              key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"<br>              match_options = ["GREATER_THAN_OR_EQUAL"]<br>              values        = ["50"]<br>            }<br>          }<br>      }])<br>      # The expression to apply to the anomaly detection rule<br>      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor<br>      specification = string<br>      # The specification to anomaly detection monitor <br>      # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor<br>      frequency = optional(string, "DAILY")<br>      # The frequency of you want to receive notifications <br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | The cost center of the product, and injected into all resource tags | `string` | `null` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | A collection of DNS zones to provision and associate with networks | <pre>map(object({<br>    comment = optional(string, "Managed by zone created by terraform")<br>    # A comment associated with the DNS zone <br>    network = string<br>    # A list of network names to associate with the DNS zone <br>    private = optional(bool, true)<br>    # A flag indicating if the DNS zone is private or public<br>  }))</pre> | `{}` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | A collection of firewall rules to apply to networks | <pre>object({<br>    capacity = optional(number, 100)<br>    # The capacity of the firewall rule, defaults to 100 <br>    name = string<br>    # The name of the firewall rule <br>    rule_source = string<br>    # The content of the suracata rules<br>    ip_sets = optional(map(list(string)), null)<br>    # A map of IP sets to apply to the firewall rule, optional ie. WEBSERVERS = ["10.0.0.0/16"]<br>    port_sets = optional(map(list(number)), null)<br>    # A map of port sets to apply to the firewall rule, optional ie. WEBSERVERS = [80, 443] <br>  })</pre> | `null` | no |
| <a name="input_kms"></a> [kms](#input\_kms) | Configuration for the KMS key to use for encryption | <pre>object({<br>    enable_default_kms = optional(bool, true)<br>    # A flag indicating if the default KMS key should be enabled <br>  })</pre> | <pre>{<br>  "enable_default_kms": true<br>}</pre> | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A collection of networks to provision within the designated region | <pre>map(object({<br>    availability_zones = optional(string, 2)<br>    # The availability zone in which to provision the network, defaults to 2 <br>    enable_private_endpoints = optional(list(string), [])<br>    # An optional list of private endpoints to associate with the network i.e ["s3", "dynamodb"]<br>    enable_shared_endpoints = optional(bool, true)<br>    # Indicates if the network should accept shared endpoints <br>    enable_transit_gateway = optional(bool, true)<br>    # A flag indicating if the network should be associated with the transit gateway <br>    enable_transit_gateway_appliance_mode = optional(bool, false)<br>    # A flag indicating if the transit gateway should be in appliance mode<br>    enable_default_route_table_association = optional(bool, true)<br>    # A flag indicating if the default route table should be associated with the network <br>    enable_default_route_table_propagation = optional(bool, true)<br>    # A flag indicating if the default route table should be propagated to the network<br>    ipam_pool_name = optional(string, null)<br>    # The name of the network <br>    nat_gateway_mode = optional(string, "none")<br>    # The NAT gateway mode to use for the network, defaults to none <br>    private_subnet_netmask = number<br>    # The netmask of the private subnet <br>    public_subnet_netmask = optional(number, 0)<br>    # The netmask of the public subnet, optional <br>    transit_gateway_routes = optional(map(string), null)<br>    # A list of routes to associate with the transit gateway, optional <br>    vpc_cidr = optional(string, null)<br>    # The CIDR block of the VPC network, required when not using IPAM <br>    vpc_netmask = optional(string, 0)<br>    # The netmask of the VPC network, required when using using IPAM<br>  }))</pre> | `{}` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | A collection of notifications to send to users | <pre>object({<br>    email = object({<br>      addresses = list(string)<br>      # A list of email addresses to send notifications to <br>    })<br>    slack = object({<br>      channel = string<br>      # The slack channel to send notifications to <br>    })<br>  })</pre> | <pre>{<br>  "email": {<br>    "addresses": []<br>  },<br>  "slack": {<br>    "channel": ""<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name for the tenant |
| <a name="output_firewall_rule_group"></a> [firewall\_rule\_group](#output\_firewall\_rule\_group) | The ARN for the firewall rule group provisioned |
| <a name="output_hosted_zone_ids"></a> [hosted\_zone\_ids](#output\_hosted\_zone\_ids) | A map of the hosted zone name to id |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags to apply to all resources |
| <a name="output_vpc_ids"></a> [vpc\_ids](#output\_vpc\_ids) | A map of the network name to vpc id |
<!-- END_TF_DOCS -->
