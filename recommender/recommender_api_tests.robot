*** Settings ***
Documentation

Library    	    ${EXECDIR}${/}scripts${/}RecommenderAPITests.py
Library         Collections
Library         String
Library         OperatingSystem
Library         JSONLibrary
Library         RequestsLibrary

*** Variables ***
${sheet_name} =


*** Test Cases ***

Execute Test Cases (uid:9f7dbd2c034c4a6ebb54670752c6cc91)
    ${complete_data} =         get_data_for_recommender_api_tests        ${sheet_name}
    #Log        ${complete_data}
    ${api_data} =         Set Variable        ${complete_data}[0]
    ${column_index} =         Set Variable        ${complete_data}[1]
    ${row_counter} =          Set Variable        ${1}
    ${failed_test_count} =         Set Variable    ${0}
    ${passed_test_count} =         Set Variable    ${0}
    FOR     ${row}    IN     @{api_data}
        ${row_counter} =         Set Variable        ${row_counter + 1}
        Log            ${row_counter}
        Log     ${row}
        ${type string}=    Evaluate     type($row)
        Log      ${type string}
        # Append To List        ${row}        True

        # getting the json string
        ${sample_json_file_path} =         Set Variable         ${EXECDIR}${/}recommender${/}sample.json
        ${sample_json_string} =        Get File            ${sample_json_file_path}

        # getting selected items from the api test data
        ${selected_item_in_api_data} =         Set Variable         ${row}[8]
        Log            ${selected_item_in_api_data}
        ${selected_item_in_api_data} =         Replace String        ${selected_item_in_api_data}        '        "
        Log            ${selected_item_in_api_data}
        
        # adding the selected item in the json string
        Log         ${sample_json_string}
        ${sample_json_string} =         Replace String        ${sample_json_string}        "selected_items_in_test_data"        ${selected_item_in_api_data}
        Log         ${sample_json_string}

        # getting order time from the api test data
        ${order_time_in_api_data} =         Set Variable         ${row}[5]

        # adding the order time in the json string
        ${sample_json_string} =         Replace String        ${sample_json_string}        order_time        ${order_time_in_api_data}
        Log         ${sample_json_string}

        # getting store id from api test data variable_store_id
        ${store_id_in_api_data} =         Set Variable         ${row}[6]

        # adding the store id in the json string
        ${sample_json_string} =         Replace String        ${sample_json_string}        variable_store_id        ${store_id_in_api_data}
        Log         ${sample_json_string}

        # getting context from api test data variable_context
        ${context_in_api_data} =         Set Variable         ${row}[1]

        # adding the context in the json string
        ${sample_json_string} =         Replace String        ${sample_json_string}        variable_context        ${context_in_api_data}
        Log         ${sample_json_string}


        # get url from the api test data
        ${url_in_api_data} =         Set Variable         ${row}[12]

        # get request headers from the api test data
        ${request_headers_in_api_data} =         Set Variable         ${row}[13]
        ${request_headers_in_api_data} =         Replace String        ${request_headers_in_api_data}        '        "
        ${request_headers_dict}=        Convert String to JSON          ${request_headers_in_api_data}

        # get query params from the api test data
        ${query_params_in_api_data} =         Set Variable         ${row}[14]
        ${query_params_in_api_data} =         Replace String        ${query_params_in_api_data}        '        "
        ${query_params_dict}=        Convert String to JSON          ${query_params_in_api_data}

        # get response code from api test data
        ${response_code_in_api_data} =         Set Variable        ${row}[16]


        # creating the request
        # ${header}=      Create Dictionary       tenant=${tenant}             Content-Type=application/json        env=${environment}
        ${json_payload_for_request}=        Convert String to JSON          ${sample_json_string}
        ${response} =        Wait Until Keyword Succeeds     20 sec      1 sec       POST         ${url_in_api_data}/             json=${json_payload_for_request}       headers=${request_headers_dict}        params=${query_params_dict}
        Log         ${response.status_code}
        
        # get validation response data
        ${response_in_api_data} =         Set Variable         ${row}[20]
        ${type string} =    Evaluate     type($response_in_api_data)
        Log        ${type string}
        Log         ${response_in_api_data}
        ${response_in_api_data} =          Replace String        ${response_in_api_data}        [        ${EMPTY}
        ${response_in_api_data} =          Replace String        ${response_in_api_data}        ]        ${EMPTY}
        ${response_in_api_data} =          Replace String        ${response_in_api_data}        '        ${EMPTY}
        ${response_in_api_data} =          Replace String        ${response_in_api_data}        ${SPACE}        ${EMPTY}
        ${response_in_api_data} =            Split String        ${response_in_api_data}        ,
        ${type string} =    Evaluate     type($response_in_api_data)
        Log        ${type string}
        Log         ${response_in_api_data}

        #update_recommender_api_tests_results        ${sheet_name}        ${column_index}        ${row_counter}        ${response.status_code}
        
        ${response_code_status} =  Run Keyword And Return Status        Should Be Equal As Numbers        ${response_code_in_api_data}      ${response.status_code}
        IF      not ${response_code_status}
            ${failure_reason} =         Set Variable        The response code received by the API request is not as expected. Expected response code: ${response_code_in_api_data}, Actual response code: ${response.status_code}
            update_recommender_api_tests_results        ${sheet_name}        ${column_index}        ${row_counter}        FAIL
            update_recommender_api_tests_results        ${sheet_name}        ${column_index+1}        ${row_counter}        ${failure_reason}
            ${failed_test_count} =        Evaluate    ${failed_test_count} + 1
        END
        
        IF        ${response_code_status}
            ${response_skus} =         Set Variable            ${response.json()}[data]
            ${type string} =    Evaluate     type($response_skus)
            Log        ${type string}
            Log        ${response_skus}
            ${response_data_comparison_status} =  Run Keyword And Return Status        Lists Should Be Equal        ${response_skus}        ${response_in_api_data}
            IF        not ${response_data_comparison_status}
                ${failure_reason} =         Set Variable        The actual response does not match expected response. Actual Response: ${response_skus}, Expected response: ${response_in_api_data}
                update_recommender_api_tests_results        ${sheet_name}        ${column_index}        ${row_counter}        FAIL
                update_recommender_api_tests_results        ${sheet_name}        ${column_index+1}        ${row_counter}        ${failure_reason}
                ${failed_test_count} =        Evaluate    ${failed_test_count} + 1
            ELSE
                update_recommender_api_tests_results        ${sheet_name}        ${column_index}        ${row_counter}        PASS
                ${passed_test_count} =        Evaluate    ${passed_test_count} + 1
            END
        END
        
#        IF         ${row_counter} == 10
#            Exit For Loop
#        END

        #${recorded_har_file_json}=        Convert String to JSON          ${recorded_har_file}
    END

    update_recommender_api_tests_results        ${sheet_name}        ${column_index+2}        2        timestamp        True
    update_recommender_api_tests_results        ${sheet_name}        ${column_index+2}        3        Passed=${passed_test_count}        True
    update_recommender_api_tests_results        ${sheet_name}        ${column_index+2}        4        Failed=${failed_test_count}        True
    
