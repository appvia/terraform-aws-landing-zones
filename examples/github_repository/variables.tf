#####################################################################################
# Variables for the GitHub Repository Module Example
# These variables demonstrate how to configure the module for different use cases
#####################################################################################

variable "github_organization" {
  description = "The GitHub organization where repositories will be created"
  type        = string
  default     = "my-organization"
}

variable "enable_basic_repository" {
  description = "Whether to create the basic repository example"
  type        = bool
  default     = true
}

variable "enable_public_repository" {
  description = "Whether to create the public repository example"
  type        = bool
  default     = false
}

variable "enable_enterprise_repository" {
  description = "Whether to create the enterprise repository example"
  type        = bool
  default     = false
}

variable "basic_repository_name" {
  description = "Name for the basic repository"
  type        = string
  default     = "my-terraform-project"
}

variable "public_repository_name" {
  description = "Name for the public repository"
  type        = string
  default     = "my-open-source-project"
}

variable "enterprise_repository_name" {
  description = "Name for the enterprise repository"
  type        = string
  default     = "enterprise-critical-system"
}

variable "basic_repository_collaborators" {
  description = "Collaborators for the basic repository"
  type = list(object({
    username   = string
    permission = optional(string, "write")
  }))
  default = [
    {
      username   = "developer1"
      permission = "write"
    },
    {
      username   = "developer2"
      permission = "write"
    }
  ]
}

variable "enterprise_repository_collaborators" {
  description = "Collaborators for the enterprise repository"
  type = list(object({
    username   = string
    permission = optional(string, "write")
  }))
  default = [
    {
      username   = "senior-dev1"
      permission = "admin"
    },
    {
      username   = "senior-dev2"
      permission = "admin"
    },
    {
      username   = "junior-dev1"
      permission = "write"
    },
    {
      username   = "junior-dev2"
      permission = "write"
    }
  ]
}

variable "basic_repository_topics" {
  description = "Topics for the basic repository"
  type        = list(string)
  default     = ["terraform", "aws", "infrastructure", "iac"]
}

variable "public_repository_topics" {
  description = "Topics for the public repository"
  type        = list(string)
  default     = ["open-source", "terraform", "aws", "community"]
}

variable "enterprise_repository_topics" {
  description = "Topics for the enterprise repository"
  type        = list(string)
  default     = ["enterprise", "terraform", "aws", "critical", "compliance"]
}

variable "basic_repository_environments" {
  description = "Environments for the basic repository"
  type        = list(string)
  default     = ["staging", "production"]
}

variable "enterprise_repository_environments" {
  description = "Environments for the enterprise repository"
  type        = list(string)
  default     = ["dev", "staging", "production"]
}

variable "enterprise_required_approving_review_count" {
  description = "Required approving review count for the enterprise repository"
  type        = number
  default     = 3
}
