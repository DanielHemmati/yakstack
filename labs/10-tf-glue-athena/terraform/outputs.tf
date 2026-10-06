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

output "glue_database_name" {
  description = "Name of the Glue Data Catalog database"
  value       = aws_glue_catalog_database.learning.name
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler for the raw users data"
  value       = aws_glue_crawler.users.name
}
