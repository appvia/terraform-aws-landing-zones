variable "repository" {
  description = "The name of the repository to provision"
  type        = string

  validation {
    condition     = length(var.repository) > 0
    error_message = "The repository name must be greater than 0"
  }

  validation {
    condition     = length(var.repository) <= 100
    error_message = "The repository name must be less than or equal to 100"
  }
}

variable "description" {
  description = "The description of the repository to provision"
  type        = string
  default     = "Terraform AWS Pipeline"
}

variable "visibility" {
  description = "The visibility of the repository to provision"
  type        = string
  default     = "private"
}

variable "repository_template" {
  description = "The repository template of the repository to provision"
  type        = string
  default     = null
}

variable "organization_template" {
  description = "The organization template of the repository to provision"
  type        = string
  default     = null
}

variable "delete_branch_on_merge" {
  description = "The delete branch on merge of the repository to provision"
  type        = bool
  default     = true
}

variable "default_branch" {
  description = "The default branch of the repository to provision"
  type        = string
  default     = "main"

  validation {
    condition     = length(var.default_branch) > 0
    error_message = "The default branch name must be greater than 0"
  }

  validation {
    condition     = length(var.default_branch) <= 100
    error_message = "The default branch name must be less than or equal to 100"
  }
}

variable "repository_collaborators" {
  description = "The GitHub user or organization to create the repositories under"
  type = list(object({
    username   = string
    permission = optional(string, "write")
  }))
  default = []
}

variable "allow_merge_commit" {
  description = "Allow merge commits within repositories"
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Allow rebase merges within repositories"
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Allow squash merges within repositories"
  type        = bool
  default     = true
}

variable "allow_auto_merge" {
  description = "Allow auto merges within repositories"
  type        = bool
  default     = false
}

variable "prevent_self_review" {
  description = "Indicates a user cannot approve their own pull requests"
  type        = bool
  default     = true
}

variable "dismiss_stale_reviews" {
  description = "Indicates a review will be dismissed if it becomes stale"
  type        = bool
  default     = true
}

variable "dismissal_users" {
  description = "The users to dismiss reviews"
  type        = list(string)
  default     = null
}

variable "dismissal_apps" {
  description = "The apps to dismiss reviews"
  type        = list(string)
  default     = null
}

variable "dismissal_teams" {
  description = "The teams to dismiss reviews"
  type        = list(string)
  default     = null
}

variable "required_approving_review_count" {
  description = "The number of approving reviews required"
  type        = number
  default     = 1
}

variable "enforce_branch_protection_for_admins" {
  description = "Indicates the branch protection is enforced for admins"
  type        = bool
  default     = true
}

variable "bypass_pull_request_allowances_users" {
  description = "The users to bypass pull request allowances"
  type        = list(string)
  default     = null
}

variable "bypass_pull_request_allowances_teams" {
  description = "The teams to bypass pull request allowances"
  type        = list(string)
  default     = null
}

variable "bypass_pull_request_allowances_apps" {
  description = "The apps to bypass pull request allowances"
  type        = list(string)
  default     = null
}

variable "required_status_checks" {
  description = "The status checks to require within repositories"
  type        = list(string)
  default = [
    "Terraform / Terraform Plan and Apply / Commitlint",
    "Terraform / Terraform Plan and Apply / Terraform Format",
    "Terraform / Terraform Plan and Apply / Terraform Lint",
    "Terraform / Terraform Plan and Apply / Terraform Plan",
    "Terraform / Terraform Plan and Apply / Terraform Security",
    "Terraform / Terraform Plan and Apply / Terraform Validate",
  ]
}

variable "repository_environments" {
  description = "The production environment to use within repositories"
  type        = list(string)
  default     = ["production"]
}

variable "default_environment_review_users" {
  description = "The user reviewers to apply to the production environment"
  type        = list(string)
  default     = null
}

variable "default_environment_review_teams" {
  description = "The teams reviewers to apply to the production environment"
  type        = list(string)
  default     = null
}

variable "repository_topics" {
  description = "The topics to apply to the repositories"
  type        = list(string)
  default     = ["aws", "terraform", "landing-zone"]
}
