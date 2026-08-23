# Terraform Assume Role Map

Start with **who is allowed to assume the role**, then configure Terraform to use that role.

```text
┌──────────────────────────┐
│ 1. Caller Identity       │
│ User / CI / AWS Account  │
└─────────────┬────────────┘
              │
              │ sts:AssumeRole
              ▼
┌──────────────────────────┐
│ 2. IAM Role Trust Policy │  ← Start here
│ Allows caller to assume  │
│ this role                │
└─────────────┬────────────┘
              │
              │ role permissions
              ▼
┌──────────────────────────┐
│ 3. IAM Role Policy       │
│ What Terraform can do    │
│ after assuming the role  │
└─────────────┬────────────┘
              │
              │ Terraform AWS provider
              ▼
┌──────────────────────────┐
│ 4. Terraform Provider    │
│ provider "aws" {         │
│   assume_role { ... }    │
│ }                        │
└──────────────────────────┘
```

Typical Terraform order:

```text
iam-role.tf
  └─ create role + trust policy

iam-policy.tf
  └─ attach permissions to role

providers.tf
  └─ configure assume_role

main.tf
  └─ create resources using assumed role
```

Key idea:

```text
Trust policy = who can assume the role
Role policy  = what they can do after assuming it
Provider     = tells Terraform to assume it
```
