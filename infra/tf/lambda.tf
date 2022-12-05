resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.this.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.repo.repository_url}:${var.image_tag}"

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.function_name
  authorization_type = "NONE"
}
