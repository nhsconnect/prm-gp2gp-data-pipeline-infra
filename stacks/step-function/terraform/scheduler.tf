resource "aws_cloudwatch_event_target" "data_pipeline" {
  target_id = "${var.environment}-data-pipeline"
  rule      = aws_cloudwatch_event_rule.run_every_three_mins.id
  arn       = aws_sfn_state_machine.data_pipeline.arn
  role_arn  = aws_iam_role.data_pipeline_trigger.arn
  input_transformer {
    input_paths = {
      "time" : "$.time"
    }
    input_template = replace(replace(jsonencode({
      "mappingFileUrl" : "s3://prm-gp2gp-asid-lookup-dev/2021/05/asidLookup.csv.gz",
      "outputFileUrl" : "s3://prm-gp2gp-ods-metadata-dev/2021/05/organisationMetadata.json",
      "time" : "<time>"
    }), "\\u003e", ">"), "\\u003c", "<")
  }
}

resource "aws_cloudwatch_event_rule" "run_every_three_mins" {
  name        = "${var.environment}-data-pipeline-trigger"
  description = "Trigger Step Function"

  schedule_expression = "cron(0/0 1 23 * ? *)"
  tags                = local.common_tags
}