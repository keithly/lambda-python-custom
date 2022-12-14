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
      version = "4.46.0"
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

locals {
  ecr_repository_name = var.function_name
}
