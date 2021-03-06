resource "aws_s3_bucket" "metrics_calculator" {
  bucket = "prm-gp2gp-metrics-${var.environment}"
  acl    = "private"

  tags = merge(
    local.common_tags,
    {
      Name = "Output transfer data for metrics calculator"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "metrics_calculator" {
  bucket = aws_s3_bucket.metrics_calculator.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}