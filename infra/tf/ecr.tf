resource "aws_ecr_repository" "this" {
  name = local.ecr_repository_name
}
