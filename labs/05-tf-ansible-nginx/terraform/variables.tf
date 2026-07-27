variable "aws_region" {
  description = "Default aws region"
  type        = string
  default     = "eu-central-1"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/terraform-ec2.pub"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

