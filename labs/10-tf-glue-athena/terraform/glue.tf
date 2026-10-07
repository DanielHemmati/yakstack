locals {
  crawler_name               = "${var.project_name}-users-crawler"
  processed_crawler_name     = "${var.project_name}-processed-users-crawler"
  processed_users_table_name = "processed_users"
  etl_job_name               = "${var.project_name}-users-transform"
}

resource "aws_glue_catalog_database" "learning" {
  name        = "glue_learning"
  description = "Metadata for the AWS Glue learning project"
}

resource "aws_glue_crawler" "users" {
  name          = local.crawler_name
  database_name = aws_glue_catalog_database.learning.name
  description   = "Discovers the schema of the raw users CSV data"
  role          = aws_iam_role.glue_crawler.arn

  s3_target {
    path = "s3://${aws_s3_bucket.data.id}/raw/users/"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  depends_on = [aws_iam_role_policy.glue_crawler]
}

resource "aws_glue_crawler" "processed_users" {
  name          = local.processed_crawler_name
  database_name = aws_glue_catalog_database.learning.name
  description   = "Catalogs processed users Parquet data and country partitions"
  role          = aws_iam_role.glue_crawler.arn
  table_prefix  = "processed_"

  s3_target {
    path = "s3://${aws_s3_bucket.data.id}/processed/users/"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  depends_on = [aws_iam_role_policy.glue_crawler]
}

resource "aws_glue_job" "users_transform" {
  name        = local.etl_job_name
  description = "Cleans the raw users data before it is written in an analytics format"
  role_arn    = aws_iam_role.glue_etl.arn

  glue_version = "5.1"
  # https://docs.aws.amazon.com/glue/latest/dg/worker-types.html
  worker_type       = "G.1X"
  number_of_workers = 2
  max_retries       = 0
  timeout           = 10

  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_object.glue_transform_script.bucket}/${aws_s3_object.glue_transform_script.key}"
  }

  default_arguments = {
    "--SOURCE_DATABASE" = aws_glue_catalog_database.learning.name
    "--SOURCE_TABLE"    = "users"
    "--TARGET_PATH"     = "s3://${aws_s3_bucket.data.id}/processed/users/"
    # this is not necessary but in future if you add sth like redshift this is required
    "--TempDir" = "s3://${aws_s3_bucket.data.id}/glue-temp/"
  }

  depends_on = [aws_iam_role_policy.glue_etl]
}
