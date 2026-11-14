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


*** Keywords ***

get_recommender_ui_test_data_1
    [Arguments]	    ${test_name}=        ${day_parts}=DAY_PARTS        ${time_zone}=TIME_ZONE
    ${day_parts}      get argument actual value     ${day_parts}
    ${time_zone}      get argument actual value     ${time_zone}
    Log         ${day_parts}
    ${type string}=    Evaluate     type($day_parts)
    Log      ${type string}
    #${day_parts}    Evaluate    json.loads('''${day_parts}''')    modules=json
    #${type string}=    Evaluate     type($day_parts)
    #Log      ${type string}

    Log         ${tenant}
    Log         ${environment}
    ${sheet_name} =         Set Variable        ${tenant}_${environment}_ui
    ${complete_data} =     get_data_for_recommender_ui_tests        ${sheet_name}        ${day_parts}        ${time_zone}
    ${test_data} =         Set Variable        ${complete_data}[0]
    ${column_index} =         Set Variable        ${complete_data}[1]
    ${day_of_the_week} =         Set Variable        ${complete_data}[2]
    ${day_part} =         Set Variable        ${complete_data}[3]
    ${hour} =         Set Variable        ${complete_data}[4]
    ${minutes} =         Set Variable        ${complete_data}[5]

    # ${test_data_1} =     Set Test Variable        ${test_data}
    Set Test Variable            ${test_data_1}        ${test_data}
    Set Test Variable            ${day_part_1}        ${day_part}
    Set Test Variable            ${day_of_the_week_1}        ${day_of_the_week}
    Set Test Variable            ${column_index_1}        ${column_index}
    
    ${row_counter} =          Set Variable        ${1}

    FOR     ${row}    IN     @{test_data}
        ${row_counter} =         Set Variable        ${row_counter + 1}
        Log        ${row}[0]
        Log        ${test_name}
        IF        "${row}[0]"=="${test_name}" and "${row}[3]"=="${day_part}" and "${row}[2]"=="${day_of_the_week}"
            Log        ${row}
            ${context} =         Set Variable        ${row}[1]
            ${first_recommendations} =         Set Variable        ${context}_first_recommendations
            ${selected_recommended_item} =         Set Variable        ${context}_selected_recommended_item
            ${second_recommendations} =         Set Variable        ${context}_second_recommendations
            ${test_row_number} =             Set Variable        ${context}_test_row_number
            ${failure_messages} =             Set Variable        ${context}_failure_messages
            Set Test Variable        ${${first_recommendations}}        ${row}[8]
            Set Test Variable        ${${selected_recommended_item}}        ${row}[9]
            Set Test Variable        ${${second_recommendations}}        ${row}[10]
            Set Test Variable        ${${test_row_number}}        ${row_counter}
            Set Test Variable        @{${failure_messages}}        Failure Messages:

        END
    END

    # Set Test Variable    @{failure_messages}    Create List

    Log         ${context}
    Log         ${first_recommendations}
    Log         ${cart_first_recommendations}
    Log         ${crosssell_first_recommendations}
    Log         ${cart_selected_recommended_item}
    Log         ${crosssell_selected_recommended_item}
    Log         ${cart_second_recommendations}
    Log         ${crosssell_second_recommendations}
    Log         ${cart_test_row_number}
    Log         ${crosssell_test_row_number}

    # invalid_key


