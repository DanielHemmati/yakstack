mock_provider "aws" {
  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = jsonencode({
        Version   = "2012-10-17"
        Statement = []
      })
    }
  }
}

run "example" {
  command = plan

  assert {
    condition     = aws_iam_user.lab_user.name == "john"
    error_message = "IAM user name should be john"
  }
}

run "secret_output_is_sensitive" {
  command = plan

  assert {
    # TODO: is this a good way to test sensitive value in terraform??
    condition = issensitive(output.secret_access_key)
    error_message = "Secret access key output must be sensitive"
  }
}
