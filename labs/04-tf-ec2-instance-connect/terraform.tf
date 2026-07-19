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

  required_version = ">= 1.15.0, < 2.0.0"
}
