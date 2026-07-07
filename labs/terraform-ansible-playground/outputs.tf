output "ec2_public_ip" {
  value = aws_instance.ubuntu.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/terraform-ec2 ubuntu@${aws_instance.ubuntu.public_ip}"
}
