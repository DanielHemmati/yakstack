output "app_ssh_command" {
  value = "ssh -i ${var.ssh_public_key_path} ubuntu@${aws_instance.nginx_instance.public_ip}"
}

output "public_ip" {
  value = aws_instance.nginx_instance.public_ip
}

output "instance_spec" {
  value = {
    instance_type = var.instance_type
    vcpu          = data.aws_ec2_instance_type.selected.default_vcpus
    memory_gib    = data.aws_ec2_instance_type.selected.memory_size / 1024
  }
}

