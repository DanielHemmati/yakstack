locals {
  email = "user@example.com" # put your email in here
}

resource "aws_organizations_organizational_unit" "test" {
  name      = "test"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_account" "ada_dev" {
  name      = "ada-dev"
  email     = local.email
  parent_id = aws_organizations_organizational_unit.test.id

  role_name = "OrganizationAccountAccessRole"

  close_on_deletion = true
}

resource "aws_identitystore_user" "ada_dev" {
  identity_store_id = data.aws_ssoadmin_instances.current.identity_store_ids[0]

  user_name    = "ada-dev"
  display_name = "Ada Dev"

  name {
    given_name  = "Ada"
    family_name = "Dev"
  }

  emails {
    value   = local.email
    primary = true
  }

}

resource "aws_ssoadmin_permission_set" "power_user" {
  name             = "PowerUserAccess"
  description      = "Power user access for development accounts"
  instance_arn     = data.aws_ssoadmin_instances.current.arns[0]
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "power_user" {
  instance_arn       = data.aws_ssoadmin_instances.current.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.power_user.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}


resource "aws_ssoadmin_account_assignment" "ada_dev_power_user" {
  instance_arn       = data.aws_ssoadmin_instances.current.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.power_user.arn

  principal_type = "USER"
  principal_id   = aws_identitystore_user.ada_dev.user_id

  target_type = "AWS_ACCOUNT"
  target_id   = aws_organizations_account.ada_dev.id
}
