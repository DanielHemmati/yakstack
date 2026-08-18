# How to assume an admin role with Terraform

This lab creates:

- an IAM user named `john`
- a console login profile for `john`
- an access key for `john`
- an IAM role with `AdministratorAccess`
- permissions that allow `john` to assume the admin role
- permissions that allow `john` to change the initial console password

IAM policies are generated with `aws_iam_policy_document` data sources instead of raw `jsonencode` blocks.

## Warning

This lab creates a path to `AdministratorAccess`. Use it only in a sandbox or learning AWS account.

Terraform stores generated secrets in state, including the IAM user's console password and access key secret. Treat `terraform.tfstate` and any remote state backend as sensitive data.

## Deploy

Run all Terraform commands from the `terraform` directory.

```bash
cd terraform
terraform init
terraform apply
```

Review the plan, then type `yes` when Terraform asks for approval.

## Get the Console Password

The console password is a sensitive Terraform output, so it is hidden in the normal `terraform apply` output.

Show it with:

```bash
terraform output -raw console_password
```

You can also get the console sign-in URL with:

```bash
terraform output -raw console_signin_url
```

## Log In as john

1. Open the console sign-in URL from `terraform output -raw console_signin_url`.
2. Log in with username `john`.
3. Use the password from `terraform output -raw console_password`.
4. AWS will require a password change on first login.
5. Set a new password that satisfies the AWS account password policy.

## Reset john's Password

If you need Terraform to generate a new initial console password, replace the login profile:

```bash
terraform apply -replace=aws_iam_user_login_profile.lab_user
terraform output -raw console_password
```

Then log in as `john` again and set a new password when prompted.

## Assume the Admin Role in the AWS Console

After logging in as `john`:

1. Open the account menu in the top-right corner of the AWS Console.
2. Choose **Switch role**.
3. For **Account**, enter the 12-digit AWS account ID. You can copy it from the console sign-in URL or from the role ARN shown by `terraform output -raw iam_role_arn`.
4. For **Role**, enter the role name:

```bash
terraform output -raw iam_role_name
```

1. Choose a display name, such as `admin`.
2. Choose **Switch Role**.

The default admin role name is `john-admin-role`.

## Assume the Admin Role with the AWS CLI

First, configure a CLI profile for `john` using the access key created by Terraform:

```bash
aws configure --profile john
```

Use these Terraform outputs when prompted:

```bash
terraform output -raw access_key_id
terraform output -raw secret_access_key
```

Then assume the admin role:

```bash
aws sts assume-role \
  --profile john \
  --role-arn "$(terraform output -raw iam_role_arn)" \
  --role-session-name john-admin-session
```

You can also print the generated assume-role command:

```bash
terraform output -raw assume_role_command
```

The command returns temporary credentials: `AccessKeyId`, `SecretAccessKey`, and `SessionToken`. Export them to use the admin role from your shell:

```bash
export AWS_ACCESS_KEY_ID="<AccessKeyId>"
export AWS_SECRET_ACCESS_KEY="<SecretAccessKey>"
export AWS_SESSION_TOKEN="<SessionToken>"
```

Verify the assumed role identity:

```bash
aws sts get-caller-identity
```

## Destroy

When finished, remove all resources created by this lab:

```bash
terraform destroy
```

## Ideas to extend this lab

1. Write test

First use terraform native functions and if needed add terratest.

1. Is it even a right approach to manage a user using terraform?

Imo it should be a better way.