get_recommender_ui_test_data
    [Arguments]        ${test_name}=        ${time_zone}=TIME_ZONE
    ${sheet_name} =         Set Variable        ${tenant}_${environment}
    ${time_zone}      get argument actual value     ${time_zone}
    ${complete_data} =     get_data_for_recommender_ui_tests_2        ${sheet_name}        ${time_zone}
    ${skumap} =         Set Variable        ${complete_data}[1]
    ${test_cases_data} =         Set Variable        ${complete_data}[0]
    Log        ${test_cases_data}
    ${column_index} =         Set Variable        ${complete_data}[2]

    ${row_counter} =          Set Variable        ${1}
    FOR     ${row}    IN     @{test_cases_data}
        ${row_counter} =         Set Variable        ${row_counter + 1}
        IF        "${row}[0]"=="${test_name}"
            Log        ${row}
            ${context} =         Set Variable        ${row}[1]
            ${test_row_number} =             Set Variable        ${context}_test_row_number
            ${failure_messages} =             Set Variable        ${context}_failure_messages
            Set Test Variable        ${${test_row_number}}        ${row_counter}
            Set Test Variable        @{${failure_messages}}        Failure/Info Messages:
        END
    END

    Set Test Variable            ${skumap_data}        ${skumap}
    Set Test Variable            ${test_cases_sheet_data}        ${test_cases_data}
    Set Test Variable            ${column_index_test_data_sheet}        ${column_index}
    Set Test Variable            ${items_in_cart}        ${EMPTY}


