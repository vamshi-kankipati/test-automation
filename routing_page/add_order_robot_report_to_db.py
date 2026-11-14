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
    file_key = f'reports/{os.environ["TENANT"]}_order_robot_reports.json'
    local_file_path = f'{os.environ["TENANT"]}_order_robot_reports.json'
else:
    file_key = f'reports/{os.environ["TENANT"]}_{os.environ["OS"]}_order_robot_reports.json'
    local_file_path = f'{os.environ["TENANT"]}_{os.environ["OS"]}_order_robot_reports.json'

try:
    print("Download Order Robot Reports Json from S3")
    s3_client.download_file(bucket_name, file_key, local_file_path)
    print("Build Order Robot Reports")
    order_robots_json = str(open(local_file_path, "r").read())
    order_robot_reports = open(local_file_path, "w")
    try:
        if order_robots_json == "{}":
            order_robot_reports_object = {}
        else:
            order_robot_reports_object = json.loads(order_robots_json)
    except Exception as e:
        print(str(e))
        order_robot_reports_object = {"reports": []}
except Exception as e:
    print(str(e))
    order_robot_reports_object = {"reports":[]}
    order_robot_reports = open(local_file_path, "w")

print(f'TENANT: {os.environ["TENANT"]}')
print(f'ROBOT REPORTS OBJECT: {order_robot_reports_object}')
print(f'OS: {os.environ["OS"]}')
print(f'ROBOT HISTORY LINK: {os.environ["ROBOT_HISTORY_LINK"]}')
print("LOCAL_FILE", local_file_path)
print("BUCKET NAME:", bucket_name)
print("FILE KEY:", file_key)

# Store the new report link
new_report_url = os.environ["ROBOT_HISTORY_LINK"]

# Append the new report link
order_robot_reports_object["reports"].append(new_report_url)

# Sort the reports based on the numeric ID extracted from the URL
order_robot_reports_object["reports"].sort(key=extract_id_from_url)

# Keep only the latest 15 reports
order_robot_reports_object["reports"] = order_robot_reports_object["reports"][-15:]

print(f'ROBOT REPORTS OBJECT: {order_robot_reports_object}')

try:
    print("JSON DUMP ROBOT REPORTS")
    dumped_order_robot_reports = json.dumps(order_robot_reports_object)
    order_robot_reports.write(dumped_order_robot_reports)
    order_robot_reports.close()
except Exception as e:
    print(str(e))

print("Upload Order Robot Reports Json to S3")
extra_args = {'CacheControl': 'no-cache'}
s3_client.upload_file(local_file_path, bucket_name, file_key, ExtraArgs=extra_args)
