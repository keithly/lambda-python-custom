terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket = "krp-project-tfstate"
    key    = "lambda-python-custom.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.41.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.2.1"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region

  default_tags {
    tags = {
      environment = "dev"
      project     = "https://github.com/keithly/lambda-python-custom"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "lambda-python-custom"
  ecr_image_tag       = "latest"
}
