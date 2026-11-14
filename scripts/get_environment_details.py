import sys

import yaml
import requests
import json
import os
from datetime import datetime


base_url = "https://studio.cucumber.io"
cookie = "_app_session=ghYv0Wvwjn%2F%2FNws2mHfOdjnT9p3N5qHcsThdhbOft%2F00yGsEJyC4Tx6vQC0h7gq0%2B004Hi5zuV%2FqNRFrYf1eSTtHX5J48JKTS6yHNw5VaDw5XJxbqOihxxpi8jK4XvJild1xd4cE7zFqaij1cwBhBcs2ZPXZOa6GtzmyFpb2KOyK9ViuWJOOlxoYUV70h3QNY0DKJGctSy9POVZ6leU7kMynuR3yWghGQbnJphaOe0nRQIdID21MreHL5HU%2Fvm4HYi1j5ebiUBsGXqp9n2vv0%2B8W7N%2Fs54SOIFa0VQ%3D%3D--VKLc%2B%2Byr6oN8Kabm--0collAkrBiajvEq6UAo2QA%3D%3D; hui=eyJfcmFpbHMiOnsibWVzc2FnZSI6IklqazJOREkySWc9PSIsImV4cCI6bnVsbCwicHVyIjoiY29va2llLmh1aSJ9fQ%3D%3D--eddcaff23e880109952c857ea42b794bf621de11; user_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6Ik9UWTBNalk9IiwiZXhwIjpudWxsLCJwdXIiOiJjb29raWUudXNlcl9pZCJ9fQ%3D%3D--43c6e07f1274f0b2b37118af115c2825d1309c72; _app_session=Lr%2BYfUc6JFoUUAVvelN68yE1tonffiwmsmDcT35FIzQraOnen8bSM1IahLQgCuW8tbniEA1p85hLcPRRtWtnjDHjw%2FzeEqxU23Chc9cnyDbrlsGFrOxxH%2Fa8Z1p6PHY3wc20EqAfDHfmvISnmpTdlcf0syqzGgZYLRXoJ8RRVnEkCDo8qKgJyptyIpn%2FTHfdaUDbpcJ1dhXA8vAQqmlLLczLzFXv2TV12jAgh7KCm5moReBkU2gtEvCB0FEaXOh4Sy%2Fjp4PcFGQB607c44Ybxjsb4BeqwYuCC5lmwQ%3D%3D--kKUmTGn3mPi0t%2F1f--weIS%2FXX5nXjNySEMflfElQ%3D%3D; hui=eyJfcmFpbHMiOnsibWVzc2FnZSI6IklqazJOREkySWc9PSIsImV4cCI6bnVsbCwicHVyIjoiY29va2llLmh1aSJ9fQ%3D%3D--eddcaff23e880109952c857ea42b794bf621de11; user_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6Ik9UWTBNalk9IiwiZXhwIjpudWxsLCJwdXIiOiJjb29raWUudXNlcl9pZCJ9fQ%3D%3D--43c6e07f1274f0b2b37118af115c2825d1309c72"
# CS API Token valid till 24-July-2024
headers = {
        'access-token': '6VobBf-bN64sUmBTwafsGA',
        'client': 'kUQZKExuHsPArzZsUMks4Q',
        'uid': 'abhalla@tillster.com',
        'Accept': 'application/vnd.api+json; version=1',
        'Cookie': cookie
    }

def get_web_environment_details(tenant, environment, value):
    #print(tenant)
    #print(environment)
    #fileName = "D:/Tillster/UI-Repo-Robot-With-Browser_For_Execution/ui-test-automation/config_files/environment-map_TO_BE_DELETED.yaml"
    #os.chdir('..')
    #print(os.getcwd())
    fileName = "../config_files/environment-map.yaml"
    with open(fileName, 'r')as stream:
        try:
            dict = yaml.safe_load(stream)
            #print(dict)
            value_to_get = ""
            if "testrun" in value.lower():
                value_to_get = "testRunId"
            elif "menutestrun" in value.lower():
                value_to_get = "menuTestRunId"
            elif "projectid" in value.lower():
                value_to_get = "projectId"
            elif "token" in value.lower():
                value_to_get = "token"
            final_value = dict[tenant][environment][value_to_get]
            #print("test run id is " + str(final_value))
            #sys.__stdout__.write("The final value to return is: --- " + str(final_value) + "\n")
            #print(final_value)
            return final_value
        except yaml.YAMLError as e:
            print(e)

