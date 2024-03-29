resource "aws_cloudwatch_dashboard" "data_pipeline" {
  dashboard_name = "${var.environment}-registrations-data-pipeline-spine-exporter"
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
          "title" : "SPINE_EXTRACT_SIZE_BYTES",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, size_in_bytes | filter strcontains(@logStream, 'spine-exporter') and event='SPINE_EXTRACT_SIZE_BYTES'",
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
          "title" : "SPINE_EXTRACT_SIZE_BYTES - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats sum(size_in_bytes) by time | sort time | filter strcontains(@logStream, 'spine-exporter') and event='SPINE_EXTRACT_SIZE_BYTES'",
          "view" : "bar"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "SPINE_EXTRACT_ROW_COUNT",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, row_count | filter strcontains(@logStream, 'spine-exporter') and event='SPINE_EXTRACT_ROW_COUNT'",
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
          "title" : "SPINE_EXTRACT_ROW_COUNT - graph",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats sum(row_count) by time | sort time | filter strcontains(@logStream, 'spine-exporter') and event='SPINE_EXTRACT_ROW_COUNT'",
          "view" : "bar"
        }
      },
      {
        "type" : "log",
        "width" : 12,
        "height" : 6,
        "properties" : {
          "period" : 120
          "region" : data.aws_region.current.name,
          "title" : "Successful upload count",
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | filter strcontains(@logStream, 'spine-exporter') and event='UPLOADED_CSV_TO_S3'",
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
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' |  stats count(event) as count by bin(1d) as timestamp | sort timestamp | filter strcontains(@logStream, 'spine-exporter') and event='UPLOADED_CSV_TO_S3'",
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
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | stats count(event) as count by bin(1d) as timestamp  | filter strcontains(@logStream, 'spine-exporter') and event='FAILED_TO_RUN_MAIN'",
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
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, event, message, @message | filter strcontains(@logStream, 'spine-exporter') and level != 'INFO'",
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
          "query" : "SOURCE '${data.aws_ssm_parameter.cloud_watch_log_group.value}' | fields @timestamp, message, @message | filter strcontains(@logStream, 'spine-exporter')",
          "view" : "table",
        }
      },
    ]
  })
}