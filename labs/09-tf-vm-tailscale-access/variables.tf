variable "region" {
  description = "Choose your aws region, default us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix for resources."
  type        = string
  default     = "tailscale-ec2"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key."
  type        = string
  default     = "~/.ssh/terraform-ec2.pub"
}

variable "ssh_private_key_path" {
  description = "Path to your SSH private key, used only for the output command."
  type        = string
  default     = "~/.ssh/terraform-ec2"
}

variable "ssh_key_name" {
  description = "AWS EC2 key pair name to create from ssh_public_key_path."
  type        = string
  default     = "terraform-ec2-key"
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key used by cloud-init to join the tailnet. Set it in an ignored terraform.tfvars file."
  type        = string
  sensitive   = true
}

variable "tailscale_hostname" {
  description = "Hostname to register in Tailscale."
  type        = string
  default     = "tf-ec2"
}

variable "enable_tailscale_ssh" {
  description = "Enable Tailscale SSH on the instance. Requires compatible Tailscale ACLs in your tailnet."
  type        = bool
  default     = true
}
