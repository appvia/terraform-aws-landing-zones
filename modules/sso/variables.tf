
variable "account_id" {
  description = "The account ID to assign the permissionset"
  type        = string
}

variable "identity_store_id" {
  description = "The identity store ID for the identity center instance"
  type        = string
}

variable "instance_arn" {
  description = "The ARN for the identity center instance"
  type        = string
}

variable "groups" {
  description = "The list of groups to assign the permissionset"
  type        = list(string)
  default     = null
}

variable "permission_set_name" {
  description = "The name of the permissionset to assign"
  type        = string
}

variable "users" {
  description = "The list of users to assign the permissionset"
  type        = list(string)
  default     = null
}

