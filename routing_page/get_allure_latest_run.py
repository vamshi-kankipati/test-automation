import json
import os
import boto3


def extract_id_from_url(url):
    segments = url.rstrip('/').split('/')
    last_segment = segments[-2]

    if last_segment.isdigit():
        return int(last_segment)
    else:
        suite_segment = last_segment.split('_')[-1]
        if suite_segment.isdigit():
            return int(suite_segment)
        else:
            return -1

s3_client = boto3.client('s3')
bucket_name = os.environ["ALLURE_REPORTS_BUCKET"]

# Determine the file key and local file path
if os.environ.get("OS", "").strip() == "":
    file_key = f'reports/{os.environ["TENANT"]}_allure_reports.json'
    local_file_path = f'{os.environ["TENANT"]}_allure_reports.json'
else:
    file_key = f'reports/{os.environ["TENANT"]}_{os.environ["OS"]}_allure_reports.json'
    local_file_path = f'{os.environ["TENANT"]}_{os.environ["OS"]}_allure_reports.json'

try:
    print("Download Allure Reports Json from S3")
    s3_client.download_file(bucket_name, file_key, local_file_path)
    print("Build Allure Reports")
    allure_json = str(open(local_file_path, "r").read())
    allure_reports = open(local_file_path, "w")
    try:
        if allure_json == "{}":
            allure_reports_object = {}
        else:
            allure_reports_object = json.loads(allure_json)
    except Exception as e:
        print(str(e))
        allure_reports_object = {"reports": []}
except Exception as e:
    print(str(e))
    allure_reports_object = {"reports":[]}
    allure_reports = open(local_file_path, "w")

print(f'TENANT: {os.environ["TENANT"]}')
print(f'allure REPORTS OBJECT: {allure_reports_object}')
print(f'OS: {os.environ["OS"]}')
print(f'ALLURE LINK: {os.environ["ALLURE_LINK"]}')
print("LOCAL_FILE", local_file_path)
print("BUCKET NAME:", bucket_name)
print("FILE KEY:", file_key)
    
# Store the new report link
new_report_url = os.environ["ALLURE_LINK"]


# Append the new report link
allure_reports_object["reports"].append(new_report_url)

# Sort the reports based on the numeric ID extracted from the URL
allure_reports_object["reports"].sort(key=extract_id_from_url)

# Keep only the latest 3 reports
allure_reports_object["reports"] = allure_reports_object["reports"][-3:]

print(f'ALLURE REPORTS OBJECT: {allure_reports_object}')

try:
    print("JSON DUMP allure REPORTS")
    dumped_allure_reports = json.dumps(allure_reports_object)
    allure_reports.write(dumped_allure_reports)
    allure_reports.close()
except Exception as e:
    print(str(e))

print("Upload allure Reports Json to S3")
extra_args = {'CacheControl': 'no-cache'}
s3_client.upload_file(local_file_path, bucket_name, file_key, ExtraArgs=extra_args)
