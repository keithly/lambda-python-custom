resource "aws_ecr_repository" "repo" {
  name = local.ecr_repository_name
}

data "aws_ecr_image" "lambda_image" {
  repository_name = local.ecr_repository_name
  image_tag       = local.ecr_image_tag
}