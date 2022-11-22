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
      version = "~> 4.40.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"

  default_tags {
    tags = {
      environment = "dev"
      project     = "https://github.com/keithly/lambda-python-custom"
    }
  }
}

locals {
  ecr_repository_name = "lambda-python-custom"
  ecr_image_tag       = "latest"
}
