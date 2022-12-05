resource "aws_iam_role" "this" {
  name = "lambda-${var.function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement: [
        {
            Effect: "Allow",
            Action: "logs:CreateLogGroup",
            Resource: "arn:${local.partition}:logs:${var.region}:${local.account_id}:*"
        },
        {
            Effect: "Allow",
            Action: [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Resource: [
                "arn:${local.partition}:logs:${var.region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.this.name}:*"
            ]
        }
    ]
  })
}

resource "aws_lambda_permission" "invoke" {
  statement_id           = "url"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.this.function_name
  function_url_auth_type = "NONE"
  principal              = "*"
}
