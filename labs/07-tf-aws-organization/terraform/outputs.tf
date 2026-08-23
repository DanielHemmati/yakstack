output "organization_id" {
  value = data.aws_organizations_organization.current.id
}

output "test_ou_id" {
  value = aws_organizations_organizational_unit.test.id
}

output "ada_dev_account_id" {
  value = aws_organizations_account.ada_dev.id
}

output "ada_dev_account_arn" {
  value = aws_organizations_account.ada_dev.arn
}

output "ada_dev_account_email" {
  value = aws_organizations_account.ada_dev.email
}

output "identity_center_instance_arn" {
  value = data.aws_ssoadmin_instances.current.arns[0]
}

output "identity_store_id" {
  value = data.aws_ssoadmin_instances.current.identity_store_ids[0]
}

output "ada_dev_identitystore_user_id" {
  value = aws_identitystore_user.ada_dev.user_id
}

output "power_user_permission_set_arn" {
  value = aws_ssoadmin_permission_set.power_user.arn
}
