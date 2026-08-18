output "access_key_id" {
  value = aws_iam_access_key.lab_user.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.lab_user.secret
  sensitive = true
}

output "iam_user_name" {
  value = aws_iam_user.lab_user.name
}

output "iam_user_arn" {
  value = aws_iam_user.lab_user.arn
}

output "iam_role_name" {
  value = aws_iam_role.admin_role.name
}

output "iam_role_arn" {
  value = aws_iam_role.admin_role.arn
}

output "assume_role_command" {
  value = "aws sts assume-role --role-arn ${aws_iam_role.admin_role.arn} --role-session-name admin-session"
}

output "console_password" {
  value     = aws_iam_user_login_profile.lab_user.password
  sensitive = true
}

output "console_signin_url" {
  value = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
}
