variable "region" {
  description = "AWS region to pick"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Default tags applied to all taggable AWS resource"
  type        = map(string)

  default = {}
}

variable "user_name" {
  description = "Name of the IAM user that can assume the admin role"
  type        = string
  default     = "john"
}

variable "role_name" {
  description = "Name of the IAM role with administrator access"
  type        = string
  default     = "john-admin-role"
}
