import urllib3
import boto3
import json
import os

from botocore.exceptions import ClientError

http = urllib3.PoolManager()

class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]


def lambda_handler(event, context):
    print(event)
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)

    gp2gp_dashboard_step_function_url = os.environ["GP2GP_DASHBOARD_STEP_FUNCTION_URL"]

    text = (
        f"## **There was an error running the gp2gp dashboard step function:** <br>"
        f"See all the latest step function for more details: {gp2gp_dashboard_step_function_url}%<br>"
    )

    msg = {
        "text": text,
        "textFormat": "markdown"
    }
    pipeline_error_encoded_msg = json.dumps(msg).encode('utf-8')

    pipeline_error_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME"])

    try:
        pipeline_error_alert_resp = http.request('POST', url=pipeline_error_alert_webhook_url, body=pipeline_error_encoded_msg)

        print({
            "message": msg["text"],
            "status_code": pipeline_error_alert_resp.status,
            "response": pipeline_error_alert_resp.data,
            "alert_type": "pipeline_error_technical_failure_rates",
        })

    except ClientError as e:
        print(e.response['Error']['Message'])
    except Exception as e:
        print("An error has occurred: ", e)
    else:
        print("Successfully sent alert")
