resource "aws_ecr_repository" "this" {
  name = local.ecr_repository_name
}

data "aws_ecr_image" "lambda_image" {
  repository_name = local.ecr_repository_name
}
