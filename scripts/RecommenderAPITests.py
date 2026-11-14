import sys
import time

import requests
import json
from datetime import datetime
from zoneinfo import ZoneInfo
import calendar
import pygsheets


class RecommenderAPITests:

    def get_data_for_recommender_api_tests(self, sheet_name):

        # CS API Token valid till 23-May-2025
        # cs_api_headers = {
        #     'access-token': 'SjMcwpOOsTaFugDDYargjA',
        #     'client': 'moVRfZOiY6GGbmMKtnkDJA',
        #     'uid': 'srajendran@tillster.com',
        #     'Accept': 'application/vnd.api+json; version=1'
        # }

        # cs_ui_headers = {
        #     'x-csrf-token': 'YST1MpZm2ZMSUb5L4pA842K9AnEF5oeLwsWBUBCHOxN077lOcRML89vyWsB0DXTIfk0KRr7s/BGNAN9WpN66gw==',
        #     'Accept-Encoding': 'gzip, deflate, br',
        #     'Accept': '*/*',
        #     'Cookie': '_ga=GA1.1.790119628.1742277948; hui=eyJfcmFpbHMiOnsibWVzc2FnZSI6Iklqa3lOakExSWc9PSIsImV4cCI6bnVsbCwicHVyIjoiY29va2llLmh1aSJ9fQ%3D%3D--bfd1ebe7d06b4d1cc79d79a0627f262fddef1aaa; user_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6Ik9USTJNRFU9IiwiZXhwIjpudWxsLCJwdXIiOiJjb29raWUudXNlcl9pZCJ9fQ%3D%3D--10bc16562430def1337c002ea2f1f2ef60be559d; _ga_E1081Q014T=GS1.1.1742277970.1.1.1742278467.0.0.0; _ga_Q17C4B81S5=GS1.1.1742277948.1.1.1742280743.0.0.0; _app_session=e9BJhG6%2BxcP9048QKoc1oPVwM0n4fJZLd3qoLhGlbqRrpoiSC1Lz4EdbxfAnxxTk3s0u8MpguMSLIS8xtfmYO5Rc8WqIyfN7RahSdxzXJQsk8gCjOhQiUnNrOIrf2%2F8HiE5gFSeiXmqY%2FYPut8KiWhgA9O1%2BXq55ok3716iguv9wxuNii1M5UQqeCoMo79qCxYgR%2BD%2BTwkXXIxq6o3ukRlJWCTInm3Ws6zsa5jX4JQw6YA2iYzyWy5nyN9hkjzGLX9BLLQwUvf3MyHbuUuhXLMno02RV9g%2FUHJl1nyRWhYhZCuRObobEfrVGgzH07ht4xe2kh32UvvoOdhGho9tCraii6CeAH0yZEAXEBqltP5a5rAaRnxb0nKDrC%2FIk%2FYV7pl8QDb6vo5qGudjn--Cs%2BoXqZDt0vSm8QP--jICocn%2F2YJbdDMZdBlugxQ%3D%3D'
        #
        # }

        #   Open google spreadsheet
        # config_path = "../recommender-v3-00f47d44f92c.json"
        config_path = "recommender-v3-00f47d44f92c.json"
        gc = pygsheets.authorize(service_file=config_path)
        sh = gc.open('Recommender V3')
        print("the sheet name is : " + sheet_name)
        wks = sh.worksheet_by_title(sheet_name)

        # read and print column names
        data = wks.get_all_records()
        # print(data)
        # print("\n\n\n")
        # for row in data:
        #     print(row)

        # Get all rows but only columns A to C
        # data1 = wks.get_values(
        #     start='A2',  # Start from first cell
        #     end='C',  # End at column C (auto-detect last row)
        #     returnas='matrix',
        #     include_tailing_empty=False
        # )
        # print("\n\n\n")
        # for row in data1:
        #     print(row)

        # Filter by column names
        # desired_cols = ['col1', 'col2', 'col3']
        # filtered_records = [{k: v for k, v in row.items() if k in desired_cols} for row in data]
        # print("\n\n\n Filtered Rows")
        # print(filtered_records)

        # Get current timestamp for header
        timestamp_header = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(timestamp_header)

        # Insert a new column at the end
        wks.add_cols(1)  # Adds 1 column at the end

        # Set the header as the timestamp
        new_col_index = wks.cols  # After adding, this is the new column index
        wks.update_value((1, new_col_index), timestamp_header)

        # Add column for Failure Reason
        wks.add_cols(1)  # Adds 1 column at the end
        wks.update_value((1, new_col_index + 1), "Failure Reason")

        # Add column for Final Status
        wks.add_cols(1)  # Adds 1 column at the end
        wks.update_value((1, new_col_index + 2), "Status")

        # Keep only first N columns
        data_matrix = [list(row.values()) for row in data]
        n = 23
        filtered_data = [row[:n] for row in data_matrix]
        print("\n\n\n Filtered based on number of columns to keep")
        print(filtered_data)
        for row in filtered_data:
            print("this is row : ")
            print(row)
        return filtered_data, new_col_index

    def update_recommender_api_tests_results(self, sheet_name, col_index, row_number, value, make_bold=False):
        #   Open google spreadsheet
        # config_path = "../recommender-v3-00f47d44f92c.json"
        config_path = "recommender-v3-00f47d44f92c.json"
        gc = pygsheets.authorize(service_file=config_path)
        sh = gc.open('Recommender V3')
        print("the sheet name is : " + sheet_name)
        wks = sh.worksheet_by_title(sheet_name)

        # Get number of rows with data
        #num_rows = len(wks.get_all_values(include_tailing_empty=False))

        timestamp_header = "empty"
        if (value == 'timestamp'):
            # Get current timestamp for header
            timestamp_header = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            wks.update_value((row_number, col_index), timestamp_header)
        else:
            wks.update_value((row_number, col_index), value)

        if (make_bold == True):
            cell = wks.cell((int(row_number), int(col_index)))
            cell.set_text_format('bold', True)

    def get_data_for_recommender_ui_tests(self, sheet_name, day_parts, time_zone):

        config_path = "recommender-v3-00f47d44f92c.json"
        gc = pygsheets.authorize(service_file=config_path)
        sh = gc.open('Recommender V3')
        print("the sheet name is : " + sheet_name)
        wks = sh.worksheet_by_title(sheet_name)

        data = wks.get_all_records()

        # Get current timestamp for header
        # time_zone = 'America / Los_Angeles'
        timestamp_header = datetime.now(ZoneInfo(time_zone)).strftime('%Y-%m-%d %H:%M:%S')
        print(timestamp_header)

        # getting details from timestamp
        dt = datetime.strptime(timestamp_header, '%Y-%m-%d %H:%M:%S')
        minutes = dt.minute
        # hour = dt.hour
        # day_of_the_week_int = dt.weekday()

        # if the minutes are more that 55 then sleep for 5 mins
        if minutes > 55:
            time.sleep(300)
            timestamp_header = datetime.now(ZoneInfo(time_zone)).strftime('%Y-%m-%d %H:%M:%S')

        # getting details from timestamp
        dt = datetime.strptime(timestamp_header, '%Y-%m-%d %H:%M:%S')
        minutes = dt.minute
        hour = dt.hour
        day_name = calendar.day_name[dt.weekday()]


        # Insert a new column at the end
        wks.add_cols(1)  # Adds 1 column at the end

        # Set the header as the timestamp
        new_col_index = wks.cols  # After adding, this is the new column index
        wks.update_value((1, new_col_index), timestamp_header)

        # Add column for Failure Reason
        wks.add_cols(1)  # Adds 1 column at the end
        wks.update_value((1, new_col_index + 1), "Failure Reason")

        # Keep only first N columns
        data_matrix = [list(row.values()) for row in data]
        n = 12
        filtered_data = [row[:n] for row in data_matrix]
        print("\n\n\n Filtered based on number of columns to keep")
        print(filtered_data)
        for row in filtered_data:
            print("this is row : ")
            print(row)

        day_part = day_parts.get(hour);
        return filtered_data, new_col_index, day_name, day_part, hour, minutes

    def get_data_for_recommender_ui_tests_2(self, sheet_name, time_zone):
        config_path = "recommender-v3-00f47d44f92c.json"
        gc = pygsheets.authorize(service_file=config_path)
        sh = gc.open('Recommender V3')
        sheet_name_skumap = sheet_name + "_skumap"
        sheet_name_testdata = sheet_name + "_ui_2"
        wks1 = sh.worksheet_by_title(sheet_name_testdata)

        data1 = wks1.get_all_records()

        # Get current timestamp for header
        timestamp_header = datetime.now(ZoneInfo(time_zone)).strftime('%Y-%m-%d %H:%M:%S')

        # Insert a new column at the end
        wks1.add_cols(1)  # Adds 1 column at the end

        # Insert a column at position 3
        wks1.insert_cols(2, 1)

        # Set the header as the timestamp
        # Below 2 lines are not required now as we are updating at position 3
        # Uncommented the below line as this value was being returned. Will handle in keywords first and then remove it
        new_col_index = wks1.cols  # After adding, this is the new column index
        # wks1.update_value((1, new_col_index), timestamp_header)

        # Set the header at position 3 as the timestamp
        wks1.update_value((1, 3), timestamp_header)

        # Add column for Failure Reason
        wks1.add_cols(1)  # Adds 1 column at the end
        wks1.insert_cols(3, 1)  # Inserts the column at position 4
        wks1.update_value((1, 4), "Failure Reason")

        # Keep only first N columns
        # check if this data is still needed as the approach is changed
        data_matrix1 = [list(row.values()) for row in data1]
        n = 2
        filtered_data1 = [row[:n] for row in data_matrix1]
        print("\n\n\n Filtered based on number of columns to keep")
        print(filtered_data1)
        for row in filtered_data1:
            print("this is row : ")
            print(row)

        # GET SKUMAP
        wks2 = sh.worksheet_by_title(sheet_name_skumap)

        data2 = wks2.get_all_records()
        data_matrix2 = [list(row.values()) for row in data2]
        n = 2
        filtered_data2 = [row[:n] for row in data_matrix2]

        return filtered_data1, filtered_data2, new_col_index

    def get_datetime_for_recommender_api(self, time_zone):
        #timestamp = datetime.now(ZoneInfo(time_zone)).strftime('%Y-%m-%d %H:%M:%S')
        #timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        # morning time
        #modified_dt = datetime.now().replace(hour=8, minute=0, second=0, microsecond=0)
        #afternoon time
        modified_dt = datetime.now().replace(hour=12, minute=0, second=0, microsecond=0)
        timestamp = modified_dt.strftime('%Y-%m-%d %H:%M:%S')
        return timestamp

    def get_data_from_recommender_api(self):
        sample_json_path = "recommender/sample.json"
        with open(sample_json_path, 'r') as json_file:
            json_string = json_file.read()




# if __name__ == '__main__':
#     recommender_api_tests = RecommenderAPITests()
#     recommender_api_tests.update_recommender_api_tests_results("bk-de-qa", 44, 2, "timestamp", True)
#    fetch_and_update_test_results("","web_prod","1041674")
