output "lambda_arn" {
  value = aws_lambda_function.python_custom.arn
}

output "function_url" {
  value = aws_lambda_function_url.latest.function_url
}

output "lambda_image_uri" {
  value = aws_lambda_function.python_custom.image_uri
}

output "image_digest" {
  value = data.aws_ecr_image.lambda_image.image_digest
}

output "image_tags" {
  value = data.aws_ecr_image.lambda_image.image_tags
}