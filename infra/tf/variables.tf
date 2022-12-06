variable "image_tag" {
  description = "the image tag for the docker image in ECR"
  type        = string
}

variable "function_name" {
  description = "the name of the lambda function and its Cloudwatch log group"
  type        = string
  default     = "lambda-python-custom"
}

variable "log_retention_days" {
  description = "the number days to keep Cloudwatch logs"
  type        = number
  default     = 60
}