verify_recommended_items_displayed_1
    [Arguments]	    ${locator}=        ${recommendations}=        ${recommendations_type}=        ${failure_messages_variable}=
    ${locator}      get argument actual value     ${locator}
    ${recommendations}      get argument actual value     ${recommendations}
    wait_for_element_state        ${locator}        visible
    ${recommended_items_elements} =     Get Elements        ${locator}
    @{item_names_list} =    Create List
    FOR     ${recommended_items_element}    IN     @{recommended_items_elements}
        #${item_name} =     Get Text        ${recommended_items_element}
        #${item_name} =     Get Property        ${recommended_items_element}        textContent
        #${item_name} =     Evaluate JavaScript    ${recommended_items_element}    (element) => element.innerText
        #${item_name} =     Get Attribute        ${recommended_items_element}        aria-label        ==        ${None}
        #IF    "${item_name}" == "None"
        #    ${item_name} =     Get Text        ${recommended_items_element}
        #END
        ${attribute_existence_status} =         Run Keyword And Return Status        Get Attribute Names        ${recommended_items_element}        contains         aria-label
        IF        ${attribute_existence_status}
            #${item_name} =     Get Text        ${recommended_items_element}
            ${item_name} =     Get Attribute        ${recommended_items_element}        aria-label
        ELSE
            ${item_name} =     Get Text        ${recommended_items_element}
        END
        Should Not Contain        ${item_name}        ...
        Append To List        ${item_names_list}        ${item_name}
    END
    Log        ${item_names_list}
    ${recommendations} =         Replace String            ${recommendations}        ['        ${EMPTY}
    ${recommendations} =         Replace String            ${recommendations}        ']        ${EMPTY}
    ${recommendations} =         Replace String            ${recommendations}        ${SPACE}'         ${EMPTY}
    ${recommendations} =         Replace String            ${recommendations}        '         ${EMPTY}
    ${recommendations_list} =            Split String        ${recommendations}        ,
    ${comparison_status} =         Run Keyword And Return Status        Lists Should Be Equal        ${recommendations_list}        ${item_names_list}
    IF      not ${comparison_status}
        ${failure_message} =         Set Variable        ${recommendations_type} do not match the expected recommendations. Actual recommendations displayed = ${item_names_list}, Expected recommendations = ${recommendations_list}
        Log         ${failure_message}
        # Append To List        ${failure_messages}        ${failure_message}
        Append To List        ${${failure_messages_variable}}        ${failure_message}
    END

verify_recommended_items_displayed
    [Arguments]	    ${locator}=        ${added_item}=        ${recommendations_type}=        ${failure_messages_variable}=
    ${locator}      get argument actual value     ${locator}
    ${added_item}      get argument actual value     ${added_item}
    
    ${is_item_added} =         Run Keyword And Return Status        Should Be Equal        ${added_item}        None
    
    IF        not ${is_item_added}
        ${id_of_added_item} =         get_id_or_name_from_skumap        id         ${added_item}
        add_item_to_cart_items        ${id_of_added_item}
    END

    ${expected_recommendations_ids_list} =         get_expected_recommendations_from_api        ${recommendations_type}
    ${expected_recommendations_names_list} =        get_id_or_name_from_skumap_for_list        name        ${expected_recommendations_ids_list}
    Log        ${expected_recommendations_names_list}
    #dummy_keyword

    wait_for_element_state        ${locator}        visible
    ${recommended_items_elements} =     Get Elements        ${locator}
    @{actual_item_names_list} =    Create List
    #Debug
    FOR     ${recommended_items_element}    IN     @{recommended_items_elements}
        ${attribute_existence_status} =         Run Keyword And Return Status        Get Attribute Names        ${recommended_items_element}        contains         data-item-name
        IF        ${attribute_existence_status}
            #${item_name} =     Get Text        ${recommended_items_element}
            ${item_name} =     Get Attribute        ${recommended_items_element}        data-item-name
        ELSE
            ${item_name} =     Get Text        ${recommended_items_element}
        END
        # adding below line as the above logic fails in case of ellipses in cart where the attribute is also present
        # ${item_name} =     Get Text        ${recommended_items_element}
        ${does_not_contains_ellipses} =         Run Keyword And Return Status        Should Not Contain        ${item_name}        ...
        IF        not ${does_not_contains_ellipses}
            Log         has ellipses
            #debug
        END
        Append To List        ${actual_item_names_list}        ${item_name}
    END
    Log        ${actual_item_names_list}
    compare_actual_and_expected_recommendations_list        ${actual_item_names_list}        ${expected_recommendations_names_list}        ${recommendations_type}        ${failure_messages_variable}        ${expected_recommendations_ids_list}

compare_actual_and_expected_recommendations_list
    [Arguments]	    ${actual_recommendations_list}=        ${expected_recommendations_list}=        ${recommendations_type}=        ${failure_messages_variable}=        ${expected_recommendations_ids_list}=
    ${actual_list_counter} =     Set Variable    ${0}
    ${expected_list_counter} =     Set Variable    ${0}
    ${saved_for_recommended_item_to_add} =         Set Variable        False
    ${failure_message} =         Set Variable        [INFO]: ${recommendations_type} ACTUAL RECOMMENDATIONS: ${actual_recommendations_list}.
    Append To List        ${${failure_messages_variable}}        ${failure_message}
    ${failure_message} =         Set Variable        [INFO]: ${recommendations_type} EXPECTED RECOMMENDATIONS: ${expected_recommendations_list}
    Append To List        ${${failure_messages_variable}}        ${failure_message}
    ${failure_message} =         Set Variable        [INFO]: ${recommendations_type} EXPECTED RECOMMENDATIONS SKUs: ${expected_recommendations_ids_list}
    Append To List        ${${failure_messages_variable}}        ${failure_message}


    # reading the menu from menu request and checking if recommendations sent by API are active or not
    ${failure_message} =     get_expected_recommender_items_availability_status_from_menu_request        ${expected_recommendations_ids_list}

    ${failure_message} =         Set Variable        [INFO]: ${recommendations_type} EXPECTED RECOMMENDATIONS SKUs with status: ${expected_recommendations_ids_with_status}
    Append To List        ${${failure_messages_variable}}        ${failure_message}

    FOR        ${actual_recommended_item}    IN     @{actual_recommendations_list}
        ${match_found} =     Set Variable        False
        FOR        ${expected_recommended_item}    IN     @{expected_recommendations_list}
            ${comparison_status} =         Run Keyword And Return Status        Should Be Equal        ${actual_recommended_item}        ${expected_recommended_item}        ignore_case=True
            IF        ${comparison_status}
                ${match_found} =     Set Variable        True
                Exit For Loop
            END
        END
        IF    not ${match_found}
            ${failure_message} =         Set Variable        [ERROR]: ${recommendations_type} FAILURE MESSAGE. Actual recommendation ${actual_recommended_item} not found in recommendations returned by Recommender API
            Append To List        ${${failure_messages_variable}}        ${failure_message}
        ELSE
            IF        not ${saved_for_recommended_item_to_add}
                ${does_not_contains_ellipses} =         Run Keyword And Return Status        Should Not Contain        ${actual_recommended_item}        ...
                IF        ${does_not_contains_ellipses}
                    Set Test Variable            ${recommended_item_to_add}        ${actual_recommended_item}
                    ${saved_for_recommended_item_to_add} =         Set Variable        True
                END
            END
        END    
    END
    # Below condition ois added only for case when the item to add is not saved in the above loop
    IF        not ${saved_for_recommended_item_to_add}
        FOR        ${actual_recommended_item}    IN     @{actual_recommendations_list}
            ${does_not_contains_ellipses} =         Run Keyword And Return Status        Should Not Contain        ${actual_recommended_item}        ...
            IF        ${does_not_contains_ellipses}
                Set Test Variable            ${recommended_item_to_add}        ${actual_recommended_item}
                ${saved_for_recommended_item_to_add} =         Set Variable        True
                Exit For Loop
            END
        END

    END

get_id_or_name_from_skumap
    [Arguments]	    ${type}=        ${value}=
    ${value_to_return} =         Set Variable        ${EMPTY}
    IF     "${type}"=="id"
        FOR     ${row}    IN     @{skumap_data}
            ${comparison_status} =         Run Keyword And Return Status        Should Be Equal        ${row}[1]        ${value}
            IF         ${comparison_status}
                ${value_to_return} =     Set Variable        ${row}[0]
                Exit For Loop
            END
        END
    ELSE
        FOR     ${row}    IN     @{skumap_data}
            IF         "${row}[0]"=="${value}"
                ${value_to_return} =     Set Variable        ${row}[1]
                Exit For Loop
            END
        END
    END
    RETURN        ${value_to_return}

get_id_or_name_from_skumap_for_list
    [Arguments]	    ${type}=        ${value}=
    ${value_to_return} =         Create List
    FOR    ${item}    IN    @{value}
        ${item_converted} =         get_id_or_name_from_skumap        ${type}        ${item}
        Append To List        ${value_to_return}        ${item_converted}
    END
    RETURN        ${value_to_return}

get_expected_recommender_items_availability_status_from_menu_request
    [Arguments]	    ${expected_recommendations_ids_list}=
    
    ${headers}=     Create Dictionary        Accept=application/json
    ...            Authorization=Basic dWF0dXNlcjpQcmV2aWV3NFUh
    ${MenuRequest} =     Create Dictionary        
    ...    language=en-us
    ...    storeName=BK-70004
    ...    datetime=12:00:00
    ...    dayoftheWeek=Monday
    ...    date=10-08-2026
    ...    override=${True}
    ...    disposition=TO_GO
    
    ${MenuRequestJson} =     Convert Json To String     ${MenuRequest}
    
    ${params} =     Create Dictionary        MenuRequest=${MenuRequestJson}        locale=en-us        appVersion=1.289.0-15        disposition=TO_GO

    ${response}=     GET     
    ...     https://uat-bk-us-kiosk.tillster.com/mobilem8-menu-service/rest/menuservice/menu
    ...     params=${params}
    ...     headers=${headers}

    #Log     ${response.status_code}
    #Log     ${response.text}
    
    ${response_json} =     Evaluate     $response.json()

    ${layout_root} =         Get From Dictionary     ${response_json}     layoutRoot
    ${root} =         Get From Dictionary     ${layout_root}     root
    ${base_elements} =     Get From Dictionary     ${root}     elems
    ${type} =    Evaluate    type($base_elements)
    Log        ${type}

    ${available_items} =    Create List
    Set Test Variable    ${available_items}

    ${unavailable_items} =    Create List
    Set Test Variable    ${unavailable_items}
    
    check_expected_recommender_items_availability_status_from_menu_json        ${base_elements}        ${expected_recommendations_ids_list}
    
    Log        ${available_items}
    Log        ${unavailable_items}
    ${expected_recommendations_ids_with_status} =         Create List
    Set Test Variable    ${expected_recommendations_ids_with_status}
    
    FOR        ${expected_item_id}    IN        @{expected_recommendations_ids_list}
        IF    "${expected_item_id}" in ${available_items}
            ${item_id_with_status} =         Set Variable        ${expected_item_id}:AVAILABLE
            Append To List    ${expected_recommendations_ids_with_status}    ${item_id_with_status}
        ELSE
            ${item_id_with_status} =         Set Variable        ${expected_item_id}:UNAVAILABLE
            Append To List    ${expected_recommendations_ids_with_status}    ${item_id_with_status}
        END
    END
    Log        ${expected_recommendations_ids_with_status}



check_expected_recommender_items_availability_status_from_menu_json
    [Arguments]	    ${elements_json}=            ${expected_recommendations_ids_list}=
    FOR         ${element}        IN        @{elements_json}
        ${type} =    Evaluate    type($element)
        Log        ${type}
        Log        ${element}
        ${number_of_available_items} =         Get Length     ${available_items}
        ${number_of_unavailable_items} =         Get Length     ${unavailable_items}
        ${total_number_of_items} =         Get Length     ${expected_recommendations_ids_list}
        IF    ${{ $number_of_available_items + $number_of_unavailable_items == $total_number_of_items }}
            Exit For Loop
        END

        ${item_id} =        Get From Dictionary     ${element}     menuItemId
        IF    "${item_id}" in ${expected_recommendations_ids_list}
            IF    "${item_id}" in ${available_items}
                Log        ${item_id} already covered
            ELSE IF        "${item_id}" in ${unavailable_items}
                Log        ${item_id} already covered
            ELSE
                ${item_availability} =         Get From Dictionary     ${element}     menuItemAvailability
                IF        "${item_availability}" == "AVAILABLE"
                    Append To List    ${available_items}    ${item_id}
                ELSE
                    Append To List    ${unavailable_items}    ${item_id}
                    # if the parent is unavailable then not checking for child items. they will be unavailable by default
                    Continue For Loop
                END
            END
        END
        
        ${item_name} =         Get From Dictionary     ${element}     menuItemName
        IF        "${item_name}" == "OFF MENU ITEMS"
            # skipping all the elements of "OFF MENU ITEMS"
            Continue For Loop
        END
        
        IF    "elems" in $element
            ${new_elements} =         Get From Dictionary     ${element}     elems
            check_expected_recommender_items_availability_status_from_menu_json            ${new_elements}        ${expected_recommendations_ids_list}
        END
        #dummy_keyword
    END

update_recommender_ui_test_status_1
    [Arguments]	    ${test_name}=
    ${sheet_name} =         Set Variable        ${tenant}_${environment}_ui

    ${row_counter} =          Set Variable        ${1}
    FOR     ${row}    IN     @{test_data_1}
        ${row_counter} =         Set Variable        ${row_counter + 1}
        Log        ${row}[0]
        Log        ${test_name}
        IF        "${row}[0]"=="${test_name}" and "${row}[3]"=="${day_part_1}" and "${row}[2]"=="${day_of_the_week_1}"
            Log        ${row}
            ${context} =         Set Variable        ${row}[1]
            ${failure_messages} =             Set Variable        ${context}_failure_messages
            Log         ${${failure_messages}}
            ${test_status} =         Run Keyword And Return Status        Length Should Be    ${${failure_messages}}    1
            IF      not ${test_status}
                update_recommender_api_tests_results        ${sheet_name}        ${column_index_1}        ${row_counter}        FAIL
            ELSE
                update_recommender_api_tests_results        ${sheet_name}        ${column_index_1}        ${row_counter}        Pass
            END
            ${failure_messages_string} =    Catenate    @{${failure_messages}}
            update_recommender_api_tests_results        ${sheet_name}        ${column_index_1+1}        ${row_counter}        ${failure_messages_string}
        END
    END

update_recommender_ui_test_status
    [Arguments]	    ${test_name}=
    ${sheet_name} =         Set Variable        ${tenant}_${environment}_ui_2

    ${row_counter} =          Set Variable        ${1}
    FOR     ${row}    IN     @{test_cases_sheet_data}
        ${row_counter} =         Set Variable        ${row_counter + 1}
        Log        ${row}[0]
        Log        ${test_name}
        IF        "${row}[0]"=="${test_name}"
            Log        ${row}
            ${context} =         Set Variable        ${row}[1]
            ${failure_messages} =             Set Variable        ${context}_failure_messages
            Log         ${${failure_messages}}
            #${test_status} =         Run Keyword And Return Status        Length Should Be    ${${failure_messages}}    4
            ${failure_messages_string} =         Catenate        @{${failure_messages}}
            ${test_status} =         Run Keyword And Return Status        Should Contain        ${failure_messages_string}    [ERROR]
            #IF      not ${test_status}
            IF      ${test_status}
                #update_recommender_api_tests_results        ${sheet_name}        ${column_index_test_data_sheet}        ${row_counter}        FAIL
                update_recommender_api_tests_results        ${sheet_name}        3        ${row_counter}        FAIL
            ELSE
                #update_recommender_api_tests_results        ${sheet_name}        ${column_index_test_data_sheet}        ${row_counter}        Pass
                update_recommender_api_tests_results        ${sheet_name}        3        ${row_counter}        Pass
            END
            ${failure_messages_string} =    Catenate    SEPARATOR=\n        @{${failure_messages}}
            #update_recommender_api_tests_results        ${sheet_name}        ${column_index_test_data_sheet+1}        ${row_counter}        ${failure_messages_string}
            update_recommender_api_tests_results        ${sheet_name}        4        ${row_counter}        ${failure_messages_string}
        END
    END

get_expected_recommendations_from_api
    [Arguments]	    ${recommendations_type}=
    ${sample_json_file_path} =         Set Variable         ${EXECDIR}${/}recommender${/}sample.json
    ${sample_json_string} =        Get File            ${sample_json_file_path}

    # adding the selected item in the json string
    Log         ${sample_json_string}
    Log        ${items_in_cart}
    ${sample_json_string} =         Replace String        ${sample_json_string}        selected_items_in_test_data        ${items_in_cart}
    Log         ${sample_json_string}

    # adding the store id in the json string
    ${sample_json_string} =         Replace String        ${sample_json_string}        variable_store_id        ${STORE_ID}
    Log         ${sample_json_string}
    
    # adding the context in the json string
    IF        "Cart" in "${recommendations_type}"
        ${sample_json_string} =         Replace String        ${sample_json_string}        variable_context        cart
        Log         ${sample_json_string}
        ${get_items_count} =         Set Variable        6
    ELSE
        ${sample_json_string} =         Replace String        ${sample_json_string}        variable_context        cross-sell
        Log         ${sample_json_string}
        ${get_items_count} =         Set Variable        20
    END
    
    # get current date-time in specified timezone
    ${current_datetime} =     get_datetime_for_recommender_api        ${TIME_ZONE}

    # adding the order time in the json string
    ${sample_json_string} =         Replace String        ${sample_json_string}        order_time        ${current_datetime}
    Log         ${sample_json_string}

    ${request_header}=      Create Dictionary       tenant=${RECOMMENDER_API_TENANT}             Content-Type=application/json        env=${RECOMMENDER_API_ENVIRONMENT}
    ${request_query_params}=      Create Dictionary       items=${get_items_count}             channel=kiosk
    ${json_payload_for_request}=        Convert String to JSON          ${sample_json_string}
    ${response} =        Wait Until Keyword Succeeds     20 sec      1 sec       POST         ${RECOMMENDER_API_URL}/             json=${json_payload_for_request}       headers=${request_header}        params=${request_query_params}

    ${response_code_status} =  Run Keyword And Return Status        Should Be Equal As Numbers        ${RECOMMENDER_API_RESPONSE_CODE}      ${response.status_code}
    IF      not ${response_code_status}
        Fail        Response code of API is not as expected
    END

    ${response_skus} =         Set Variable            ${response.json()}[data]
    RETURN        ${response_skus}


add_item_to_cart_items
    [Arguments]	    ${id}=
    IF         "${items_in_cart}"=="${EMPTY}"
        Set Test Variable        ${items_in_cart}        ${id}
    ELSE
        Set Test Variable        ${items_in_cart}        ${id},${items_in_cart}
    END