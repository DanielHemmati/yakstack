output "bucket_name" {
  description = "Name of the S3 data bucket"
  value       = aws_s3_bucket.data.id
}

output "raw_data_uri" {
  description = "S3 URI for the raw data prefix"
  value       = "s3://${aws_s3_bucket.data.id}/raw/"
}

output "raw_users_uri" {
  description = "S3 URI scanned by the users crawler"
  value       = "s3://${aws_s3_bucket.data.id}/raw/users/"
}

output "processed_data_uri" {
  description = "S3 URI for the processed data prefix"
  value       = "s3://${aws_s3_bucket.data.id}/processed/"
}

output "processed_users_uri" {
  description = "S3 URI where the Glue job writes users data in Parquet format"
  value       = "s3://${aws_s3_bucket.data.id}/processed/users/"
}

output "glue_database_name" {
  description = "Name of the Glue Data Catalog database"
  value       = aws_glue_catalog_database.learning.name
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler for the raw users data"
  value       = aws_glue_crawler.users.name
}

output "processed_users_crawler_name" {
  description = "Name of the Glue crawler for processed users data"
  value       = aws_glue_crawler.processed_users.name
}

output "processed_users_table_name" {
  description = "Name of the Glue table created by the processed users crawler"
  value       = local.processed_users_table_name
}

output "glue_etl_job_name" {
  description = "Name of the Glue job that cleans the raw users data"
  value       = aws_glue_job.users_transform.name
}

output "glue_etl_script_uri" {
  description = "S3 URI of the Glue ETL script"
  value       = "s3://${aws_s3_object.glue_transform_script.bucket}/${aws_s3_object.glue_transform_script.key}"
}

output "athena_workgroup_name" {
  description = "Name of the Athena workgroup for this project"
  value       = aws_athena_workgroup.learning.name
}

output "athena_results_uri" {
  description = "S3 URI where Athena stores query results"
  value       = "s3://${aws_s3_bucket.data.id}/athena-results/"
}
