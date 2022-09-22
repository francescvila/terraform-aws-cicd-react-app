provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.11.0"
    }
  }

  backend "s3" {
    region  = "us-east-1"
    bucket  = "tfstate-sandbox-1663839467"
    key     = "dev.tfsate"
    profile = "sandbox"
    encrypt = true
  }
}
