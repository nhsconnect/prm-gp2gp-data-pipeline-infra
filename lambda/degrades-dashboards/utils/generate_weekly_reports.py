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

    files = [
        s3_service.download_file(
            bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"),
            key=f"/{prefix}/degrades_summary.csv",
            file=f"{os.getcwd()}/tmp/{prefix.replace("/", "-")}-degrades_summary.csv",
        )
        for prefix in prefixes
    ]
    readers = []
    for file in files:
        with open(f"{os.getcwd()}/{file}", "r") as f:
            for line in csv.DictReader(f):
                readers.append(line)
                logger.info(line)


    logger.info(readers)
    logger.info(files)


def get_keys_from_date_range(date_beginning: str):
    start_date = datetime.fromisoformat(date_beginning)

    week_range = [start_date + timedelta(days=i) for i in range(0, 7, 1)]

    date_keys = [datetime.strftime(day, "%Y/%m/%d") for day in week_range]

    return date_keys
