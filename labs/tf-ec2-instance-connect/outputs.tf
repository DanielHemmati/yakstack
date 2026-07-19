output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.ec2_instance.id
}

output "public_ip" {
  description = "EC2 IPv4 address"
  value       = aws_instance.ec2_instance.public_ip
}

output "current_caller_arn" {
  description = "ARN of the identity running Terraform"
  value       = data.aws_caller_identity.current.arn
}

output "current_iam_user" {
  description = "IAM user receiving Instance connect permissions"
  value       = local.current_iam_user_name
}

output "instance_connect_policy_arn" {
  description = "ARN of the EC2 insntace Connect IAM policy"
  value       = aws_iam_policy.instance_connect.arn
}

