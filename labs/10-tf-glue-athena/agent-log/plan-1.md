## phase 2 scripts

Deploy and upload the new path:

```bash
terraform -chdir=terraform apply
./scripts/upload-data.sh
```

Start the crawler:

aws glue start-crawler \
--name "$(terraform -chdir=terraform output -raw glue_crawler_name)"

Check its state until it returns READY:

aws glue get-crawler \
--name "$(terraform -chdir=terraform output -raw glue_crawler_name)" \
--query "Crawler.State"

Inspect the generated schema:

aws glue get-table \
--database-name glue_learning \
--name users \
--query "Table.StorageDescriptor.Columns"

---

## phase 4

Validation

- terraform fmt -check: passed
- terraform validate: passed
- Terraform plan: 4 to add, 0 to change, 0 to destroy
- Python syntax check: passed
- Terraform security policy: POLICY_OK
- git diff --check: passed

Deployment was not completed because the workspace policy blocks
terraform apply. To deploy and test:

terraform -chdir=terraform apply

aws glue start-job-run \
--job-name "$(terraform -chdir=terraform output -raw
glue_etl_job_name)"
