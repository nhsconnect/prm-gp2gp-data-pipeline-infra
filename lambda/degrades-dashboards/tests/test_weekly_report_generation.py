import os
from unittest.mock import call

from moto import mock_aws
from utils.generate_weekly_reports import (
    generate_weekly_report,
    get_keys_from_date_range,
)


def test_get_keys_from_date_range():
    expected = [
        "2024/09/16",
        "2024/09/17",
        "2024/09/18",
        "2024/09/19",
        "2024/09/20",
        "2024/09/21",
        "2024/09/22",
    ]
    assert get_keys_from_date_range("2024-09-16") == expected


@mock_aws
def test_generate_weekly_calls_s3_with_keys(set_env, mock_s3, mock_s3_service):
    files = [
        "2024-09-16.csv",
        "2024-09-17.csv",
        "2024-09-18.csv",
        "2024-09-19.csv",
        "2024-09-20.csv",
        "2024-09-21.csv",
        "2024-09-22.csv",
    ]
    prefixes = [
        "2024/09/16",
        "2024/09/17",
        "2024/09/18",
        "2024/09/19",
        "2024/09/20",
        "2024/09/21",
        "2024/09/22",
    ]

    for index, file in enumerate(files):
        mock_s3.upload_file(
            f"./tests/reports/{file}", f"/{prefixes[index]}/degrades_summary.csv"
        )

    mock_s3_service.download_file.return_value = "tmp/2024-09-16-degrades_summary.csv"

    generate_weekly_report("2024-09-16")

    expected_calls = [
        call(
            bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"),
            key=f"/{prefix}/degrades_summary.csv",
        )
        for prefix in prefixes
    ]

    mock_s3_service.read_file_from_S3.assert_has_calls(expected_calls)


@mock_aws
def test_weekly_report_generation(set_env, mock_s3, mock_s3_service):
    files = [
        "2024-09-16.csv",
        "2024-09-17.csv",
        "2024-09-18.csv",
        "2024-09-19.csv",
        "2024-09-20.csv",
        "2024-09-21.csv",
        "2024-09-22.csv",
    ]
    prefixes = [
        "2024/09/16",
        "2024/09/17",
        "2024/09/18",
        "2024/09/19",
        "2024/09/20",
        "2024/09/21",
        "2024/09/22",
    ]

    mock_s3_service.download_file.return_value = "tmp/2024-09-16-degrades_summary.csv"

    for index, file in enumerate(files):
        mock_s3.upload_file(
            f"./tests/reports/{file}", f"/{prefixes[index]}/degrades_summary.csv"
        )
    actual = generate_weekly_report("2024-09-16")
    with open("./tests/reports/global.csv") as file:
        expected = file.read()
        assert actual == expected
