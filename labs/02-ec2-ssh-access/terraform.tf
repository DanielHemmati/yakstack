terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.6.0"
    }
  }

  # backend "s3" {
  #   bucket       = "terraform-up-and-running-1337"
  #   key          = "global/s3/terraform.tfstate"
  #   region       = "us-east-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
  #
  required_version = ">= 1.15.0, < 2.0.0"
}



