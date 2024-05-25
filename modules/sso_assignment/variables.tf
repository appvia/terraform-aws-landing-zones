
variable "groups" {
  description = "The list of groups to assign the permissionset"
  type        = list(string)
  default     = null
}

variable "identity_store_id" {
  description = "The ID for the identity store"
  type        = string
}

variable "instance_arn" {
  description = "The ARN for the identity center instance"
  type        = string
}

variable "permissionset" {
  description = "The name of the permissionset to assign"
  type        = string
}

variable "target" {
  description = "The list of targets (accounts) to assign the permissionset"
  type        = string
}

variable "users" {
  description = "The list of users to assign the permissionset"
  type        = list(string)
  default     = null
}

