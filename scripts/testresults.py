import sys
import requests
import json
import datetime
import pygsheets


def fetch_and_update_test_results_CS(*args):

    # CS API Token valid till 23-May-2025
    cs_api_headers = {
        'access-token': 'b-wbGptET4JYIuWzyV69jg',
        'client': 'iM64VMT8A0J0ebSq3FJCPg',
        'uid': 'srajendran@tillster.com',
        'Accept': 'application/vnd.api+json; version=1'
    }

    cs_ui_headers = {
        'x-csrf-token': 'uLsfDYTh/pYfIUuBY5M89HQF6op4EvYD2koHdzeQKO76EXWBPdpvQFrcSrpYqJwcO1VSMCcmmnHveVqC3wL0kw==',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': '*/*',
        'Cookie': '_ga=GA1.1.173319314.1745716728; testRunSynchroRetestPref=false; hui=eyJfcmFpbHMiOnsibWVzc2FnZSI6Iklqa3lOakExSWc9PSIsImV4cCI6bnVsbCwicHVyIjoiY29va2llLmh1aSJ9fQ%3D%3D--bfd1ebe7d06b4d1cc79d79a0627f262fddef1aaa; user_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6Ik9USTJNRFU9IiwiZXhwIjpudWxsLCJwdXIiOiJjb29raWUudXNlcl9pZCJ9fQ%3D%3D--10bc16562430def1337c002ea2f1f2ef60be559d; _ga_E1081Q014T=GS2.1.s1759474417$o6$g0$t1759474423$j54$l0$h0; _ga_Q17C4B81S5=GS2.1.s1774892734$o739$g1$t1774892764$j30$l0$h0; _app_session=aioNolmGfL1pxonYcEbvZr21uVY1%2Fqv74iSW79KtM6JkEMQ6FHSqm3yh0smS7VtBmIZYOsTvq9ZvfJY0vPAqnGm7hCwDGqaaJ3EqK1VsdEMis0%2BY1qA9qKt9yjQu9dINnO7%2BMJzaNKemzWeo9aUAEnZpT5w98lmBYlGAKE2bnNmQ6PFYKkRs0Ln3nwNocFz3dSDTI3rpPc5ucFekhNxKj2X%2BASJ8TACXtpOTdTEF4bQBkev6pWdoW1oPju4x62eD%2FG0gXGPAQvifiORHgTzt0Z5finmZ%2BG%2FcPTipamZLZ7bwbmfh%2BVzGswJ3stoyaZCcoUiWzy03rSfVbd0mAQvhw9oJSGMkhQ77ofsmjxr%2B8tuVO1kheF%2FXEWyhiNUZgEf%2BpQcAdjkGBrDp2zHY--GemUhcAY9m0p81Rf--lyHmxRku1qAi1LhCAXIOKw%3D%3D'

    }

    #   Open google spreadsheet
    config_path = "../majestic-option-385817-78708383e734.json"
    gc = pygsheets.authorize(service_file=config_path)
    sh = gc.open('UI Test Automation Report')
    wks = sh.worksheet_by_title(args[1])

    #   Loop  through test run id's
    for tenant in args[2:]:

        # Get the automation test results for a project
        base_url = "https://studio.cucumberstudio.com/test_runs?ids[]="+tenant

        response = requests.request("GET", base_url, headers=cs_ui_headers)
        response_json = response.content
        response_object = json.loads(response_json)
        test_runs = response_object["test_runs"]

        #   Check if the response for the test run id returns empty list; if so then do not update anything into the spreadsheet
        if test_runs:
            tag_key_name = ""            # Resetting the value to be empty, so stale value is not passed to the manual test cases endpoint from the previous project, if no manual tag is found for the current project id
            tag_value_name = ""
            for test_run in test_runs:
                test_run_name = test_run["name"]
                project_id = test_run["project_id"]
                tests_count = test_run["tests_count"]
                test_run_id = test_run["id"]
                test_run_description = test_run["description"]
                tests_passed = test_run["cached_statuses"]["passed"]
                tests_failed = test_run["cached_statuses"]["failed"]
                tests_undefined = test_run["cached_statuses"]["undefined"]
                date = str(datetime.date.today())

            #  Get the total number of test cases in a project
            test_cases_base_url = "https://studio.cucumberstudio.com/api/projects/"+str(project_id)+"/scenarios"
            test_cases_response = requests.request("GET", test_cases_base_url, headers=cs_api_headers)
            test_cases_response_json = test_cases_response.content
            test_cases_response_object = json.loads(test_cases_response_json)
            test_cases = test_cases_response_object["data"]
            total_number_of_test_cases = len(test_cases)

            #  Get the tags in a project and filter for the manual tag
            tags_base_url = "https://studio.cucumberstudio.com/tags?projectId="+str(project_id)+"&taggableType=scenario"
            tags_response = requests.request("GET", tags_base_url, headers=cs_ui_headers)
            tags_response_json = tags_response.content
            tags_response_object = json.loads(tags_response_json)
            tags_list = tags_response_object["tags"]

            for tag in tags_list:
                tag_key = tag["key"]
                tag_value = tag["value"]
                if tag_value == 'Manual' or tag_value == 'manual' or tag_key == 'Manual' or tag_key == 'manual':
                    tag_key_name = tag_key           # If there is no manual tag, then to avoid sending the last tag key and value, assigning the key and value to a temp variable only when manual tag is found
                    tag_value_name = tag_value
                    break


            #  Get the number of manual test cases in a project
            manual_cases_base_url = "https://studio.cucumberstudio.com/api/projects/"+str(project_id)+"/scenarios/find_by_tags?key="+tag_key_name+"&value="+tag_value_name
            manual_cases_response = requests.request("GET", manual_cases_base_url, headers=cs_api_headers)
            manual_cases_response_json = manual_cases_response.content
            manual_cases_response_object = json.loads(manual_cases_response_json)
            manual_cases = manual_cases_response_object["data"]
            total_number_of_manual_cases = len(manual_cases)

            number_of_NTA_NTU_cases = total_number_of_test_cases - (total_number_of_manual_cases + tests_count)

            print("total number of test cases", total_number_of_test_cases)
            #  Get the total number of test cases in Archive folder - Retrieves number of test cases based on the tag in the Archive folder
            test_cases_base_url = "https://studio.cucumberstudio.com/api/projects/"+str(project_id)+"/folders/find_by_tags?key=Archive"
            test_cases_response = requests.request("GET", test_cases_base_url, headers=cs_api_headers)
            test_cases_response_json = test_cases_response.content
            test_cases_response_object = json.loads(test_cases_response_json)
            if test_cases_response_object["data"]:                                                      #Perform the below steps to exclude the test cases in Archive folder from total number of test cases, only if the Archive folder exists
                test_cases = test_cases_response_object["data"][0]["attributes"]["scenarios-count"]
                total_number_of_test_cases = total_number_of_test_cases - test_cases
                print("total number of test cases" , total_number_of_test_cases , "archive test cases" , test_cases)

            wks.append_table([date,test_run_name,total_number_of_test_cases,total_number_of_manual_cases,number_of_NTA_NTU_cases,tests_count,tests_passed,tests_failed,tests_undefined,test_run_description,project_id,test_run_id], overwrite=True)

        else:
            pass

def fetch_and_update_test_results(*args):

    # CS API Token valid till 23-May-2025
    cs_api_headers = {
        'access-token': 'b-wbGptET4JYIuWzyV69jg',
        'client': 'iM64VMT8A0J0ebSq3FJCPg',
        'uid': 'srajendran@tillster.com',
        'Accept': 'application/vnd.api+json; version=1'
    }

    cs_ui_headers = {
        'x-csrf-token': 'uLsfDYTh/pYfIUuBY5M89HQF6op4EvYD2koHdzeQKO76EXWBPdpvQFrcSrpYqJwcO1VSMCcmmnHveVqC3wL0kw==',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': '*/*',
        'Cookie': '_ga=GA1.1.173319314.1745716728; testRunSynchroRetestPref=false; hui=eyJfcmFpbHMiOnsibWVzc2FnZSI6Iklqa3lOakExSWc9PSIsImV4cCI6bnVsbCwicHVyIjoiY29va2llLmh1aSJ9fQ%3D%3D--bfd1ebe7d06b4d1cc79d79a0627f262fddef1aaa; user_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6Ik9USTJNRFU9IiwiZXhwIjpudWxsLCJwdXIiOiJjb29raWUudXNlcl9pZCJ9fQ%3D%3D--10bc16562430def1337c002ea2f1f2ef60be559d; _ga_E1081Q014T=GS2.1.s1759474417$o6$g0$t1759474423$j54$l0$h0; _ga_Q17C4B81S5=GS2.1.s1774892734$o739$g1$t1774892764$j30$l0$h0; _app_session=aioNolmGfL1pxonYcEbvZr21uVY1%2Fqv74iSW79KtM6JkEMQ6FHSqm3yh0smS7VtBmIZYOsTvq9ZvfJY0vPAqnGm7hCwDGqaaJ3EqK1VsdEMis0%2BY1qA9qKt9yjQu9dINnO7%2BMJzaNKemzWeo9aUAEnZpT5w98lmBYlGAKE2bnNmQ6PFYKkRs0Ln3nwNocFz3dSDTI3rpPc5ucFekhNxKj2X%2BASJ8TACXtpOTdTEF4bQBkev6pWdoW1oPju4x62eD%2FG0gXGPAQvifiORHgTzt0Z5finmZ%2BG%2FcPTipamZLZ7bwbmfh%2BVzGswJ3stoyaZCcoUiWzy03rSfVbd0mAQvhw9oJSGMkhQ77ofsmjxr%2B8tuVO1kheF%2FXEWyhiNUZgEf%2BpQcAdjkGBrDp2zHY--GemUhcAY9m0p81Rf--lyHmxRku1qAi1LhCAXIOKw%3D%3D'

    }

    #   Open google spreadsheet
    config_path = "../majestic-option-385817-78708383e734.json"
    gc = pygsheets.authorize(service_file=config_path)
    sh = gc.open('UI Test Automation Report')
    wks = sh.worksheet_by_title(args[1])

    #   Loop  through test run id's
    for tenant in args[2:]:

        tenant = tenant.split(",")
        project_token = tenant[0]
        test_run_id = tenant[1]
        project_id = tenant[2]
        # Get the automation test results for a project
        base_url = "https://praxis.tillster.com/api/projects/" + str(project_token) + "/test_runs/" + str(test_run_id)

        response = requests.request("GET", base_url)
        response_json = response.content
        response_object = json.loads(response_json)
        # test_runs = response_object["test_runs"]
        # data = response_object["data"]

        #   Check if the response for the test run id returns empty list; if so then do not update anything into the spreadsheet
        if "data" in response_object:
            tag_key_name = ""            # Resetting the value to be empty, so stale value is not passed to the manual test cases endpoint from the previous project, if no manual tag is found for the current project id
            tag_value_name = ""
            data = response_object["data"]
            test_run_name = data["attributes"]["name"]
            # project_id = test_run["project_id"]
            tests_count = data["attributes"]["tests-count"]
            test_run_id = data["id"]
            test_run_description = data["attributes"]["description"]
            tests_passed = data["attributes"]["statuses"]["passed"]
            tests_failed = data["attributes"]["statuses"]["failed"]
            tests_undefined = data["attributes"]["statuses"]["untested"]
            date = str(datetime.date.today())

            #  Get the total number of test cases in a project
            test_cases_base_url = "https://praxis.tillster.com/api/projects/"+str(project_token)+"/scenarios"
            test_cases_response = requests.request("GET", test_cases_base_url)
            test_cases_response_json = test_cases_response.content
            test_cases_response_object = json.loads(test_cases_response_json)
            test_cases = test_cases_response_object["data"]
            total_number_of_test_cases = len(test_cases)

            #  Get the tags in a project and filter for the manual tag
            tags_base_url = "https://praxis.tillster.com/api/projects/" + str(project_token) + "/tags"
            tags_response = requests.request("GET", tags_base_url)
            tags_response_json = tags_response.content
            tags_response_object = json.loads(tags_response_json)
            tags_list = tags_response_object["data"]

            for tag in tags_list:
                # tag_key = tag["key"]
                tag_value = tag["id"]
                if tag_value == 'Manual' or tag_value == 'manual':
                    # tag_key_name = tag_key           # If there is no manual tag, then to avoid sending the last tag key and value, assigning the key and value to a temp variable only when manual tag is found
                    tag_value_name = tag_value
                    break


            #  Get the number of manual test cases in a project
            # manual_cases_base_url = "https://praxis.tillster.com/api/projects/"+str(project_token)+"/scenarios/find_by_tags?key="+tag_key_name+"&value="+tag_value_name
            manual_cases_base_url = "https://praxis.tillster.com/api/projects/" + str(
                project_token) + "/scenarios/find_by_tags?key=" + tag_value_name
            manual_cases_response = requests.request("GET", manual_cases_base_url)
            manual_cases_response_json = manual_cases_response.content
            manual_cases_response_object = json.loads(manual_cases_response_json)
            manual_cases = manual_cases_response_object["data"]
            total_number_of_manual_cases = len(manual_cases)

            number_of_NTA_NTU_cases = total_number_of_test_cases - (total_number_of_manual_cases + tests_count)

            print("total number of test cases", total_number_of_test_cases)
            #  Get the total number of test cases in Archive folder - Retrieves number of test cases based on the tag in the Archive folder
            test_cases_base_url = "https://praxis.tillster.com/api/projects/"+str(project_token)+"/folders/find_by_tags?key=Archive"
            test_cases_response = requests.request("GET", test_cases_base_url, headers=cs_api_headers)
            test_cases_response_json = test_cases_response.content
            test_cases_response_object = json.loads(test_cases_response_json)
            if test_cases_response_object["data"]:                                                      #Perform the below steps to exclude the test cases in Archive folder from total number of test cases, only if the Archive folder exists
                test_cases = test_cases_response_object["data"][0]["attributes"]["scenarios-count"]
                total_number_of_test_cases = total_number_of_test_cases - test_cases
                print("total number of test cases" , total_number_of_test_cases , "archive test cases" , test_cases)

            wks.append_table([date,test_run_name,total_number_of_test_cases,total_number_of_manual_cases,number_of_NTA_NTU_cases,tests_count,tests_passed,tests_failed,tests_undefined,test_run_description,project_id,test_run_id], overwrite=True)

            wks.append_table([date,test_run_name,total_number_of_test_cases,total_number_of_manual_cases,number_of_NTA_NTU_cases,tests_count,tests_passed,tests_failed,tests_undefined,test_run_description,project_id,test_run_id], overwrite=True)

        else:
            pass


if __name__ == '__main__':
    fetch_and_update_test_results(*sys.argv)
    # fetch_and_update_test_results("","web_prod","1041674")
    # fetch_and_update_test_results("", "web_feature_development", "4711883172970063775541,1083595")
    # fetch_and_update_test_results("", "web_feature_development", "6471772068185436455273,1099829,99")
    # fetch_and_update_test_results_praxis("", "web_prod", ["6293252153497947913585", "9968"])
