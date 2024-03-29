import urllib3
import boto3
import json
import os
import zlib
from datetime import datetime
from base64 import b64decode
from botocore.exceptions import ClientError

http = urllib3.PoolManager()


class SsmSecretManager:
    def __init__(self, ssm):
        self._ssm = ssm

    def get_secret(self, name):
        response = self._ssm.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]


def decode(data):
    compressed_payload = b64decode(data)
    json_payload = zlib.decompress(compressed_payload, 16+zlib.MAX_WBITS)
    return json.loads(json_payload)


def lambda_handler(event, context):
    ssm = boto3.client("ssm")
    secret_manager = SsmSecretManager(ssm)

    data = decode(event["awslogs"]["data"])
    message = json.loads(data["logEvents"][0]["message"])
    percent_of_technical_failures = float(message["percent-of-technical-failures"])
    total_technical_failures = message["total-technical-failures"]
    total_transfers = message["total-transfers"]
    start_date = message["reporting-window-start-datetime"]
    datetime_obj = datetime.strptime(start_date, '%Y-%m-%dT%H:%M:%S%z').strftime("%A %d %B, %Y")

    daily_alert_heading = f"## **Daily technical failure rate**"
    base_text = (
        f"<ul>"
        f"<li>***Percent of technical failures***: {percent_of_technical_failures}%</li>"
        f"<li>***Total technical failures***: {total_technical_failures}</li>"
        f"<li>***Total transfers***: {total_transfers}</li>"
        f"<li>***Date***: {datetime_obj}</li>"
        f"</ul>"
    )

    daily_alert_msg = {
        "text": daily_alert_heading + base_text,
        "textFormat": "markdown"
    }
    daily_alert_encoded_msg = json.dumps(daily_alert_msg).encode('utf-8')

    daily_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_TECHNICAL_FAILURES_WEBHOOK_URL_PARAM_NAME"])

    try:
        print("Sending alert to webhook with message: ", daily_alert_encoded_msg)
        daily_alert_resp = http.request('POST', url=daily_alert_webhook_url, body=daily_alert_encoded_msg)

        print({
            "message": daily_alert_msg["text"],
            "status_code": daily_alert_resp.status,
            "response": daily_alert_resp.data,
            "alert_type": "daily_technical_failure_rates",
        })

        technical_failure_threshold_rate = int(secret_manager.get_secret(os.environ["LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_RATE_PARAM_NAME"]))

        if percent_of_technical_failures > technical_failure_threshold_rate:
            threshold_alert_heading = f"## **Technical failures are above the threshold:**"
            threshold_alert_msg = {
                "text": threshold_alert_heading + base_text,
                "textFormat": "markdown"
            }
            threshold_alert_encoded_msg = json.dumps(threshold_alert_msg).encode('utf-8')

            exceeded_threshold_alert_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_TECHNICAL_FAILURES_ABOVE_THRESHOLD_WEBHOOK_URL_PARAM_NAME"])
            exceeded_threshold_alert_resp = http.request('POST', url=exceeded_threshold_alert_webhook_url, body=threshold_alert_encoded_msg)

            print("Alert to main threshold channel sent.", exceeded_threshold_alert_resp)

            print({
                "message": threshold_alert_msg["text"],
                "status_code": exceeded_threshold_alert_resp.status,
                "response": exceeded_threshold_alert_resp.data,
                "alert_type": "exceeded_threshold_technical_failure_rates",
                "technical_failure_threshold": technical_failure_threshold_rate,
                "technical_failure_rate": percent_of_technical_failures
            })

            log_alerts_general_webhook_url = secret_manager.get_secret(os.environ["LOG_ALERTS_GENERAL_WEBHOOK_URL_PARAM_NAME"])
            exceeded_threshold_alert_two_resp = http.request('POST', url=log_alerts_general_webhook_url, body=threshold_alert_encoded_msg)

            print("Alert to general channel sent.", exceeded_threshold_alert_two_resp)

    except ClientError as e:
        print(e.response['Error']['Message'])
    except Exception as e:
        print("An error has occurred: ", e)
    else:
        print("Successfully sent alerts")