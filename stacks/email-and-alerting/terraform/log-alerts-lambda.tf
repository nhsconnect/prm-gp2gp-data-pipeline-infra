variable "log_alerts_technical_failures_above_threshold_lambda_name" {
  default = "log-alerts-technical-failures-above-threshold-lambda"
}

resource "aws_lambda_function" "log_alerts_technical_failures_above_threshold_lambda" {
  filename      = var.log_alerts_technical_failures_above_threshold_lambda_zip
  function_name = "${var.environment}-${var.log_alerts_technical_failures_above_threshold_lambda_name}"
  role          = aws_iam_role.log_alerts_lambda_role.arn
  handler       = "main.lambda_handler"
  source_code_hash = filebase64sha256(var.log_alerts_technical_failures_above_threshold_lambda_zip)
  runtime = "python3.9"
  timeout = 15
  tags          = local.common_tags

  environment {
    variables = {
      LOG_ALERTS_TECHNICAL_FAILURES_WEBHOOK_URL_PARAM_NAME = var.log_alerts_technical_failures_webhook_url_param_name,
      LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_WEBHOOK_URL_PARAM_NAME = var.log_alerts_technical_failures_above_threshold_webhook_url_param_name,
      LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME = var.log_alerts_general_webhook_url_param_name,
      LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_RATE_PARAM_NAME = var.log_alerts_technical_failures_above_threshold_rate_param_name
    }
  }
}

resource "aws_iam_policy" "cloudwatch_log_access" {
  name   = "${var.environment}-log-alerts-cloudwatch-log-access"
  policy = data.aws_iam_policy_document.cloudwatch_log_access.json
}

resource "aws_cloudwatch_log_group" "log_alerts_technical_failures_above_threshold" {
  name = "/aws/lambda/${var.environment}-${var.log_alerts_technical_failures_above_threshold_lambda_name}"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-${var.log_alerts_technical_failures_above_threshold_lambda_name}"
    }
  )
  retention_in_days = 60
}

data "aws_iam_policy_document" "cloudwatch_log_access" {
  statement {
    sid = "CloudwatchLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.log_alerts_technical_failures_above_threshold.arn}:*",
      "${aws_cloudwatch_log_group.log_alerts_pipeline_error.arn}:*"
    ]
  }
}

resource "aws_iam_role" "log_alerts_lambda_role" {
  name               = "${var.environment}-log-alerts-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.log_alerts_ssm_access.arn,
    aws_iam_policy.cloudwatch_log_access.arn,
    ]
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "log_alerts_ssm_access" {
  statement {
    sid = "GetSSMParameter"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_technical_failures_webhook_url_param_name}",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_technical_failures_above_threshold_webhook_url_param_name}",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_general_webhook_url_param_name}",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.log_alerts_technical_failures_above_threshold_rate_param_name}"
    ]
  }
}

resource "aws_iam_policy" "log_alerts_ssm_access" {
  name   = "${var.environment}-log-alerts-ssm-access"
  policy = data.aws_iam_policy_document.log_alerts_ssm_access.json
}

resource "aws_lambda_permission" "log_alerts_technical_failures_above_threshold_lambda_allow_cloudwatch" {
  statement_id = "log-alerts-technical-failures-above-threshold-lambda-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_alerts_technical_failures_above_threshold_lambda.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${data.aws_ssm_parameter.cloud_watch_log_group.value}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "log_alerts_technical_failures_above_threshold" {
  count           = var.environment == "dev" ? 0 : 1
  name            = "${var.environment}-log-alerts-technical-failures-above-threshold-log-filter"
  depends_on      = [aws_lambda_permission.log_alerts_technical_failures_above_threshold_lambda_allow_cloudwatch]
  log_group_name  = data.aws_ssm_parameter.cloud_watch_log_group.value
  filter_pattern  = "{ $.module = \"reports_pipeline\" && $.alert-enabled is true }"
  destination_arn = aws_lambda_function.log_alerts_technical_failures_above_threshold_lambda.arn
}

# Pipeline error lambda
variable "log_alerts_pipeline_error_lambda_name" {
  default = "log-alerts-pipeline-error-lambda"
}

resource "aws_lambda_function" "log_alerts_pipeline_error_lambda" {
  filename      = var.log_alerts_pipeline_error_lambda_zip
  function_name = "${var.environment}-${var.log_alerts_pipeline_error_lambda_name}"
  role          = aws_iam_role.log_alerts_lambda_role.arn
  handler       = "main.lambda_handler"
  source_code_hash = filebase64sha256(var.log_alerts_pipeline_error_lambda_zip)
  runtime = "python3.9"
  timeout = 15
  tags          = local.common_tags

  environment {
    variables = {
      LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME = var.log_alerts_general_webhook_url_param_name,
      CLOUDWATCH_DASHBOARD_URL = var.cloudwatch_dashboard_url
    }
  }
}

resource "aws_lambda_permission" "log_alerts_pipeline_error_lambda_allow_cloudwatch" {
  statement_id = "log-alerts-pipeline-error-lambda-allow-cloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_alerts_pipeline_error_lambda.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${data.aws_ssm_parameter.cloud_watch_log_group.value}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "log_alerts_pipeline_error" {
  count           = var.environment == "dev" ? 0 : 1
  name            = "${var.environment}-log-alerts-pipeline-error-log-filter"
  depends_on      = [aws_lambda_permission.log_alerts_pipeline_error_lambda_allow_cloudwatch]
  log_group_name  = data.aws_ssm_parameter.cloud_watch_log_group.value
  filter_pattern  = "\"Failed to run main, exiting...\""
  destination_arn = aws_lambda_function.log_alerts_pipeline_error_lambda.arn
}

resource "aws_cloudwatch_log_group" "log_alerts_pipeline_error" {
  name = "/aws/lambda/${var.environment}-${var.log_alerts_pipeline_error_lambda_name}"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-${var.log_alerts_pipeline_error_lambda_name}"
    }
  )
  retention_in_days = 60
}