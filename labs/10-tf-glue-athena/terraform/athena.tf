locals {
  athena_workgroup_name = "${var.project_name}-workgroup"
}

resource "aws_athena_workgroup" "learning" {
  name        = local.athena_workgroup_name
  description = "Runs queries against the Glue learning catalog"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = 104857600

    result_configuration {
      output_location = "s3://${aws_s3_bucket.data.id}/athena-results/"

      # though not necessary to write this, but i like to
      # be explicit
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_athena_named_query" "all_users" {
  name        = "All users"
  description = "Returns every row from the raw users table"
  database    = aws_glue_catalog_database.learning.name
  workgroup   = aws_athena_workgroup.learning.id
  query       = "SELECT * FROM users;"
}

resource "aws_athena_named_query" "users_over_30" {
  name        = "Users over 30"
  description = "Returns users whose age is greater than 30"
  database    = aws_glue_catalog_database.learning.name
  workgroup   = aws_athena_workgroup.learning.id
  query       = <<-SQL
    SELECT *
    FROM users
    WHERE age > 30;
  SQL
}

resource "aws_athena_named_query" "users_by_country" {
  name        = "Users by country"
  description = "Counts users in each country"
  database    = aws_glue_catalog_database.learning.name
  workgroup   = aws_athena_workgroup.learning.id
  query       = <<-SQL
    SELECT country, COUNT(*) AS users
    FROM users
    GROUP BY country
    ORDER BY users DESC;
  SQL
}
