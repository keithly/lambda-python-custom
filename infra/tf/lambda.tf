resource "aws_lambda_function" "python_custom" {
  function_name = "lambda_python_custom"
  role          = aws_iam_role.lambda_python_custom.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.repo.repository_url}:${data.aws_ecr_image.lambda_image.image_tag}"
}

resource "aws_lambda_function_url" "latest" {
  function_name      = aws_lambda_function.python_custom.function_name
  authorization_type = "NONE"
}
