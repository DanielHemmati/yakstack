#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
PERMISSION_SET_NAME="${1:-PowerUserAccess}"
MANAGED_POLICY_ARN="${MANAGED_POLICY_ARN:-arn:aws:iam::aws:policy/PowerUserAccess}"

echo "Using region: ${REGION}"
echo "Looking for permission set: ${PERMISSION_SET_NAME}"
echo "Using managed policy: ${MANAGED_POLICY_ARN}"

INSTANCE_ARN="$(
  aws sso-admin list-instances \
    --region "$REGION" \
    --query 'Instances[0].InstanceArn' \
    --output text
)"

IDENTITY_STORE_ID="$(
  aws sso-admin list-instances \
    --region "$REGION" \
    --query 'Instances[0].IdentityStoreId' \
    --output text
)"

if [[ -z "$INSTANCE_ARN" || "$INSTANCE_ARN" == "None" ]]; then
  echo "No IAM Identity Center instance found in region: $REGION"
  exit 1
fi

echo "Identity Center instance ARN:"
echo "$INSTANCE_ARN"
echo

echo "Identity Store ID:"
echo "$IDENTITY_STORE_ID"
echo

PERMISSION_SET_ARN=""

for ps_arn in $(
  aws sso-admin list-permission-sets \
    --region "$REGION" \
    --instance-arn "$INSTANCE_ARN" \
    --query 'PermissionSets[]' \
    --output text
); do
  name="$(
    aws sso-admin describe-permission-set \
      --region "$REGION" \
      --instance-arn "$INSTANCE_ARN" \
      --permission-set-arn "$ps_arn" \
      --query 'PermissionSet.Name' \
      --output text
  )"

  if [[ "$name" == "$PERMISSION_SET_NAME" ]]; then
    PERMISSION_SET_ARN="$ps_arn"
    break
  fi
done

if [[ -z "$PERMISSION_SET_ARN" ]]; then
  echo "Permission set not found: $PERMISSION_SET_NAME"
  exit 1
fi

echo "Permission set ARN:"
echo "$PERMISSION_SET_ARN"
echo

import_if_missing() {
  local address="$1"
  local import_id="$2"

  if terraform state show "$address" >/dev/null 2>&1; then
    echo "Already imported: $address"
    return
  fi

  echo "Importing: $address"
  terraform import "$address" "$import_id"
}

import_if_missing \
  "aws_ssoadmin_permission_set.power_user" \
  "${PERMISSION_SET_ARN},${INSTANCE_ARN}"

import_if_missing \
  "aws_ssoadmin_managed_policy_attachment.power_user" \
  "${MANAGED_POLICY_ARN},${PERMISSION_SET_ARN},${INSTANCE_ARN}"

echo
echo "Imports complete. Run: terraform plan"
