resource "aws_iam_role" "ods_downloader" {
  name               = "${var.environment}-registrations-ods-downloader"
  description        = "Role for ods downloader ECS task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy_attachment" "ods_input_bucket_read_access" {
  name = aws_iam_role.ods_downloader.name
  policy_arn = aws_iam_policy.ods_input_bucket_read_access.arn
}

resource "aws_iam_policy" "ods_input_bucket_read_access" {
  name    = "${aws_s3_bucket.ods_input.bucket}-read"
  policy  = data.aws_iam_policy_document.ods_input_bucket_read_access.json
}

data "aws_iam_policy_document" "ods_input_bucket_read_access" {
  statement {
    sid = "ListBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.ods_input.bucket}"
    ]
  }

  statement {
    sid = "ReadObjects"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.ods_input.bucket}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ods_output_bucket_write_access" {
  role    = aws_iam_role.ods_downloader.name
  policy_arn = aws_iam_policy.ods_output_bucket_write_access.arn
}

resource "aws_iam_policy" "ods_output_bucket_write_access" {
  name    = "${aws_s3_bucket.ods_output.bucket}-write"
  policy  = data.aws_iam_policy_document.ods_output_bucket_write_access.json
}

data "aws_iam_policy_document" "ods_output_bucket_write_access" {
  statement {
    sid = "WriteObjects"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.ods_output.bucket}/*"
    ]
  }
}