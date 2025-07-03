import os
import csv
from unittest.mock import call

from moto import mock_aws

from utils.generate_weekly_reports import (
    generate_weekly_report,
    get_keys_from_date_range,
    generate_weekly_summary
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

    mock_s3_service.get_object_from_s3.return_value = "./tests/reports/global.csv"

    generate_weekly_report("2024-09-16")

    expected_calls = [
        call(
            bucket_name=os.getenv("REGISTRATIONS_MI_EVENT_BUCKET"),
            key=f"/{prefix}/degrades_summary.csv",
        )
        for prefix in prefixes
    ]

    mock_s3_service.read_file_from_S3.get_object_from_s3(expected_calls)


def test_generate_weekly_summary_summarises_weekly_data(mock_s3, set_env):
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

    actual = generate_weekly_summary(prefixes, "2024-09-16")

    with open("./tests/reports/global.csv", "r") as expected_file:
        reader = csv.DictReader(expected_file)
        rows = [row for row in reader]

        for key, value in actual.items():
            actual[key] = str(value)
        assert actual == rows[0]





@mock_aws
def test_weekly_report_generation_adds_new_row_to_global_report(set_env, mock_s3, mocker):
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
    mocker.patch(
        "utils.generate_weekly_reports.generate_weekly_summary"
    ).return_value = {
        "WEEK_BEGINNING": "2024/09/23",
        "TOTAL": 47.0,
        "MEDICATION: CODE": 16.0,
        "NON_DRUG_ALLERGY: CODE": 7.0,
        "RECORD_ENTRY: CODE": 11.0,
        "RECORD_ENTRY: NUMERIC_VALUE": 4.0,
        "DRUG_ALLERGY: CODE": 2.0,
        "ALLERGY: CODE": 1.0,
    }

    for index, file in enumerate(files):
        mock_s3.upload_file(
            f"./tests/reports/{file}", f"/{prefixes[index]}/degrades_summary.csv"
        )
    mock_s3.upload_file(
        "./tests/reports/global.csv", "/reports/degrades_weekly_report.csv"
    )

    generate_weekly_report("2024-09-16")

    mock_s3.download_file(
        Key="/reports/degrades_weekly_report.csv",
        Filename="tmp/degrades_weekly_report.csv",
    )
    with (
        open("./tests/reports/global_2.csv", "r") as expected_file,
        open("tmp/degrades_weekly_report.csv", "r") as actual_file,
    ):
        expected = expected_file.read()
        actual = actual_file.read()
        assert actual == expected

    os.remove("tmp/degrades_weekly_report.csv")
