resource "aws_ecr_repository" "repo" {
  name = local.ecr_repository_name
}
