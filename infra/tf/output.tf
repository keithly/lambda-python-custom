output "lambda_arn" {
  value = aws_lambda_function.python_custom.arn
}

output "function_url" {
  value = aws_lambda_function_url.latest.function_url
}

output "image_digest" {
  value = data.aws_ecr_image.lambda_image.image_digest
}