def get_mobile_environment_details(tenant, environment, platform, value):
    #print(tenant)
    #print(environment)
    platform = platform.lower()
    #fileName = "D:/Tillster/UI-Repo-Robot-With-Browser_For_Execution/ui-test-automation/config_files/environment-map_TO_BE_DELETED.yaml"
    #os.chdir('..')
    #print(os.getcwd())
    fileName = "../config_files/environment-map.yaml"
    with open(fileName, 'r') as stream:
        try:
            dict = yaml.safe_load(stream)
            #print(dict)
            value_to_get = ""
            if "testrun" in value.lower():
                value_to_get = "testRunId"
                final_value = dict[tenant][environment][platform][value_to_get]
                #print("Test Run ID is " + str(final_value))
                return final_value
            elif "testfairy" in value.lower():
                value_to_get = "testFairyProjectId"
                final_value = dict[tenant][environment][platform][value_to_get]
            elif "menutestrun" in value.lower():
                value_to_get = "menuTestRunId"
                final_value = dict[tenant][environment][platform][value_to_get]
            elif "projectid" in value.lower():
                value_to_get = "projectId"
            elif "token" in value.lower():
                value_to_get = "token"
            final_value = dict[tenant][environment][value_to_get]
            #print("Final value is " + final_value)
            #sys.__stdout__.write("The final value to return is: --- " + str(final_value) + "\n")
            #print(final_value)
            return final_value
        except yaml.YAMLError as e:
            print(e)


def create_new_test_run_web(tenant, environment, tag):
    #print("create new test run")
    project_id = get_web_environment_details(tenant, environment, "projectid")
    automation_tag_id = get_tag_id(project_id, "Status")
    target_tag_id = get_tag_id(project_id, tag)
    #print("automation tag id is " + str(automation_tag_id))

    tenant_folders_ids = get_tenant_folders_ids(project_id, tenant)
    #print("____________Tenant folders list________________")
    #print(tenant_folders_ids)
    #print(len(tenant_folders_ids))

    #get_filtered_test_cases_for_test_run(project_id, tenant_folders_ids, tag_key, tag_value, filtered_test_list)
    automated_test_cases_for_tenant = get_filtered_test_cases_for_test_run(project_id, tenant_folders_ids, [], "Status", "Automated")
    #print("##########################################")
    #print(automated_test_cases_for_tenant)
    #print("automated test cases " + str(len(automated_test_cases_for_tenant)))

    tag_key = ""
    tag_value = ""
    if ":" in tag:
        tag_key_value = tag.split(":")
        tag_key = tag_key_value[0]
        tag_value = tag_key_value[1]
    else:
        tag_key = tag
        tag_value = ""
    filtered_automated_test_cases_for_tenant = get_filtered_test_cases_for_test_run(project_id, tenant_folders_ids, automated_test_cases_for_tenant, tag_key, tag_value)
    #print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
    #print(filtered_automated_test_cases_for_tenant)
    #print("Final test cases " + str(len(filtered_automated_test_cases_for_tenant)))

    current_date_time = datetime.now()
    formated_date_time = current_date_time.strftime("%d-%m-%Y %H:%M:%S")
    new_test_run_name = tenant + "_" + environment + "_Web_" + formated_date_time
    new_test_run_id = create_test_run(project_id, filtered_automated_test_cases_for_tenant, new_test_run_name)
    #print("new test run id is " + str(new_test_run_id))
    #os.environ["NEWTESTRUNID"] = new_test_run_id
    return new_test_run_id


