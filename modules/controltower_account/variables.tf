
variable "account_email" {
  description = "The email address of the account to create"
  type        = string

  validation {
    condition     = length(var.account_email) > 0
    error_message = "The account_email must be a non-empty string"
  }

  validation {
    condition     = can(regex("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}", var.account_email))
    error_message = "The account_email must be a valid email address"
  }
}

variable "account_name" {
  description = "The name of the account to create"
  type        = string

  validation {
    condition     = length(var.account_name) > 0
    error_message = "The account_name must be a non-empty string"
  }

  validation {
    condition     = can(regex("[a-zA-Z0-9-]{1,32}", var.account_name))
    error_message = "The account_name must be alphanumeric and dashes, and between 1 and 32 characters"
  }
}

variable "sso_user_first_name" {
  description = "The first name of the SSO user to create"
  type        = string

  validation {
    condition     = length(var.sso_user_first_name) > 0
    error_message = "The sso_user_first_name must be a non-empty string"
  }
}

variable "sso_user_last_name" {
  description = "The last name of the SSO user to create"
  type        = string

  validation {
    condition     = length(var.sso_user_last_name) > 0
    error_message = "The sso_user_last_name must be a non-empty string"
  }
}

variable "service_catalog_product_name" {
  description = "The name of the Service Catalog product to use for account creation"
  type        = string
  default     = "AWS Control Tower Account Factory"

  validation {
    condition     = length(var.service_catalog_product_id) > 0
    error_message = "The service_catalog_product_id must be a non-empty string"
  }
}

variable "service_catalog_provisioning_artifact_id" {
  description = "The ID of the Service Catalog provisioning artifact to use for account creation"
  type        = string

  validation {
    condition     = length(var.service_catalog_provisioning_artifact_id) > 0
    error_message = "The service_catalog_provisioning_artifact_id must be a non-empty string"
  }
}

variable "organizational_unit_id" {
  description = "The organizational unit id where the account should be created"
  type        = string

  validation {
    condition     = length(var.organizational_unit_id) > 0
    error_message = "The organizational_unit_id must be a non-empty string"
  }

  validation {
    condition     = can(regex("ou-[a-z0-9]{4,32}-[a-z0-9]{8,32}", var.organizational_unit_id))
    error_message = "The organizational_unit_id must be in the format ou-<32 characters>-<32 characters>"
  }
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
}
