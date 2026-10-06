variable "aws_region" {
  description = "AWS region for the project resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to identify the project resources"
  type        = string
  default     = "glue-learning"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "The project name must use lowercase letters, numbers, and hyphens."
  }
}

variable "default_tags" {
  description = "Additional tags to apply to taggable resources"
  type        = map(string)
  default     = {}
}
