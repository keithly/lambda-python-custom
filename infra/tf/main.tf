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
      version = "~> 4.45.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      environment = "dev"
      project     = "https://github.com/keithly/lambda-python-custom"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id          = data.aws_caller_identity.current.account_id
  partition           = data.aws_partition.current.partition
  ecr_repository_name = var.function_name
}
