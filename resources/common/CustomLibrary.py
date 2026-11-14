import appium
from robot.libraries.BuiltIn import BuiltIn
from appium import webdriver
# import subprocess
# from AppiumLibrary import AppiumLibrary
# from appium.webdriver.common.appiumby import AppiumBy
# from selenium.webdriver.common.action_chains import ActionChains
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import *
import time, json, requests, os, shutil, string
from git.repo.base import Repo
from email.header import Header, decode_header, make_header
import difflib
import subprocess, allure
from requests.auth import HTTPBasicAuth
from os import listdir
from bs4 import BeautifulSoup
import urllib3
from PIL import Image
from logging import debug, error, info, warn
from urllib.parse import unquote
from babel.numbers import parse_decimal
from babel.dates import format_datetime
import re
import dateparser


class CustomLibrary:

    def __init__(self, username, password):
        self.driver = None
        self.username = username
        self.password = password

    # Function to get driver instance
    def get_the_driver_instance(self):
        applium_lib = BuiltIn().get_library_instance('AppiumLibrary')
        self.driver = applium_lib._current_application()

    # Function to activate the applications that are installed on the device
    def activate_the_app(self, package_name):
        self.driver.activate_app(package_name)

    # Function to terminate the applications that are installed on the device
    def terminate_the_app(self, package_name):
        self.driver.terminate_app(package_name)

    def choose_an_option_by_index_from_ios_dropdown(self, dropdown_options, index):
        flag = 'True'
        paramss = {'order': 'next', 'offset': 0.15, 'element': dropdown_options}
        for index_value in range(index):
            try:
                self.driver.execute_script("mobile:selectPickerWheelValue", paramss)
            except  InvalidElementStateException:
                flag = 'False'
        if self.driver.find_element_by_name("Done"):
            self.driver.find_element_by_name("Done").click()
        return flag

    def choose_an_option_by_text_from_ios_dropdown(self, dropdown_options, testdata):
        flag = 'False'
        try:
            while True:
                if dropdown_options.get_attribute("value") == testdata:
                    flag = 'True'
                    break
                paramss = {'order': 'next', 'offset': 0.15, 'element': dropdown_options}
                self.driver.execute_script("mobile:selectPickerWheelValue", paramss)
        except InvalidElementStateException:
            flag = 'False'
        if self.driver.find_element_by_name("Done"):
            self.driver.find_element_by_name("Done").click()
        return flag

    # currently the below code is not used as the calling method did not need it
    # However this code maybe used in future, hence retaining the code/method
    # the RF method calling this method is "verify_number_of_options_in_list_locator"
    def get_number_of_options_in_ios_dropdown(self, dropdown_options):
        paramss = {'order': 'next', 'offset': 0.15, 'element': dropdown_options}
        count = 0
        for index_value in range(1000):
            try:
                self.driver.execute_script("mobile:selectPickerWheelValue", paramss)
            except  InvalidElementStateException:
                count = index_value
        if self.driver.find_element_by_name("Done"):
            self.driver.find_element_by_name("Done").click()
        return count

    def get_window_title(self, expected_title):
        flag = False
        index = 1
        try:
            for index in range(1, 20):
                time.sleep(1)
                window_handles = self.driver.window_handles
                for handle in window_handles:
                    self.driver.switch_to.window(handle)
                    title = self.driver.title
                    if title == expected_title:
                        flag = True
                        return flag
        except WebDriverException:
            flag = False
        return flag

    def get_json_file_from_gitHub(self, i18n_url):
        url = i18n_url
        resp = requests.get(url, auth=(self.username, self.password))
        data = json.loads(resp.text)
        return data

    def fetch_i18_files(self, clone_fe_repo_repeatedly, folderToSave, fe_repo, i18_locations, lang_selection, baseline):
        alldicts = []
        differencesContent = []
        item = ['Something went wrong...Nothing to compare']

        if lang_selection == 'Default':
            json_path = folderToSave + "/i18n_Default.json"
            baseline_path = baseline + "/baseline_i18n_Default.json"
            differences_file_path = folderToSave + "/i18n_Default_Differences.json"
        elif lang_selection == 'NonDefault' or lang_selection == 'Non_Default':
            json_path = folderToSave + "/i18n_NonDefault.json"
            baseline_path = baseline + "/baseline_i18n_NonDefault.json"
            differences_file_path = folderToSave + "/i18n_NonDefault_Differences.json"
        elif lang_selection == 'config':
            json_path = folderToSave + "/config.json"
            baseline_path = baseline + "/baseline_config.json"
            differences_file_path = folderToSave + "/config_Differences.json"

        # Identifying if baseline already exists or not
        if os.path.exists(baseline_path):
            baseline_path_already_exists = True
        else:
            baseline_path_already_exists = False

        # If clone_fe_repo is set to false and baseline file already exists, keys from the previous clone that is stored in i18n.json will be used
        if (clone_fe_repo_repeatedly == 'False') and (baseline_path_already_exists == True):
            with open(baseline_path, encoding='utf-8') as json_file:
                data = json.load(json_file)
                alldicts.append(data)

        # If clone_fe_repo is set to True and baseline file does not exists, then create a i18n file from fe_repo and generate a new baseline
        else:
            # If i18n keys needs to be fetched from fe_repo, then clone the fe_repo
            if (fe_repo != 'none') and ('home' not in fe_repo):
                # If fe_repo directory already exists from previous clone, then remove that directory for a fresh clone
                if os.path.exists(folderToSave):
                    shutil.rmtree(folderToSave)
                fe_repo_replace_username = fe_repo.replace("username", self.username)
                fe_repo_replace_password = fe_repo_replace_username.replace("password", self.password)
                Repo.clone_from(fe_repo_replace_password, folderToSave, multi_options=['--single-branch', '--depth=1'])

            # If i18n keys can be fetched from API, then create a new directory if already does not exists
            elif not os.path.exists(folderToSave):
                os.mkdir(folderToSave)

            json_path_already_exists = True

            # Writing keys to a file; in this case i18n.json
            with open(json_path, "w", encoding='utf-8') as outfile:
                for i18_location in i18_locations:
                    path_to_json = folderToSave + i18_location

                    # Raw "file" accessing directly from github using API request
                    if 'https' in i18_location:
                        # Fetch build timestamp from home page
                        if 'home' in fe_repo:
                            resp = requests.get(fe_repo)
                            html_resp = resp.text
                            html = BeautifulSoup(html_resp, 'html.parser')
                            node = html.find(property="og:image")
                            link = node.get("content")
                            build_timestamp = int(''.join(filter(str.isdigit, link)))
                            i18_location = i18_location.replace('%s', str(build_timestamp))
                            # The auth info in the below request was causing issue for PC-GT qa-a environment. Hence removed the auth
                            # resp = requests.get(i18_location, auth=(self.username, self.password))
                            resp = requests.get(i18_location)
                            data = json.loads(resp.text)
                        else:
                            resp = requests.get(i18_location, auth=(self.username, self.password))
                            data = json.loads(resp.text)
                        alldicts.append(data)

                    # After cloning FE repo from github, fethching all json files from a "folder" that is present locally
                    elif '.json' not in path_to_json:
                        for file_name in [file for file in os.listdir(path_to_json) if file.endswith('.json')]:
                            with open(path_to_json + file_name, encoding='utf-8') as json_file:
                                data = json.load(json_file)
                                alldicts.append(data)

                    # After cloning FE repo from github, fetching json "file" that is present locally
                    else:
                        with open(path_to_json, encoding='utf-8') as json_file:
                            data = json.load(json_file)
                            alldicts.append(data)
                json_object = json.dumps(alldicts, indent=4, ensure_ascii=False)
                outfile.write(json_object)

        # If i18n from fe_repo exists from previous clone or cloned from this run
        if os.path.exists(json_path):

            # If i18n file from fe_repo exists and baseline does not exists, then copy the i18n file from fe_repo and generate a new baseline
            if baseline_path_already_exists == False:
                shutil.copyfile(json_path, baseline_path)
                item = ['No Difference']

            # If i18n file from fe_repo exists and baseline already exists, then compare to identify differences between i18n file and baseline. i18n file could from previous clone or cloned from this run
            else:
                with open(baseline_path, encoding='utf-8') as orig_file, open(json_path,
                                                                              encoding='utf-8') as target_file:
                    diff = difflib.Differ()
                    item = diff.compare(target_file.readlines(), orig_file.readlines())
                    item = [line.replace('\'', '').replace('\n', '').replace('"', '').replace(',', '') for line in item
                            if line.startswith(("- ", "+ "))]

            # Storing the differences in a seperate file
            with open(differences_file_path, "w", encoding='utf-8') as differences:
                differencesContent.append(item)
                json_object = json.dumps(differencesContent, sort_keys=True, indent=4, ensure_ascii=False)
                differences.write(json_object)

        # else if i18n from fe_repo does not exists and clone_fe_repo is set to False and baseline already exists, then existing baseline will be used for identifying the elements and no new i18n file will be cloned from fe_repo

        return alldicts, item

    def compare_json_and_write_differences_in_file(self, baseline_path, current_path):
        with open(baseline_path, encoding='utf-8') as orig_file, open(current_path,
                                                                      encoding='utf-8') as target_file:
            diff = difflib.Differ()
            item = diff.compare(target_file.readlines(), orig_file.readlines())
            item = [line.replace('\'', '').replace('\n', '').replace('"', '').replace(',', '') for line in item
                    if line.startswith(("- ", "+ "))]

            differencesContent = []
            differences_file_path = baseline_path + "diff_"
            with open(differences_file_path, "w", encoding='utf-8') as differences:
                differencesContent.append(item)
                json_object = json.dumps(differencesContent, sort_keys=True, indent=4, ensure_ascii=False)
                differences.write(json_object)

        return item

    def write_json_to_file(self, file_path, json_dict):
        with open(file_path, "w", encoding='utf-8') as outfile:
            json_object = json.dumps(json_dict, indent=4, ensure_ascii=False)
            outfile.write(json_object)


    def decode_email_header(self, emailHeader):
        decoded_email_header = make_header(decode_header(emailHeader))
        return str(decoded_email_header)

    def get_test_id_mappings(self, responseJson):
        test_id_mappings = {}
        tests = responseJson['data']
        for test in tests:
            id = test['id']
            name = test['attributes']['name']
            test_id_mappings[name] = id
        return test_id_mappings

    def capture_screenshot(self, source):
        allure.attach.file(source, name="screenshot", attachment_type=allure.attachment_type.JPG)

    def get_latest_build(self, project_id, environment):
        print("Started")
        print(listdir())
        for fileName in listdir():
            if fileName.endswith('.apk') or fileName.endswith('.ipa'):
                os.remove(fileName)
        username = "abhalla@tillster.com"
        password = "cc342507b8ffbd55fc4ebd0ff73da4c91a1933e4"
        base_url = "https://api.testfairy.com/api/1/projects/"
        get_project_builds_url = base_url + str(project_id) + "/builds"
        response = requests.get(get_project_builds_url, auth=HTTPBasicAuth(username, password))
        print(response.status_code)
        response_json = response.content
        response_object = json.loads(response_json)
        # print(response_object)
        builds = response_object['builds']
        # print(builds)
        build_id = "not sure"
        download_url = "empty"
        print(build_id)
        print(download_url)
        for build in builds:
            env = build['appVersion']
            environment = environment.replace("_", "-")
            if environment in env:
                build_id = build["id"]
                download_url = build["appUrl"]
                break
        print(build_id)
        print(download_url)
        file_name = "python." + download_url[-3:]
        # file download
        download_file_response = requests.get(download_url, stream=True, auth=HTTPBasicAuth(username, password))
        with open(file_name, "wb") as downloaded_file:
            for chunk in download_file_response.iter_content(chunk_size=1024):

                # writing one chunk at a time to pdf file
                if chunk:
                    downloaded_file.write(chunk)

        print("Upload Started")
        browserstack_upload_url = "https://api-cloud.browserstack.com/app-automate/upload"
        file_to_upload = {'file': open(file_name, 'rb')}
        upload_response = requests.post(browserstack_upload_url,
                                        auth=HTTPBasicAuth("ankurbhalla2", "o96zXU5P5nj3qjxnz3xq"),
                                        files=file_to_upload)
        print(upload_response.status_code)
        upload_response_json = upload_response.content
        print(upload_response_json)
        upload_response_object = json.loads(upload_response_json)
        print(upload_response_object)
        app_url = upload_response_object["app_url"]
        print(app_url)
        return app_url

    def attach_screenshot_in_cs(self, url, request_headers, screenshot_file):
        with open(screenshot_file, 'rb') as filedata:
            r = requests.post(url, headers=request_headers, files={'file': filedata})
        return r, r.content

    def get_input_field_value(self, xpath_locator):
        try:
            xpath_locator = xpath_locator.replace("'", "\\'")
            script = f"return document.evaluate('{xpath_locator}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.value;"
            attribute_value = self.driver.execute_script(script)
            print(attribute_value)
            return attribute_value

        except Exception as e:
            print(f"Error: {e}")
            return None

    def swipe_down(self):
        initial_page_source = self.driver.page_source
        status = ""
        size = self.driver.get_window_size()
        start_x = size['width'] // 2
        start_y = size['height'] * 0.8
        end_x = size['width'] // 2
        end_y = size['height'] * 0.1

        self.driver.swipe(start_x, start_y, end_x, end_y, duration=500)

        current_page_source = self.driver.page_source
        if initial_page_source != current_page_source:
            print("Content changed, continue swiping")
        else:
            print("Content unchanged, exit for loop")
            status = "EOP"
           
        return status

    def push_file_onto_device(self, upload_path, source):
        platform_name = self.driver.capabilities['platformName']
        print(platform_name)
        if platform_name == 'Android':
            self.driver.push_file(upload_path, source_path=r'' + source)
        else:
            self.driver.push_file('@' + upload_path, source_path=r'' + source)

    def send_app_to_background(self):
        self.driver.execute_script('mobile: backgroundApp')

    def open_deeplink(self, deeplink_url, package):
        if 'ios' in self.driver.desired_capabilities['platformName'].lower():
            self.driver.execute_script('mobile:deepLink', {'url': f'{deeplink_url}', 'bundleId': f'{package}'})
        else:
            self.driver.execute_script('mobile:deepLink', {'url': f'{deeplink_url}', 'package': f'{package}'})

    def crop_image(self, image_path, left, upper, right, lower):
        image = Image.open(image_path)
        crop_area = (left, upper, right, lower)
        cropped_image = image.crop(crop_area)
        cropped_image.save(image_path)

    def run_cypress_tests(self, spec_file, test_name):
        print("INSIDE THE CUSTOM METHOD")
        print(spec_file)
        os.chdir("D:/Tillster/FE_Code_Cypress/fe-core/apps/cypress")
        # result_temp = subprocess.run(['cd', 'D:\Tillster\FE_Code_Cypress\fe-core\apps\cypress'], capture_output=True, text=True, shell=True)
        # print("THIS IS THE OUTPUT 1: " + result_temp.stdout)
        result_temp_2 = subprocess.run(['cd'], capture_output=True,
                                     text=True, shell=True)
        print("THIS IS THE OUTPUT 2: " + result_temp_2.stdout)

        # command = "echo 1234321 & cd D:\Tillster\FE_Code_Cypress\fe-core\apps\cypress & cd"
        # result_temp_3 = subprocess.run(command, capture_output=True, text=True, shell=True)
        # print("THIS IS THE OUTPUT 3: " + result_temp_3.stdout)
        # try:
        #     result = subprocess.run(['npx', 'cypress', 'run', '--spec', spec_file], capture_output=True, text=True, shell=True)
        # except subprocess.CalledProcessError as cmderr:
        #     print(cmderr.output)

        test_case_name="PORUSVerifyGuestusercanplacePickupOrderwithonlinepaymentProd"
        result = subprocess.run("npx cypress run --env configFile=dev,brandId=bk-co,grep=" + test_case_name + " --spec " + spec_file, capture_output=True, text=True,
                                shell=True, encoding="utf8")

        # cypress_command = "npx cypress run --env configFile=dev,brandId=bk-co,grep='PORUS - Verify Guest user can place Pickup Order with online payment - Prod' --spec " + spec_file
        # result = subprocess.run(cypress_command, capture_output=True, text=True,
        #                         shell=True)
        print("AFTER THE EXECUTION OF COMMAND")
        print(result)
        if result.returncode != 0:
            raise Exception(f"Cypress tests failed: {result}")
        print(result.stderr)

    def decode_url_encoded_value(self, encoded_value):
        # new_value = unquote(encoded_value)
        # print(new_value)
        return unquote(encoded_value)


    def find_resource_files(self, root_folder):
        resources = []
        for dirpath, _, filenames in os.walk(root_folder):
            for f in filenames:
                if f.endswith('.robot'):
                    # Use forward slashes for Robot Framework compatibility
                    resources.append(os.path.relpath(os.path.join(dirpath, f), root_folder).replace(os.sep, '/'))
        return resources

    #def write_central_resource(self, resource_paths, output_file, highlevel_methods_path, common_resource_paths):
    def write_central_resource(self, resource_paths, output_file, shared_repo_path):
        with open(output_file, 'w') as f:
            f.write("*** Settings ***\n")
            for path in resource_paths:
                #f.write(f"Resource    ../../resources${{/}}modules${{/}}{highlevel_methods_path}${{/}}{path}\n")
                f.write(f"Resource    ..${{/}}{shared_repo_path}${{/}}{path}\n")

            # for common_path in common_resource_paths:
            #     #f.write(f"Resource    ../../resources${{/}}modules${{/}}shared_modules${{/}}common_code${{/}}{common_path}\n")
            #     f.write( f"Resource    ..${{/}}common_code${{/}}{common_path}\n")

    def parse_price(self, price_text, locale_code="en_US"):
        if not price_text or price_text.strip() == "":
            return 0.0
        # Convert a price string based on the specified locale into a float.
        try:
            return float(parse_decimal(price_text, locale=locale_code))
        except Exception as e:
            raise ValueError(f"Could not parse price '{price_text}' with locale '{locale_code}': {e}")

    STRFTIME_TO_BABEL_MAP = {
        '%A': 'EEEE',
        '%a': 'EEE',
        '%B': 'MMMM',
        '%b': 'MMM',
        '%Y': 'yyyy',
        '%y': 'yy',
        '%m': 'MM',
        '%d': 'dd',
        '%e': 'd',
        '%H': 'HH',
        '%I': 'hh',
        '%l': 'h',
        '%M': 'mm',
        '%S': 'ss',
        '%p': 'a',
    }
    # This will handle any locale-specific literal overrides (e.g. forcing English AM/PM for fr_CA)
    LITERAL_OVERRIDES = {
        ('fr_CA', '%p'): lambda datetime_object: datetime_object.strftime('%p'),  # BP-CA site shows English AM/PM
    }

    # Converts a format string (e.g. '%Y,%m %d') into an equivalent Babel pattern (e.g. 'yyyy-MM-dd')
    def convert_strftime_to_babel_format(self, strftime_format, date_object, locale=None):
        directives = sorted(set(self.STRFTIME_TO_BABEL_MAP) | {'%p'}, key=len, reverse=True)
        directive_re = re.compile('|'.join(re.escape(d) for d in directives))
        result = []
        current_position = 0
        literal_buffer = ''
        # Escape and append buffered literal text, then reset the buffer.
        def flush():
            nonlocal literal_buffer
            if literal_buffer:
                result.append(f"'{literal_buffer.replace(chr(39), chr(39) * 2)}'")
                literal_buffer = ''
        # Check every strftime directive found in the format string in the order they appear.
        for match in directive_re.finditer(strftime_format):
            literal_buffer += strftime_format[current_position:match.start()]
            directive = match.group()
            override_key = (locale, directive)
            override = self.LITERAL_OVERRIDES.get((locale, directive))
            if override:
                print(f"Override FOUND for {override_key}")
                override_value = override(date_object)
                print(f"Override RESULT for {directive}: '{override_value}'")
                literal_buffer += override(date_object)
            else:
                flush()
                result.append(self.STRFTIME_TO_BABEL_MAP[directive])
            current_position = match.end()
        # Append any trailing literal text left over after the last matched directive.
        literal_buffer += strftime_format[current_position:]
        flush()
        babel_format = ''.join(result)
        print(f"Converted '{strftime_format}' -> babel pattern '{babel_format}'")
        return babel_format

    # Parse a human-readable locale-formatted date/time string into a Python datetime object.
    def parse_localized_datetime(self, text, locale):
        print("Entered into parse_localized_datetime")
        print("Original localized text: ", text)
        dateparser_locale = locale.replace('_', '-')
        date_object = dateparser.parse(text, locales=[dateparser_locale])
        print("Parsed date object: ", date_object)
        if date_object is None:
            raise ValueError(f"Could not parse '{text}' for locale '{locale}'")
        return date_object

    # Formats a datetime object back into a localized string.
    def format_datetime_for_locale(self, date_object, expected_format, locale):
        print("Entered into format_datetime_for_locale")
        babel_pattern = self.convert_strftime_to_babel_format(expected_format, date_object, locale)
        formatted_value = format_datetime(date_object, format=babel_pattern, locale=locale)
        print("Formatted value is: ", formatted_value)
        return formatted_value