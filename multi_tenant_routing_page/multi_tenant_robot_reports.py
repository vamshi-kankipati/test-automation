import os
import json
import re
import boto3

def extract_id_from_url(url):
    """Extract numeric ID from the second-to-last segment of the URL."""
    segments = url.rstrip('/').split('/')
    last_segment = segments[-2] if len(segments) > 1 else ""
    if last_segment.isdigit():
        return int(last_segment)
    else:
        suite_segment = last_segment.split('_')[-1]
        return int(suite_segment) if suite_segment.isdigit() else -1

def normalize_environment(env_raw):
    """Normalize environment names to qa-a or qa-b for reports."""
    env_lower = env_raw.lower()
    if re.match(r'qa[-_]a(_pwa)?$', env_lower):
        return "qa-a"
    elif re.match(r'qa[-_]b(_pwa)?$', env_lower):
        return "qa-b"
    else:
        return env_lower  

def main():
    # Read required environment variables
    tenant = os.environ.get("TENANT")
    environment_raw = os.environ.get("ENVIRONMENT", "")
    environment = normalize_environment(environment_raw)
    new_report_url = os.environ.get("ROBOT_HISTORY_LINK")
    s3_bucket = os.environ.get("ALLURE_REPORTS_BUCKET")
    os_name = os.environ.get("OS", "").strip()

    if not tenant or not new_report_url or not s3_bucket:
        print("Required environment variables TENANT, ROBOT_HISTORY_LINK, or ALLURE_REPORTS_BUCKET missing!")
        return

    # Upload folder in S3
    folder = "multi-tenant-reports"

    # Determine S3 key and local path
    if os_name:
        file_key = f'{folder}/{tenant}_{environment}_{os_name}_robot_reports.json'
        local_file_path = f'{tenant}_{environment}_{os_name}_robot_reports.json'
    else:
        file_key = f'{folder}/{tenant}_{environment}_robot_reports.json'
        local_file_path = f'{tenant}_{environment}_robot_reports.json'

    s3_client = boto3.client('s3')

    # Download existing JSON if present
    try:
        print(f"Downloading {file_key} from S3 bucket {s3_bucket}...")
        s3_client.download_file(s3_bucket, file_key, local_file_path)
        with open(local_file_path, "r") as f:
            robots_json = f.read().strip()
            if not robots_json or robots_json == "{}":
                robot_reports_object = {"reports": []}
            else:
                robot_reports_object = json.loads(robots_json)
    except Exception:
        print(f"No existing file found. Creating new report object for {tenant}-{environment}.")
        robot_reports_object = {"reports": []}

    # Normalize QA in URL
    normalized_url = re.sub(r'qa[-_]a|qa[-_]b', environment, new_report_url, flags=re.IGNORECASE)
    robot_reports_object["reports"].append(normalized_url)

    # Sort by extracted ID and keep only latest 15
    robot_reports_object["reports"].sort(key=extract_id_from_url)
    robot_reports_object["reports"] = robot_reports_object["reports"][-15:]

    with open(local_file_path, "w") as f:
        json.dump(robot_reports_object, f, indent=4)

    # Upload back to S3
    print(f"Uploading updated {file_key} to S3 bucket {s3_bucket}...")
    s3_client.upload_file(local_file_path, s3_bucket, file_key, ExtraArgs={"CacheControl": "no-cache"})

    print(f"Updated {file_key} with {len(robot_reports_object['reports'])} reports successfully.")

if __name__ == "__main__":
    main()
