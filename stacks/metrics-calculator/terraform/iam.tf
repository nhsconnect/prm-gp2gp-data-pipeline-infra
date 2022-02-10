data "aws_ssm_parameter" "transfers_input_bucket_name" {
  name = var.transfers_input_bucket_param_name
}

data "aws_ssm_parameter" "transfers_input_bucket_read_access_arn" {
  name = var.transfer_input_bucket_read_access_param_name
}


resource "aws_iam_role" "metrics_calculator" {
  name               = "${var.environment}-registrations-metrics-calculator"
  description        = "Role for metrics calculator ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = [
    data.aws_ssm_parameter.transfers_input_bucket_read_access_arn.value,
    aws_iam_policy.metrics_calculator_output_bucket_write_access.arn
  ]
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = [
    "sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "metrics_calculator_output_bucket_write_access" {
  name   = "${aws_s3_bucket.metrics_calculator.bucket}-write"
  policy = data.aws_iam_policy_document.metrics_calculator_output_bucket_write_access.json
}

data "aws_iam_policy_document" "metrics_calculator_output_bucket_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.metrics_calculator.bucket}/*"
    ]
  }
}