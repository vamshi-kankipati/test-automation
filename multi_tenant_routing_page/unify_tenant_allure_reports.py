import json
import os
import re

import boto3


REPORTS_FOLDER = "multi-tenant-reports"
MAX_REPORTS = 3


def normalize_environment(environment):
    """Normalize environment names to qa-a or qa-b."""

    if not environment:
        return ""

    environment = environment.lower().strip()

    if re.match(r"^qa[-_]a(_pwa)?$", environment):
        return "qa-a"

    if re.match(r"^qa[-_]b(_pwa)?$", environment):
        return "qa-b"

    return environment


def normalize_url_environment(url, environment):
    """Normalize QA environment inside the report URL."""

    if not url or not environment:
        return url

    return re.sub(
        r"qa[-_]a(?:_pwa)?|qa[-_]b(?:_pwa)?",
        environment,
        url,
        flags=re.IGNORECASE,
    )


def extract_run_number(url):
    """
    Extract the GitHub run number from URLs such as:

    .../allure-report/qa-b/74/
    .../allure-report/qa-b/74/suite_1/
    """

    segments = [
        segment
        for segment in url.rstrip("/").split("/")
        if segment
    ]

    # Search backwards for the numeric run number.
    for segment in reversed(segments):
        if segment.isdigit():
            return int(segment)

    return -1


def load_existing_reports(
    s3_client,
    bucket,
    file_key,
    local_file,
):
    """Download existing routing JSON from S3."""

    try:
        print(f"Downloading existing JSON: {file_key}")

        s3_client.download_file(
            bucket,
            file_key,
            local_file,
        )

        with open(local_file, "r") as file:
            content = file.read().strip()

        if not content or content == "{}":
            return {"reports": []}

        data = json.loads(content)

        if not isinstance(data, dict):
            return {"reports": []}

        data.setdefault("reports", [])

        return data

    except Exception as error:
        print(
            f"No existing routing file found: {file_key}"
        )
        print(f"S3 message: {error}")

        return {"reports": []}


def main():

    tenant = os.getenv(
        "TENANT",
        "",
    ).strip()

    environment = normalize_environment(
        os.getenv(
            "ENVIRONMENT",
            "",
        )
    )

    platform = os.getenv(
        "REPORT_PLATFORM",
        os.getenv("OS", ""),
    ).strip().lower()

    suite_name = os.getenv(
        "SUITE_NAME",
        "",
    ).strip()

    new_report_url = os.getenv(
        "ALLURE_LINK",
        "",
    ).strip()

    bucket = os.getenv(
        "ALLURE_REPORTS_BUCKET",
        "",
    ).strip()

    if not tenant:
        raise RuntimeError(
            "TENANT is required"
        )

    if not environment:
        raise RuntimeError(
            "ENVIRONMENT is required"
        )

    if not platform:
        raise RuntimeError(
            "REPORT_PLATFORM or OS is required"
        )

    if not new_report_url:
        raise RuntimeError(
            "ALLURE_LINK is required"
        )

    if not bucket:
        raise RuntimeError(
            "ALLURE_REPORTS_BUCKET is required"
        )

    print("========================================")
    print("UNIFY ALLURE REPORT ROUTING")
    print("========================================")
    print(f"Tenant: {tenant}")
    print(f"Environment: {environment}")
    print(f"Platform: {platform}")
    print(f"Suite: {suite_name or '<none>'}")
    print(f"Allure Link: {new_report_url}")
    print("========================================")

    # --------------------------------------------------------
    # IMPORTANT:
    #
    # Unify gets its own routing JSON.
    #
    # Example:
    #
    # multi-tenant-reports/
    #   bk-co_qa-b_unify_android_allure_reports.json
    #
    # --------------------------------------------------------

    file_name = (
        f"{tenant}_"
        f"{environment}_"
        f"unify_"
        f"{platform}_"
        f"allure_reports.json"
    )

    file_key = (
        f"{REPORTS_FOLDER}/"
        f"{file_name}"
    )

    local_file = file_name

    print(f"S3 file: {file_key}")

    s3_client = boto3.client("s3")

    # --------------------------------------------------------
    # Load existing reports
    # --------------------------------------------------------

    reports_object = load_existing_reports(
        s3_client=s3_client,
        bucket=bucket,
        file_key=file_key,
        local_file=local_file,
    )

    reports = reports_object.setdefault(
        "reports",
        [],
    )

    # --------------------------------------------------------
    # Normalize environment in URL
    # --------------------------------------------------------

    normalized_url = normalize_url_environment(
        new_report_url,
        environment,
    )

    # Always make URL consistent.
    normalized_url = normalized_url.rstrip("/") + "/"

    print(
        f"Normalized URL: {normalized_url}"
    )

    # --------------------------------------------------------
    # Prevent duplicates
    # --------------------------------------------------------

    if normalized_url in reports:

        print(
            "URL already exists. "
            "Skipping duplicate."
        )

    else:

        reports.append(
            normalized_url
        )

        print(
            "Added new Allure report."
        )

    # --------------------------------------------------------
    # Sort by GitHub run number
    # --------------------------------------------------------

    reports.sort(
        key=extract_run_number
    )

    # --------------------------------------------------------
    # Keep latest 3
    # --------------------------------------------------------

    reports_object["reports"] = reports[
        -MAX_REPORTS:
    ]

    print("Final reports:")

    print(
        json.dumps(
            reports_object,
            indent=4,
        )
    )

    # --------------------------------------------------------
    # Write JSON
    # --------------------------------------------------------

    with open(local_file, "w") as file:

        json.dump(
            reports_object,
            file,
            indent=4,
        )

    # --------------------------------------------------------
    # Upload JSON
    # --------------------------------------------------------

    print(
        f"Uploading {file_key}..."
    )

    s3_client.upload_file(
        local_file,
        bucket,
        file_key,
        ExtraArgs={
            "CacheControl": "no-cache",
        },
    )

    print(
        f"Successfully updated {file_key}"
    )


if __name__ == "__main__":
    main()
