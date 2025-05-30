resource "aws_lambda_function" "degrades_lambda" {
  filename         = var.degrades_dashboards_lambda_zip
  function_name    = "${var.environment}_${var.degrades_lambda_name}"
  role             = aws_iam_role.degrades_lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${var.degrades_dashboards_lambda_zip}")
  timeout          = 15
}