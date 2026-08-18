# lab 06 spec: admin access through assumerole

## goal

create an AWS IAM setup with Terraform where an admin IAM user receives access keys and uses them only to assume an admin role.

The lab should create an IAM user that can assume an IAM role. The admin permissions must live on the role, not directly on the user.

## Security Model

The IAM user is an entry principal for role assumption.

The IAM user must not have direct administrator permissions.

The IAM user should have Terraform-managed access keys so it can authenticate programmatically.

Do not create:

- `aws_iam_user_login_profile`
- hardcoded secrets
- generated passwords

The IAM role receives administrator permissions and returns temporary credentials only when assumed through AWS STS.

## AWS Resources

Terraform should create:

- One IAM user, for example `assume-role-admin-user`
- One IAM access key for the IAM user
- One IAM role, for example `john-admin-role`
- A trust policy on the role that allows only the IAM user to call `sts:AssumeRole`
- An IAM policy attached to the user that allows `sts:AssumeRole` only on the admin role
- The AWS managed `AdministratorAccess` policy attached to the role

## Terraform Files

Use plain Terraform only.

Expected files:

- `versions.tf` for required providers and their versions
- `provider.tf` for AWS provider configuration
- `variables.tf` for configurable values such as AWS region, user name, and role name
- `main.tf` for IAM resources
- `outputs.tf` for useful outputs
- `dependencies.tf` for all of the terraform data sources

## Outputs

Terraform should output:

- IAM user name
- IAM user ARN
- IAM access key ID
- IAM secret access key, marked sensitive
- IAM role name
- IAM role ARN
- Example AWS CLI command for assuming the role

The secret access key output must be marked sensitive.

## Example AssumeRole Flow

The lab should document the intended flow:

```text
Human/operator
      |
      | authenticates with IAM user access key
      v
IAM user with Terraform-managed access key
      |
      | sts:AssumeRole
      v
Admin IAM role
      |
      | temporary STS credentials
      v
Admin access
```

Example CLI command to expose in the output or README:

```bash
aws sts assume-role \
  --role-arn <role-arn> \
  --role-session-name admin-session
```

## Important Security Note

The IAM user has long-lived access keys, but it must not have direct administrator permissions.

The access key should only allow the user to call `sts:AssumeRole` for the admin role. Administrator permissions are granted by temporary STS credentials returned from assuming the role.

## Acceptance Criteria

- `terraform init` succeeds.
- `terraform validate` succeeds.
- `terraform plan` shows one IAM user and one IAM role.
- The user policy allows only `sts:AssumeRole` against the created role.
- The role trust policy allows assumption only by the created user.
- The admin policy is attached to the role, not to the user.
- Terraform creates one IAM access key for the user.
- The secret access key output is marked sensitive.
