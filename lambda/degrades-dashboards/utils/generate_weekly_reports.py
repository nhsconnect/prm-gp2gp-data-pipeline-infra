import io
import os
import pandas as pd
import logging
from datetime import datetime, timedelta

from utils.s3_service import S3Service

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def generate_weekly_report(date_beginning: str):
    logger.info(f"Getting file keys for reports week beginning: {date_beginning}")
    prefixes = get_keys_from_date_range(date_beginning)

    logger.info(f"Generating weekly summary for week beginning: {date_beginning}")
    weekly_summary = generate_weekly_summary(prefixes, date_beginning)

    s3_service = S3Service()

    dfs = []
    dfs.append(pd.DataFrame(weekly_summary, [0]))

    logger.info(f"Retrieving weekly summary report from S3")
    csv_body = s3_service.get_object_from_s3(
        bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"),
        key="/reports/degrades_weekly_report.csv",
    )
    dfs.append(pd.read_csv(csv_body))

    df = pd.concat(dfs, ignore_index=True)
    print(df)

    logger.info(f"Writing updating weekly summary report in S3")
    with io.StringIO() as csv_file:
        df.to_csv(csv_file, index=False)
        s3_service.client.put_object(
            Bucket=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"),
            Key="/reports/degrades_weekly_report.csv",
            Body=csv_file.getvalue(),
        )

    logger.info(f"Successfully updated weekly summary report with summary for week beginning: {date_beginning}")


def get_keys_from_date_range(date_beginning: str) -> list[str]:
    start_date = datetime.fromisoformat(date_beginning)
    week_range = [start_date + timedelta(days=i) for i in range(0, 7, 1)]
    date_keys = [datetime.strftime(day, "%Y/%m/%d") for day in week_range]

    return date_keys


def generate_weekly_summary(prefixes: list[str], date_beginning) -> dict:
    s3_service = S3Service()
    dfs = []
    logger.info(f"Retrieving daily reports for week beginning: {date_beginning} from S3")
    for prefix in prefixes:
        csv_body = s3_service.get_object_from_s3(
            bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"),
            key=f"/{prefix}/degrades_summary.csv",
        )
        dfs.append(pd.read_csv(csv_body))

    df = pd.concat(dfs, ignore_index=True).sum()
    week_summary = df.to_dict()
    week_summary.update({"WEEK_BEGINNING": date_beginning.replace("-", "/")})
    logger.info(f"Successfully generated weekly summary for {date_beginning}: {week_summary}")
    return week_summary
