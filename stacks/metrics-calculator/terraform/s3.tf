resource "aws_s3_bucket" "metrics_calculator" {
  bucket = "prm-gp2gp-metrics-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name            = "${var.environment}-output-metrics-data-for-metrics-calculator"
      ApplicationRole = "AwsS3Bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "metrics_calculator" {
  bucket = aws_s3_bucket.metrics_calculator.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "reports_generator" {
  bucket = aws_s3_bucket.metrics_calculator.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "metrics_calculator" {
  bucket = aws_s3_bucket.metrics_calculator.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
