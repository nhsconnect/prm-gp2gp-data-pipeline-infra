resource "aws_ssm_parameter" "gocd_trigger_lambda_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/dashboard-pipeline-gocd-trigger/lambda-arn"
  type  = "String"
  value = aws_lambda_function.gocd_trigger.arn
  tags  = local.common_tags
}