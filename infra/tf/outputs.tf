output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "function_url" {
  value = aws_lambda_function_url.this.function_url
}

output "lambda_image_uri" {
  value = aws_lambda_function.this.image_uri
}
