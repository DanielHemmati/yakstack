data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy" "administrator_access" {
  arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "allow_assume_admin_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      aws_iam_role.admin_role.arn
    ]
  }
}

data "aws_iam_policy_document" "allow_change_own_password" {
  statement {
    effect = "Allow"

    actions = [
      "iam:ChangePassword",
      "iam:GetAccountPasswordPolicy",
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "admin_role_trust_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_iam_user.lab_user.arn
      ]
    }
  }
}
