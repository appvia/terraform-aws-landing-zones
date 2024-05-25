
variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The region to deploy the resources"
  type        = string
  default     = "eu-west-2"
}
