mock_provider "aws" {}

run "example" {
  command = plan

  assert {
    condition     = aws_iam_user.example.name == "example-user"
    error_message = "IAM user name should be example-user"
  }
}

run "secret_output_is_sensetive" {
  command = plan

  assert {
    # TODO: is this a good way to test sensitive value in terraform??
    condition = issensitive(output.secret_access_key)
    error_message = "Secret access key output must be sensitive"
  }
}
