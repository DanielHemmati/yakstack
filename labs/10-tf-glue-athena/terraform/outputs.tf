output "bucket_name" {
  description = "Name of the S3 data bucket"
  value       = aws_s3_bucket.data.id
}

output "raw_data_uri" {
  description = "S3 URI for the raw data prefix"
  value       = "s3://${aws_s3_bucket.data.id}/raw/"
}

output "processed_data_uri" {
  description = "S3 URI for the processed data prefix"
  value       = "s3://${aws_s3_bucket.data.id}/processed/"
}
