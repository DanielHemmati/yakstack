data "aws_iam_policy_document" "glue_crawler_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    # These conditions protect against the confused deputy problem,
    # where another AWS account tries to use your role through Glue.
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:crawler/${local.crawler_name}",
      ]
    }
  }
}

# who is allowed to become this role?
resource "aws_iam_role" "glue_crawler" {
  name               = "${var.project_name}-crawler-role"
  description        = "Allows the Glue crawler to read raw user data and update the Data Catalog"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_assume_role.json
}

data "aws_iam_policy_document" "glue_crawler_permissions" {
  statement {
    sid       = "ReadBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.data.arn]
  }

  statement {
    sid       = "ListRawUsersPrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.data.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "raw/users",
        "raw/users/*",
      ]
    }
  }

  statement {
    sid       = "ReadRawUsersData"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.data.arn}/raw/users/*"]
  }

  statement {
    sid    = "ReadGlueDatabase"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
      aws_glue_catalog_database.learning.arn,
    ]
  }

  statement {
    sid    = "ManageUsersTable"
    effect = "Allow"
    actions = [
      "glue:BatchCreatePartition",
      "glue:BatchGetPartition",
      "glue:CreatePartition",
      "glue:CreateTable",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:GetTable",
      "glue:GetTables",
      "glue:UpdatePartition",
      "glue:UpdateTable",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
      aws_glue_catalog_database.learning.arn,
      "arn:${data.aws_partition.current.partition}:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.learning.name}/*",
    ]
  }

  statement {
    sid    = "WriteCrawlerLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/*",
    ]
  }
}

# what is the role allowed to do after it has been assumed?
resource "aws_iam_role_policy" "glue_crawler" {
  name   = "${var.project_name}-crawler-policy"
  role   = aws_iam_role.glue_crawler.id
  policy = data.aws_iam_policy_document.glue_crawler_permissions.json
}

data "aws_iam_policy_document" "glue_etl_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:job/${local.etl_job_name}",
      ]
    }
  }
}

resource "aws_iam_role" "glue_etl" {
  name               = "${var.project_name}-etl-role"
  description        = "Allows the Glue ETL job to read raw users data and write processed Parquet data"
  assume_role_policy = data.aws_iam_policy_document.glue_etl_assume_role.json
}

data "aws_iam_policy_document" "glue_etl_permissions" {
  statement {
    sid       = "ReadBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.data.arn]
  }

  statement {
    sid       = "ListJobDataPrefixes"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.data.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "raw/users",
        "raw/users/*",
        "processed/users",
        "processed/users/*",
      ]
    }
  }

  statement {
    sid     = "ReadJobInputs"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.data.arn}/glue-scripts/transform.py",
      "${aws_s3_bucket.data.arn}/raw/users/*",
    ]
  }

  statement {
    sid       = "WriteTemporaryData"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.data.arn}/glue-temp/*"]
  }

  statement {
    sid    = "WriteProcessedUsersData"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.data.arn}/processed/users/*"]
  }

  statement {
    sid    = "ReadUsersCatalogTable"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:GetTable",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
      aws_glue_catalog_database.learning.arn,
      "arn:${data.aws_partition.current.partition}:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.learning.name}/users",
    ]
  }

  statement {
    sid    = "WriteJobLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/jobs/*",
    ]
  }
}

resource "aws_iam_role_policy" "glue_etl" {
  name   = "${var.project_name}-etl-policy"
  role   = aws_iam_role.glue_etl.id
  policy = data.aws_iam_policy_document.glue_etl_permissions.json
}
