resource "aws_iam_user" "example" {
  name = "example-user"

  tags = {
    Environment = "dev"
  }
}
