resource "aws_cloudwatch_dashboard" "data_pipeline" {
  dashboard_name = "${var.environment}-registrations-data-pipeline-ods-downloader"
  dashboard_body = jsonencode({
    "start" : "-P3D"
    "widgets" : [
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Successful upload count",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | filter strcontains(@logStream, 'ods-downloader') and event='UPLOADED_JSON_TO_S3'",
          "view" : "table",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Successful upload count - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | sort timestamp | filter strcontains(@logStream, 'ods-downloader') and event='UPLOADED_JSON_TO_S3'",
          "view" : "bar",
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "FAILED_TO_RUN_MAIN",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats count(event) as count by bin(1d) as timestamp  | filter strcontains(@logStream, 'ods-downloader') and event='FAILED_TO_RUN_MAIN'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Non-info logs (errors, warnings, system)",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, message, @message | filter strcontains(@logStream, 'ods-downloader') and level != 'INFO'",
          "view" : "table"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "All log messages",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, message, @message | filter strcontains(@logStream, 'ods-downloader')",
          "view" : "table",
        }
      },
    ]
  })
}