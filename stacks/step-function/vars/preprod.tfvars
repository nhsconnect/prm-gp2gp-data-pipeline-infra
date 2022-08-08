data_pipeline_ecs_cluster_arn_param_name="/registrations/preprod/data-pipeline/ecs-cluster/ecs-cluster-arn"
data_pipeline_private_subnet_id_param_name="/registrations/preprod/data-pipeline/base-networking/private-subnet-id"
data_pipeline_outbound_only_security_group_id_param_name="/registrations/preprod/data-pipeline/base-networking/outbound-only-security-group-id"
data_pipeline_execution_role_arn_param_name="/registrations/preprod/data-pipeline/ecs-execution-role-arn"
ods_downloader_iam_role_arn_param_name="/registrations/preprod/data-pipeline/ods-downloader/iam-role-arn"
ods_downloader_task_definition_arn_param_name="/registrations/preprod/data-pipeline/ods-downloader/task-definition-arn"
metrics_calculator_task_definition_arn_param_name="/registrations/preprod/data-pipeline/metrics-calculator/task-definition-arn"
metrics_calculator_iam_role_arn_param_name="/registrations/preprod/data-pipeline/metrics-calculator/iam-role-arn"
transfer_classifier_iam_role_arn_param_name="/registrations/preprod/data-pipeline/transfer-classifier/iam-role-arn"
transfer_classifier_task_definition_arn_param_name="/registrations/preprod/data-pipeline/transfer-classifier/task-definition-arn"
reports_generator_iam_role_arn_param_name="/registrations/preprod/data-pipeline/reports-generator/iam-role-arn"
reports_generator_task_definition_arn_param_name="/registrations/preprod/data-pipeline/reports-generator/task-definition-arn"
spine_exporter_task_definition_arn_param_name="/registrations/preprod/data-pipeline/spine-exporter/task-definition-arn"
spine_exporter_iam_role_arn_param_name="/registrations/preprod/data-pipeline/spine-exporter/iam-role-arn"
transfer_data_bucket_name="prm-gp2gp-transfer-data-preprod"
gocd_trigger_lambda_arn_param_name="/registrations/preprod/data-pipeline/dashboard-pipeline-gocd-trigger/lambda-arn"
log_group_param_name="/registrations/preprod/data-pipeline/cloudwatch-log-group-name"
log_alerts_technical_failures_webhook_url_ssm_path="/registrations/preprod/user-input/log-alerts-technical-failures-webhook-url"
log_alerts_technical_failures_above_threshold_webhook_url_ssm_path="/registrations/preprod/user-input/log-alerts-technical-failures-above-threshold-webhook-url"
log_alerts_technical_failures_above_threshold_webhook_url_channel_two_ssm_path="/registrations/preprod/user-input/log-alerts-technical-failures-above-threshold-webhook-url-channel-two"
log_alerts_technical_failures_above_threshold_rate_ssm_path="/registrations/preprod/user-input/log-alerts-technical-failures-above-threshold-rate-threshold"
cloudwatch_dashboard_url="https://console.aws.amazon.com/cloudwatch/home#dashboards:name=preprod-registrations-data-pipeline-overview"