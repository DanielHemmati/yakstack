output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.tailscale.id
}

output "public_ip" {
  description = "Public IP assigned for outbound internet access. SSH is not opened to the internet."
  value       = aws_instance.tailscale.public_ip
}

output "private_ip" {
  description = "Private VPC IP."
  value       = aws_instance.tailscale.private_ip
}

output "tailscale_hostname" {
  description = "Tailscale hostname requested during bootstrap."
  value       = var.tailscale_hostname
}

output "tailscale_ssh_command" {
  description = "SSH command to try after the node joins your tailnet and Tailscale SSH ACLs allow access."
  value       = "ssh ubuntu@${var.tailscale_hostname}"
}

output "ssh_command" {
  description = "Normal SSH command using the public EC2 address."
  value       = "ssh -i ${var.ssh_private_key_path} ubuntu@${aws_instance.tailscale.public_ip}"
}
