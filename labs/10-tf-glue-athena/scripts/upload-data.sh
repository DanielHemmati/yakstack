#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform"
CSV_FILE="${PROJECT_ROOT}/data/users.csv"

for required_command in terraform aws; do
  if ! command -v "${required_command}" >/dev/null 2>&1; then
    printf 'Error: %s is not installed or is not in PATH.\n' "${required_command}" >&2
    exit 1
  fi
done

BUCKET_NAME="$(terraform -chdir="${TERRAFORM_DIR}" output -raw bucket_name)"

aws s3 cp "${CSV_FILE}" "s3://${BUCKET_NAME}/raw/users.csv" --only-show-errors
aws s3api put-object --bucket "${BUCKET_NAME}" --key "processed/" >/dev/null

printf 'Uploaded %s to s3://%s/raw/users.csv\n' "${CSV_FILE}" "${BUCKET_NAME}"
printf 'Created s3://%s/processed/\n' "${BUCKET_NAME}"
