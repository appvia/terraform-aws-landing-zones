
variable "account_email" {
  description = "The email address of the account to create"
  type        = string
}

variable "account_name" {
  description = "The name of the account to create"
  type        = string
}

variable "close_on_deletion" {
  description = "Whether to close the account when it is deleted from the organization"
  type        = bool
  default     = null
}

variable "enable_iam_billing_access" {
  description = "Whether to allow IAM users to access billing information"
  type        = bool
  default     = true
}

variable "organizational_unit_id" {
  description = "The organizational unit id where the account should be created"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
}
