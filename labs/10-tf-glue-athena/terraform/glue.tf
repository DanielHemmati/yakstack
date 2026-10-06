locals {
  crawler_name = "${var.project_name}-users-crawler"
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
