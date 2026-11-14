import json
import os
import re
import boto3


def extract_id_from_url(url):
    segments = url.rstrip('/').split('/')
    last_segment = segments[-2] if len(segments) > 1 else ""

    if last_segment.isdigit():
        return int(last_segment)
    else:
        suite_segment = last_segment.split('_')[-1]
        return int(suite_segment) if suite_segment.isdigit() else -1


def normalize_environment(env_raw):
    """Normalize environment names to qa-a or qa-b."""
    env_lower = env_raw.lower()

    if re.match(r'qa[-_]a(_pwa)?$', env_lower):
        return "qa-a"
    elif re.match(r'qa[-_]b(_pwa)?$', env_lower):
        return "qa-b"
    else:
        return env_lower


s3_client = boto3.client('s3')

# Read env variables
tenant = os.environ.get("TENANT")
environment_raw = os.environ.get("ENVIRONMENT", "")
environment = normalize_environment(environment_raw)
bucket_name = os.environ.get("ALLURE_REPORTS_BUCKET")
os_name = os.environ.get("OS", "").strip()
new_report_url = os.environ.get("ALLURE_LINK")

# Validate required vars
if not tenant or not bucket_name or not new_report_url:
    raise Exception("Missing required env vars: TENANT, ALLURE_REPORTS_BUCKET, or ALLURE_LINK")

# Folder
folder = "multi-tenant-reports"

# Determine file key and local file path
if os_name:
    file_key = f'{folder}/{tenant}_{environment}_{os_name}_allure_reports.json'
    local_file_path = f'{tenant}_{environment}_{os_name}_allure_reports.json'
else:
    file_key = f'{folder}/{tenant}_{environment}_allure_reports.json'
    local_file_path = f'{tenant}_{environment}_allure_reports.json'

# Download existing JSON
try:
    print("Download Allure Reports Json from S3")
    s3_client.download_file(bucket_name, file_key, local_file_path)

    with open(local_file_path, "r") as f:
        allure_json = f.read().strip()

        if not allure_json or allure_json == "{}":
            allure_reports_object = {"reports": []}
        else:
            allure_reports_object = json.loads(allure_json)

except Exception:
    print(f"No existing file found. Creating new report object for {tenant}-{environment}.")
    allure_reports_object = {"reports": []}

print(f'TENANT: {tenant}')
print(f'ENVIRONMENT: {environment}')
print(f'OS: {os_name}')
print(f'ALLURE LINK (raw): {new_report_url}')
print("FILE KEY:", file_key)

# Normalize environment inside URL
normalized_url = re.sub(r'qa[-_]a|qa[-_]b', environment, new_report_url, flags=re.IGNORECASE)

# Ensure reports key
allure_reports_object.setdefault("reports", [])

# Append new report
allure_reports_object["reports"].append(normalized_url)

# Sort and keep latest 3
allure_reports_object["reports"].sort(key=extract_id_from_url)
allure_reports_object["reports"] = allure_reports_object["reports"][-3:]

print(f'UPDATED REPORTS: {allure_reports_object}')

# Write JSON
with open(local_file_path, "w") as f:
    json.dump(allure_reports_object, f, indent=4)

# Upload back to S3
print("Upload allure Reports Json to S3")
s3_client.upload_file(
    local_file_path,
    bucket_name,
    file_key,
    ExtraArgs={'CacheControl': 'no-cache'}
)

print(f"Successfully updated {file_key}")