def create_new_test_run_mobile(tenant, environment, platform, tag_list):
    #print("create new test run")
    project_id = ""
    if "web" in platform.lower():
        project_id = get_web_environment_details(tenant, environment, "projectid")
    else:
        project_id = get_mobile_environment_details(tenant, environment, platform, "projectid")

    #automation_tag_id = get_tag_id(project_id, "Status")  ## this is not required for now. also this calls is failing as it is required to sign-in
    #target_tag_id = get_tag_id(project_id, tag)  # this is not required for now. also this calls is failing as it is required to sign-in
    #print("automation tag id is " + str(automation_tag_id))

    tenant_folders_ids = get_tenant_folders_ids(project_id, tenant)
    #print("____________Tenant folders list________________")
    #print(tenant_folders_ids)
    #print(len(tenant_folders_ids))

    #get_filtered_test_cases_for_test_run(project_id, tenant_folders_ids, tag_key, tag_value, filtered_test_list)
    automated_test_cases_for_tenant = get_filtered_test_cases_for_test_run(project_id, tenant_folders_ids, [], "Status", "Automated")
    #print("##########################################")
    #print(automated_test_cases_for_tenant)
    #print("automated test cases " + str(len(automated_test_cases_for_tenant)))

    final_filtered_automated_test_cases_for_tenant = []
    for tag in tag_list:
        tag_key = ""
        tag_value = ""
        if ":" in tag:
            tag_key_value = tag.split(":")
            tag_key = tag_key_value[0]
            tag_value = tag_key_value[1]
        else:
            tag_key = tag
            tag_value = ""
        filtered_automated_test_cases_for_tenant = get_filtered_test_cases_for_test_run(project_id, tenant_folders_ids,
                                                                                        automated_test_cases_for_tenant,
                                                                                        tag_key, tag_value)
        final_filtered_automated_test_cases_for_tenant = final_filtered_automated_test_cases_for_tenant + list(set(filtered_automated_test_cases_for_tenant) - set(final_filtered_automated_test_cases_for_tenant))

    ####filtered_automated_test_cases_for_tenant = get_filtered_test_cases_for_test_run(project_id, tenant_folders_ids, tag, "", automated_test_cases_for_tenant)
    #print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
    #print(filtered_automated_test_cases_for_tenant)
    #print("Final test cases " + str(len(filtered_automated_test_cases_for_tenant)))

    current_date_time = datetime.now()
    formated_date_time = current_date_time.strftime("%d-%m-%Y %H:%M:%S")
    new_test_run_name = tenant + "_" + environment + "_" + platform + "_" + formated_date_time
    new_test_run_id = create_test_run(project_id, final_filtered_automated_test_cases_for_tenant, new_test_run_name)
    #print("new test run id is " + str(new_test_run_id))
    os.environ["NEWTESTRUNID"] = new_test_run_id
    return new_test_run_id



def get_tag_id(project_id, tag_name):
    #print(project_id)
    get_tags_request_url = base_url + "/tags?projectId=" + str(project_id) + "&taggableType=scenario"
    response = requests.request("GET", get_tags_request_url, headers=headers)
    #print(response.status_code)
    response_json = response.content
    response_object = json.loads(response_json)
    #print("response json" + str(response_json))
    target_tag_id = 0
    tags = response_object["tags"]
    for tag in tags:
        #print(tag)
        if tag_name == "Status":
            if tag["key"] == "Status" and tag["value"] == "Automated":
                target_tag_id = tag["id"]
                break
        else:
            if tag["key"] == tag_name:
                target_tag_id = tag["id"]
                break
    return target_tag_id

def get_tenant_folders_ids(project_id, tenant):
    #print("Inside get tenant folders " + tenant)
    folders_list = []
    get_tenant_folders_request_url = base_url + "/api/projects/" + str(project_id) + "/folders"
    #print(get_tenant_folders_request_url)
    response = requests.request("GET", get_tenant_folders_request_url, headers=headers)
    #print(response.status_code)
    response_json = response.content
    response_object = json.loads(response_json)
    #print("response json" + str(response_json))
    folders_node = response_object["data"]
    #print("Total number of folders " + str(len(folders_node)))
    for folder in folders_node:
        if folder["attributes"]["name"] == tenant:
            folders_list.append(int(folder["id"]))
            break

    continue_loop = True
    while continue_loop:
        child_folder_found = False
        for folder in folders_node:
            if folder["attributes"]["parent-id"] in folders_list and int(folder["id"]) not in folders_list:
                folders_list.append(int(folder["id"]))
                child_folder_found = True
                break
        if  not child_folder_found:
            break

    return folders_list


