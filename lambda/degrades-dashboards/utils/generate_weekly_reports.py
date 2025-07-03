import os
import csv
import logging
from datetime import datetime, timedelta

from utils.s3_service import S3Service

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def generate_weekly_report(date_beginning: str):
    prefixes = get_keys_from_date_range(date_beginning)

    s3_service = S3Service()

    dataframes = [
        s3_service.read_file_from_S3(
            bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"),
            key=f"/{prefix}/degrades_summary.csv",
        )
        for prefix in prefixes
    ]


def get_keys_from_date_range(date_beginning: str):
    start_date = datetime.fromisoformat(date_beginning)

    week_range = [start_date + timedelta(days=i) for i in range(0, 7, 1)]

    date_keys = [datetime.strftime(day, "%Y/%m/%d") for day in week_range]

    return date_keys
