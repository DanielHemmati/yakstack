provider "aws" {
  region = var.region

  default_tags {
    tags = merge({ managedBy = "terraform" }, var.default_tags)
  }
}

