resource "aws_iam_user" "lab_user" {
  name = var.user_name

  tags = {
    Environment = "dev"
  }
}

resource "aws_iam_user_policy" "allow_assume_admin_role" {
  name   = "allow-assume-role"
  user   = aws_iam_user.lab_user.name
  policy = data.aws_iam_policy_document.allow_assume_admin_role.json
}

# INFO: after i enter a new password for the user john i got this error:
# "You may not be authorized to perform this action, or the new password
# does not comply with the account password policy set by your administrator."
# And it did solved the problem
resource "aws_iam_user_policy" "allow_change_own_password" {
  name   = "allow-change-own-password"
  user   = aws_iam_user.lab_user.name
  policy = data.aws_iam_policy_document.allow_change_own_password.json
}

resource "aws_iam_role" "admin_role" {
  description          = "Admin role assumed by the lab IAM user"
  name                 = var.role_name
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.admin_role_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.admin_role.name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

resource "aws_iam_user_login_profile" "lab_user" {
  user                    = aws_iam_user.lab_user.name
  password_reset_required = true
}

resource "aws_iam_access_key" "lab_user" {
  user = aws_iam_user.lab_user.name
}
