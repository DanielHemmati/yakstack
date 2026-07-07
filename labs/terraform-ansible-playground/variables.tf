variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/terraform-ec2.pub"
}

