import os
from os import listdir
import calendar
import time

import requests
import json
from requests.auth import HTTPBasicAuth
import sys


def get_latest_build(projectId, environment):
    #print("Started")
    #print(listdir())
    for fileName in listdir():
        if fileName.endswith('.apk') or fileName.endswith('.ipa'):
            os.remove(fileName)
    username = "abhalla@tillster.com"
    password = "cc342507b8ffbd55fc4ebd0ff73da4c91a1933e4"
    base_url = "https://api.testfairy.com/api/1/projects/"
    get_project_builds_url = base_url + projectId + "/builds"
    response = requests.get(get_project_builds_url, auth = HTTPBasicAuth(username, password))
    #print(response.status_code)
    response_json = response.content
    response_object = json.loads(response_json)
    #print(response_object)
    builds = response_object['builds']
    #print(builds)
    build_id = "not sure"
    download_url = "empty"
    #print(build_id)
    #print(download_url)
    for build in builds:
        env = build['appVersion']
        environment = environment.replace("_", "-")
        if environment in env:
            build_id = build["id"]
            download_url = build["appUrl"]
            break
    #print(build_id)
    #print(download_url)
    # below code is to append timestamp in the file name. but this is not required currently. commented and saved for future use
    # current_gmt = time.gmtime()
    # new_time_stamp = calendar.timegm(current_gmt)
    file_name = "python." + download_url[-3:]
    #file download
    download_file_response = requests.get(download_url, stream=True, auth = HTTPBasicAuth(username, password))
    with open(file_name, "wb") as downloaded_file:
        for chunk in download_file_response.iter_content(chunk_size=1024):

            # writing one chunk at a time to pdf file
            if chunk:
                downloaded_file.write(chunk)

    #print("Upload Started")
    browserstack_upload_url = "https://api-cloud.browserstack.com/app-automate/upload"
    file_to_upload = {'file': open(file_name, 'rb')}
    upload_response = requests.post(browserstack_upload_url, auth = HTTPBasicAuth("ankurbhalla2", "o96zXU5P5nj3qjxnz3xq"), files=file_to_upload)
    #print(upload_response.status_code)
    upload_response_json = upload_response.content
    #print(upload_response_json)
    upload_response_object = json.loads(upload_response_json)
    #print(upload_response_object)
    app_url = upload_response_object["app_url"]
    print(app_url)
    return app_url



if __name__ == '__main__':
    get_latest_build(sys.argv[1], sys.argv[2])