resource "aws_iam_role" "lambda_python_custom" {
  name = "lambda_python_custom"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : "sts:AssumeRole" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_python_custom" {
  role       = aws_iam_role.lambda_python_custom.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "invoke" {
  statement_id           = "url"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.python_custom.function_name
  function_url_auth_type = "NONE"
  principal              = "*"
}