# the below method is not being used
def get_automated_test_cases_for_test_run_old(project_id, tenant_folders_ids, target_tag_id):
    #print(project_id)
    test_cases_list = []
    get_tenant_test_cases_request_url = base_url + "/api/projects/" + str(project_id) + "/scenarios/find_by_tags?key=Status&value=Automated&include=tags"
    response = requests.request("GET", get_tenant_test_cases_request_url, headers=headers)
    #print(response.status_code)
    response_json = response.content
    response_object = json.loads(response_json)
    #print("response json for filtred tests \n" + str(response_object))
    test_cases = response_object["data"]
    for test_case in test_cases:
        if test_case["attributes"]["folder-id"] in tenant_folders_ids:
            test_case_tags = test_case["relationships"]["tags"]["data"]
            for test_case_tag in test_case_tags:
                if int(test_case_tag["id"]) == target_tag_id:
                    test_cases_list.append(test_case["id"])

    return test_cases_list

def get_filtered_test_cases_for_test_run(project_id, tenant_folders_ids, filtered_test_list, tag_key, tag_value):
    #print(project_id)
    test_cases_list = []
    get_tenant_test_cases_request_url = base_url + "/api/projects/" + str(project_id) + "/scenarios/find_by_tags?key=" + tag_key + "&value=" + tag_value + "&include=tags"
    response = requests.request("GET", get_tenant_test_cases_request_url, headers=headers)
    #print(response.status_code)
    response_json = response.content
    response_object = json.loads(response_json)
    #print("response json for filtred tests \n" + str(response_object))
    test_cases = response_object["data"]
    for test_case in test_cases:
        if test_case["attributes"]["folder-id"] in tenant_folders_ids:
            if len(filtered_test_list) < 1:
                test_cases_list.append(test_case["id"])
            else:
                if test_case["id"] in filtered_test_list:
                    test_cases_list.append(test_case["id"])

    return test_cases_list


def create_test_run(project_id, test_cases_list, test_run_name):
    create_test_run_request_url = base_url + "/api/projects/" + str(project_id) + "/test_runs?include=tags"
    attributes = {"name":test_run_name, "description":"New Test Run", "scenario_ids":test_cases_list}
    data = {"attributes":attributes}
    payload = {"data":data}
    payload_json = json.dumps(payload)
    #print(payload_json)
    response = requests.request("POST", create_test_run_request_url, headers=headers, data=payload_json)
    response_json = response.content
    response_object = json.loads(response_json)
    #print(response.status_code)
    #print("response for crete test run" + str(response_object))
    test_run_id = response_object["data"]["id"]
    return test_run_id



if __name__ == '__main__':
    final_value = None;
    if "newtestrun" not in sys.argv[1].lower():
        if "web" in sys.argv[2]:
            final_value = get_web_environment_details(sys.argv[2], sys.argv[3], sys.argv[5])
        elif "mobile" in sys.argv[2]:
            #print("in mobile method")
            final_value = get_mobile_environment_details(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
    else:
        #print("get new test run")
        # commented below code as it is not required
        # args_length = len(sys.argv)
        # tags_list = []
        # for i in range(5, args_length):
        #     tags_list.append(sys.argv[i])

        tags_length = len(sys.argv[6])
        tags_list = sys.argv[6][1:tags_length-1]
        tags_list = tags_list.split('!')
        if "web" in sys.argv[2]:
            final_value = create_new_test_run_mobile(sys.argv[2], sys.argv[3], sys.argv[4], tags_list)
        elif "mobile" in sys.argv[2]:
            #print("in mobile method")
            final_value = create_new_test_run_mobile(sys.argv[2], sys.argv[3], sys.argv[4], tags_list)
    print(final_value)