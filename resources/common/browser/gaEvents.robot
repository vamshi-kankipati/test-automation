*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
# for recording HAR file
open_new_context
    [Documentation]    Tracking the GA events from HAR
    [Arguments]        ${lbs_enabled}=False        ${location_latitude}=Default        ${location_longitude}=Default        ${new_url}=none
    ${permissions}=     Set Variable        None
    IF      '${lbs_enabled}'!='False'
        ${permissions} =        Create List       geolocation
    END

    ${geolocation}=     Set Variable        None
    IF      '${location_latitude}'!='Default'
        ${location_latitude}     get argument actual value       ${location_latitude}
        ${location_longitude}     get argument actual value       ${location_longitude}
        ${geolocation} =        Create Dictionary       latitude=${location_latitude}       longitude=${location_longitude}
    END

    ${recorded_har_file_path} =         Set Variable        ${EXECDIR}${/}har.har
    ${file_exists}      Run Keyword and Return Status       File Should Exist           ${recorded_har_file_path}
    IF              ${file_exists}
        Remove File             ${recorded_har_file_path}
        Create File             ${recorded_har_file_path}
        Sleep           1s
    END
    ${har_config}=          Create Dictionary                   path=${recorded_har_file_path}               omitContent=false

    ${HTTP_USERNAME}        GetVariableValue     ${HTTP_USERNAME}
    ${HTTP_PASSWORD}        GetVariableValue     ${HTTP_PASSWORD}

    ${pwd} =     Set Variable     ${HTTP_PASSWORD}
    ${username} =     Set Variable     ${HTTP_USERNAME}

    New context         permissions=${permissions}        geolocation=${geolocation}        recordHar=${har_config}        httpCredentials={'username': '${username}', 'password': '$pwd'}
    IF              '${new_url}'=='none'
        Log         ${url}
        New Page            ${url}
    ELSE
        ${new_url}      get argument actual value     ${new_url}
        New Page            ${new_url}
    END
    Set Test Variable       ${RECOMMENDED_ITEMS_COUNT}     0

open_new_non_incognito_context
    [Documentation]         For setting the pre-requisites and opening page
    [Arguments]             ${lbs_enabled}=False        ${location_latitude}=Default        ${location_longitude}=Default        ${new_url}=none
    #${execution_browser}      get argument actual value     ${execution_browser}
    #${userAgent}      get argument actual value     ${userAgent}
    #${viewport}      get argument actual value     ${viewport}
    ${permissions}=     Set Variable        None
    IF      '${lbs_enabled}'!='False'
        ${permissions} =        Create List       geolocation
    END

    ${geolocation}=     Set Variable        None
    IF      '${location_latitude}'!='Default'
        ${location_latitude}     get argument actual value       ${location_latitude}
        ${location_longitude}     get argument actual value       ${location_longitude}
        ${geolocation} =        Create Dictionary       latitude=${location_latitude}       longitude=${location_longitude}
    END

    ${recorded_har_file_path} =         Set Variable        ${EXECDIR}${/}har.har
    ${file_exists}      Run Keyword and Return Status       File Should Exist           ${recorded_har_file_path}
    IF              ${file_exists}
        Remove File             ${recorded_har_file_path}
        Create File             ${recorded_har_file_path}
        Sleep           1s
    END
    ${har_config}=          Create Dictionary                   path=${recorded_har_file_path}               omitContent=false
    ${HTTP_USERNAME}        GetVariableValue     ${HTTP_USERNAME}
    ${HTTP_PASSWORD}        GetVariableValue     ${HTTP_PASSWORD}

    ${pwd} =     Set Variable     ${HTTP_PASSWORD}
    ${username} =     Set Variable     ${HTTP_USERNAME}
    New Persistent Context         headless=false    permissions=${permissions}        geolocation=${geolocation}        recordHar=${har_config}        httpCredentials={'username': '${username}', 'password': '$pwd'}
    # New Persistent Context         url=${url}           browser=${execution_browser}        headless=${headless}       userAgent=${userAgent}                viewport=${viewport}

    IF              '${new_url}'=='none'
        New Page            ${url}
    ELSE
        ${new_url}      get argument actual value     ${new_url}
        New Page            ${new_url}
    END
    Set Test Variable       ${RECOMMENDED_ITEMS_COUNT}     0

open_new_context_2
    [Documentation]    Tracking the GA events from HAR
	#[Arguments]	    ${recorded_har_file_path}=None
    [Arguments]	    ${recorded_har_file_path}=${EXECDIR}${/}har.har
    ${file_exists}      Run Keyword and Return Status       File Should Exist           ${recorded_har_file_path}
    IF              ${file_exists}
        Remove File             ${recorded_har_file_path}
        #Create File             ${recorded_har_file_path}
        Sleep           1s
    END

    ${proxy_port}=          Create Dictionary                   existing_proxy_port_to_use=${8080}
    Start Local Server      ${EXECDIR}${/}browsermob-proxy-2.1.4${/}bin${/}browsermob-proxy     options=${proxy_port}
    ${BrowserMob_Proxy} =    Create Proxy
    Log         ${BrowserMob_Proxy.port}
    #Stop Local Server

    #${proxy_config}=          Create Dictionary                   server=${BrowserMob_Proxy}
    ${proxy_config}=          Create Dictionary                   server=https://localhost:${BrowserMob_Proxy.port}
    #${proxy_config}=          Create Dictionary                   server="https://0.0.0.0:8081"

    New context         proxy=${proxy_config}

    New Har

    Browser.New Page            ${url}
    Debug

# for recording HAR file
#extract_ga_calls_info_and_save_as_json
compare_current_ga_calls_with_baseline
    [Documentation]    Tracking the GA events from HAR
	#[Arguments]	        ${recorded_har_file_path}=None
	[Arguments]	        ${baseline}=None

    # for testing
    # validate_ga_json_file        ${baseline}

    ${baseline}  get argument actual value      ${baseline}
    # Fetching the calls in har file and storing it in entries_list

#    ${recorded_har_file}=        Get File            ${recorded_har_file_path}
#    ${recorded_har_file_json}=        Convert String to JSON          ${recorded_har_file}
#    @{entries_list}=       SET VARIABLE            ${recorded_har_file_json['log']['entries']}
    @{entries_list} =        get_all_calls_from_har_file
    ${entries_length}                 GET LENGTH              ${entries_list}
    Log to Console          entries_length::: ${entries_length}

    # getting count of analytics requests
    ${iteration_count} =      SET VARIABLE        ${0}
    ${count_of_calls} =      SET VARIABLE        ${0}
    ${ga_calls} =       Create Dictionary
    FOR     ${entries}      IN          @{entries_list}
        ${iteration_count} =      EVALUATE        ${iteration_count} + 1
        #IF      "analytics.google.com" in "${entries['request']['url']}" and "POST" in "${entries['request']['method']}"
        IF      "/g/collect?" in "${entries['request']['url']}" and "POST" in "${entries['request']['method']}"
            ${count_of_calls} =      EVALUATE        ${count_of_calls} + 1
            ${ga_parameters} =      get_ga_prameters_from_request       ${entries}
            Log         ${ga_parameters}
            IF      '${ga_parameters.get("en")}'=='${None}'
                ${ga_calls_from_composite_call} =      get_ga_calls_from_composite_request        ${entries}
                IF      """${ga_calls_from_composite_call}"""=="""no_post_data"""
                    ${ga_calls} =       add_new_ga_call_to_dict     ${ga_calls}     ${ga_parameters}
                    Continue For Loop
                END
                ${count} =      Get Length      ${ga_calls_from_composite_call}
                FOR     ${ga_call_from_composite_call}      IN      @{ga_calls_from_composite_call}
                    ${ga_parameters} =      get_ga_prameters_from_individual_call_in_composite_request          ${ga_call_from_composite_call}
                    ${ga_calls} =       add_new_ga_call_to_dict     ${ga_calls}     ${ga_parameters}
                END
            ELSE
                ${ga_calls} =       add_new_ga_call_to_dict     ${ga_calls}     ${ga_parameters}
            END
            #${ga_calls} =       add_new_ga_call_to_dict     ${ga_calls}     ${ga_parameters}
        END
    END
    Log         ${count_of_calls}
    Log         ${ga_calls}

    ${ga_info_dict} =      Create Dictionary

    # remove the page_views
#    ${page_view_calls_list} =       Create List
#    FOR    ${key}    IN    @{ga_calls.keys()}
#        IF      "page_view" in "${key}" or "view_recommended_item" in "${key}"
#            Append To List      ${page_view_calls_list}     ${key}
#        END
#    END

    # view_recommended_item
    ${file_exists} =      Run Keyword and Return Status        File Should Exist      ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
    IF     ${file_exists}
        ${ga_calls_parameters_file} =        Get File            ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
        ${ga_calls_parameters_file_json}=        Convert String to JSON          ${ga_calls_parameters_file}

        ${ga_calls_node} =         Get From Dictionary        ${ga_calls_parameters_file_json}        valid_calls_list

        ${valid_calls_list} =         Get Dictionary Keys        ${ga_calls_node}        sort_keys=False
    ELSE IF    "kiosk" in "${tenant}"
        @{valid_calls_list} =       Create List         language_selection      order_disposition       sign_up     login
        ...     spend_virtual_currency      earn_virtual_currency       select_content      view_item_list
        ...     select_item     select_combo        add_recommendation_to_cart      purchase_recommended_item
        ...     view_cart       view_item       add_to_cart     remove_from_cart        edit_cart       begin_checkout
        ...     apply_promotion     remove_promotion        add_payment_info        purchase        session_end
    ELSE
        @{valid_calls_list} =       Create List         select_content      view_item_list      select_item         view_store_list
        ...     select_store        select_order_disposition        spend_virtual_currency      earn_virtual_currency
        ...     view_item       add_to_cart         add_recommendation_to_cart      view_cart
        ...     remove_from_cart        edit_cart       begin_checkout      sign_up     login       apply_promotion
        ...     remove_promotion        add_payment_info        purchase_recommended_item       purchase        change_password
        ...     forgot_password     reset_password      edit_profile
    END

    ${invalid_calls_list} =       Create List

    ${view_recommended_call_count} =        Set Variable        0

    Log         ${ga_calls.keys()}
    FOR    ${key}    IN    @{ga_calls.keys()}
        # Split here
        # ${key_contents} =        Split String        ${key}           _
        ${new_key} =        Remove String Using Regexp         ${key}      _\\d+
        IF    "${new_key}"=="view_recommended_item"
            ${view_recommended_call_count} =        Evaluate        ${view_recommended_call_count}+1
        END
    END

    #Log     ${RECOMMENDED_ITEMS_COUNT}
    Log     ${view_recommended_call_count}

    FOR    ${key}    IN    @{ga_calls.keys()}
        # Split here
        # ${key_contents} =        Split String        ${key}           _
        ${new_key} =        Remove String Using Regexp         ${key}      _\\d+
        IF    "${new_key}" not in @{valid_calls_list}
            Append To List      ${invalid_calls_list}     ${key}
        END
    END

    FOR    ${key}    IN    @{invalid_calls_list}
        Remove From Dictionary          ${ga_calls}         ${key}
    END


    ${ga_calls_length} =        Get Length      ${ga_calls}
    Set To Dictionary       ${ga_info_dict}        total_ga_calls=${ga_calls_length}
    Set To Dictionary       ${ga_info_dict}        ga_calls=${ga_calls}
    #${har_info_string} =        Convert To String    ${har_info_dict}
    #${har_info_json} =        Convert String to JSON          ${har_info_string}


    # writing to file
    ${basline_exists}       Run Keyword and Return Status       File Should Exist       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json
    IF     not ${basline_exists}
        #Dump Json To File       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json         ${ga_info_dict}
        write_json_to_file       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json         ${ga_info_dict}
        Log         Baseline HAR info file not available. Created one!!!
        validate_ga_json_file        ${ga_info_dict}
    ELSE
        #Dump Json To File       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json         ${ga_info_dict}
        write_json_to_file       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json         ${ga_info_dict}
        validate_ga_json_file        ${ga_info_dict}
    END

    #JSONLibrary.Dump Json To File       ${EXECDIR}${/}info.json         ${har_info_dict}

    compare_current_and_baseline_ga_calls_in_flow       ${baseline}

#    ${match}    Run Keyword And Return Status   should be equal     ${view_recommended_call_count}      ${RECOMMENDED_ITEMS_COUNT}
#    IF      not ${match}
#        Fail    Number of view recommended items calls sent does not match count of recommeded items displayed on UI. Calls Sent:${view_recommended_call_count}    Items shown on UI:${RECOMMENDED_ITEMS_COUNT}
#    END


get_all_calls_from_har_file
    [Arguments]	    ${recorded_har_file_path}=${EXECDIR}${/}har.har
    ${recorded_har_file}=        Get File            ${recorded_har_file_path}
    ${recorded_har_file_json}=        Convert String to JSON          ${recorded_har_file}
    @{entries_list}=       SET VARIABLE            ${recorded_har_file_json['log']['entries']}
    [return]  ${entries_list}


# for recording HAR file
compare_number_of_ga_calls_in_flow
    [Arguments]	        ${baseline}=None

    ${baseline}  get argument actual value      ${baseline}
    ${current_exists}       Run Keyword and Return Status       File Should Exist       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
    IF     not ${current_exists}
        Log         Current GA JSON info file not available.
    ELSE
        ${baseline_json_file}=        Get File            ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json
        ${baseline_json_file_json}=        Convert String to JSON          ${baseline_json_file}
        ${baseline_number_of_calls}=       SET VARIABLE            ${baseline_json_file_json['total_ga_calls']}

        ${current_json_file}=        Get File            ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
        ${current_json_file_json}=        Convert String to JSON          ${current_json_file}
        ${current_number_of_calls}=       SET VARIABLE            ${current_json_file_json['total_ga_calls']}

        Should Be Equal As Numbers        ${current_number_of_calls}      ${baseline_number_of_calls}


    END

compare_current_and_baseline_ga_calls_in_flow
    [Arguments]	        ${baseline}=None

    ${baseline}  get argument actual value      ${baseline}
    ${current_exists}       Run Keyword and Return Status       File Should Exist       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
    IF     not ${current_exists}
        Log         Current GA JSON info file not available.
    ELSE
        ${file_exists} =      Run Keyword and Return Status        File Should Exist      ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
        IF     ${file_exists}
            ${ga_calls_parameters_file} =        Get File            ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
            ${ga_calls_parameters_file_json}=        Convert String to JSON          ${ga_calls_parameters_file}
            ${ga_calls_node_from_template} =         Get From Dictionary        ${ga_calls_parameters_file_json}        valid_calls_list
            # ${valid_calls_list_from_template} =         Get Dictionary Keys        ${ga_calls_node_from_template}        sort_keys=False

            ${ga_calls_node_from_template} =         Get From Dictionary        ${ga_calls_parameters_file_json}        valid_calls_list
            ${valid_calls_list_from_template} =         Get Dictionary Keys        ${ga_calls_node_from_template}        sort_keys=False
            
            
            ${baseline_json_file}=        Get File            ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json
            ${baseline_json_file_json}=        Convert String to JSON          ${baseline_json_file}

            ${current_json_file}=        Get File            ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
            ${current_json_file_json}=        Convert String to JSON          ${current_json_file}

            ${baseline_ga_calls} =         Get From Dictionary        ${baseline_json_file_json}        ga_calls
            ${current_ga_calls} =         Get From Dictionary        ${current_json_file_json}        ga_calls

            ${baseline_ga_calls_keys} =         Get Dictionary Keys        ${baseline_ga_calls}        sort_keys=False
            ${current_ga_calls_keys} =         Get Dictionary Keys        ${current_ga_calls}        sort_keys=False
            
            ${number_of_ga_calls_in_baseline} =         Get Length          ${baseline_ga_calls_keys}
            ${number_of_ga_calls_in_current} =         Get Length          ${current_ga_calls_keys}
            
            IF         ${number_of_ga_calls_in_baseline} >= ${number_of_ga_calls_in_current}
                Log         Baseline is greater
                exhaustive_comparison_of_baseline_and_current_ga_files        ${ga_calls_node_from_template}        ${baseline_ga_calls}        ${current_ga_calls}    baseline         current        ${baseline}
            ELSE
                Log         Current is greater
                exhaustive_comparison_of_baseline_and_current_ga_files        ${ga_calls_node_from_template}        ${current_ga_calls}        ${baseline_ga_calls}        current        baseline        ${baseline}
            END
        END
    END

exhaustive_comparison_of_baseline_and_current_ga_files
    [Arguments]	        ${ga_calls_node_from_template}=None        ${dict_with_more_calls}=None        ${dict_with_less_calls}=None        ${more_calls_dict_name}=None        ${less_calls_dict_name}=None        ${baseline}=None
    @{comparison_errors} =         Create List

    ${dict_with_more_calls_keys} =         Get Dictionary Keys        ${dict_with_more_calls}        sort_keys=False
    ${dict_with_less_calls_keys} =         Get Dictionary Keys        ${dict_with_less_calls}        sort_keys=False
    
    ${session_id_1} =         get_session_id_from_dict        ${dict_with_more_calls}
    ${session_id_2} =         get_session_id_from_dict        ${dict_with_less_calls}

    ${dict_with_less_calls_keys_length} =        Get Length        ${dict_with_less_calls_keys}

    ${counter} =         Set Variable        ${0}
    FOR    ${key}    IN    @{dict_with_more_calls_keys}
        IF     "${key}"!="${dict_with_less_calls_keys}[${counter}]"
            IF         "view_recommended_item" in "${key}"
                # earlier this was done to ignore view_recommended_item as it was supposed to change
                # Continue For Loop
                compare_json_files_hl_method          ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
#                ${counter2} =         Set Variable        ${counter}
#                FOR    ${index}    IN RANGE    ${counter2}        ${dict_with_less_calls_keys_length}
#                    ${counter} =    Evaluate        ${counter} + 1
#                    IF     "${key}"=="${dict_with_less_calls_keys}[${index}]"
#                        Exit For Loop
#                    END
#                END
            ELSE
                compare_json_files_hl_method          ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
            END
        END
        IF     "${key}"=="${dict_with_less_calls_keys}[${counter}]"
            ${parameters_of_call_dict_with_more_calls} =         Get From Dictionary        ${dict_with_more_calls}        ${key}
            ${parameters_of_call_dict_with_more_calls_keys} =         Get Dictionary Keys        ${parameters_of_call_dict_with_more_calls}        sort_keys=True
            ${parameters_of_call_dict_with_less_calls} =         Get From Dictionary        ${dict_with_less_calls}        ${key}
            ${parameters_of_call_dict_with_less_calls_keys} =         Get Dictionary Keys        ${parameters_of_call_dict_with_less_calls}        sort_keys=True


            FOR    ${para}    IN    @{parameters_of_call_dict_with_more_calls_keys}
                Log         ${comparison_errors}
                ${result} =         Run Keyword And Return Status        List Should Contain Value            ${parameters_of_call_dict_with_less_calls_keys}            ${para}
                IF     not ${result}
                    Append To List        ${comparison_errors}        ${key} does not contain parameter ${para} in either baseline or current JSON.
                END
            END
            FOR    ${para}    IN    @{parameters_of_call_dict_with_less_calls_keys}
                Log         ${comparison_errors}
                ${result} =         Run Keyword And Return Status        List Should Contain Value            ${parameters_of_call_dict_with_more_calls_keys}            ${para}
                IF     not ${result}
                    Append To List        ${comparison_errors}        ${key} does not contain parameter ${para} in either baseline or current JSON.
                END
            END
            ${new_key} =        Remove String Using Regexp         ${key}      _\\d+
            ${parameters_of_ga_calls_node_from_template} =         Get From Dictionary        ${ga_calls_node_from_template}        ${new_key}
            ${parameters_of_ga_calls_node_from_template_keys} =         Get Dictionary Keys        ${parameters_of_ga_calls_node_from_template}        sort_keys=True
            FOR        ${parameter}    IN    @{parameters_of_call_dict_with_more_calls_keys}
                IF         "${parameter}"=="en"
                    ${template_parameter} =     Set Variable        ${parameter}
                ELSE
                    FOR         ${template_parameter_key}    IN    @{parameters_of_ga_calls_node_from_template_keys}
                        IF         "${template_parameter_key}"=="en"
                            Continue For Loop
                        ELSE IF         "${template_parameter_key}" in "${parameter}"
                            ${template_parameter} =     Set Variable        ${template_parameter_key}
                            Exit For Loop
                        END
                    END
                END
                ${template_parameter_value} =         Get From Dictionary        ${parameters_of_ga_calls_node_from_template}        ${template_parameter}
                ${parameter_value_dict_with_more_calls} =         Get From Dictionary        ${parameters_of_call_dict_with_more_calls}        ${parameter}
                ${parameter_value_dict_with_less_calls} =         Get From Dictionary        ${parameters_of_call_dict_with_less_calls}        ${parameter}
                IF         "match" in "${template_parameter_value}"
                    IF      "session_id" in "${parameter}"
                        Log         "Do not replace session id"
                    ELSE IF        "transaction_id" in "${parameter}"
                        Log         "Do not replace session id"
                    ELSE
                        ${parameter_value_dict_with_more_calls} =         Replace String         ${parameter_value_dict_with_more_calls}         ${session_id_1}            ${EMPTY}
                        ${parameter_value_dict_with_more_calls} =         Replace String         ${parameter_value_dict_with_more_calls}         ${session_id_2}            ${EMPTY}
                        ${parameter_value_dict_with_less_calls} =         Replace String         ${parameter_value_dict_with_less_calls}         ${session_id_1}            ${EMPTY}
                        ${parameter_value_dict_with_less_calls} =         Replace String         ${parameter_value_dict_with_less_calls}         ${session_id_2}            ${EMPTY}
                    END
                    Log         ${parameter_value_dict_with_more_calls}
                    Log         ${parameter_value_dict_with_less_calls}
                    IF        """${parameter_value_dict_with_more_calls}"""!="""${parameter_value_dict_with_less_calls}"""
                        Append To List        ${comparison_errors}        ${key} contains different values for parameter ${parameter}. It should be same.
                    END
                ELSE IF         "different" in "${template_parameter_value}"
                    IF      "session_id" in "${parameter}"
                        Log         "Do not replace session id"
                    ELSE IF        "transaction_id" in "${parameter}"
                        Log         "Do not replace session id"
                    ELSE
                        ${parameter_value_dict_with_more_calls} =         Replace String         ${parameter_value_dict_with_more_calls}         ${session_id_1}            ${EMPTY}
                        ${parameter_value_dict_with_more_calls} =         Replace String         ${parameter_value_dict_with_more_calls}         ${session_id_2}            ${EMPTY}
                        ${parameter_value_dict_with_less_calls} =         Replace String         ${parameter_value_dict_with_less_calls}         ${session_id_1}            ${EMPTY}
                        ${parameter_value_dict_with_less_calls} =         Replace String         ${parameter_value_dict_with_less_calls}         ${session_id_2}            ${EMPTY}
                    END
                    Log         ${parameter_value_dict_with_more_calls}
                    Log         ${parameter_value_dict_with_less_calls}
                    IF        """${parameter_value_dict_with_more_calls}"""=="""${parameter_value_dict_with_less_calls}"""
                        Append To List        ${comparison_errors}        ${key} contains same values for parameter ${parameter}. It should be different.
                    END
                END
            END
            ${counter} =    Evaluate        ${counter} + 1
        END
    END

    ${comparison_errors_length} =         Get Length        ${comparison_errors}
    IF        "${comparison_errors_length}"!="0"
        Log     ${comparison_errors_length}
        Fail    Assertion failure: Generated Current JSON file comparison with Baseline JSON file failed with following errors: ${comparison_errors}
    END


compare_current_and_baseline_ga_calls_in_flow_old
    [Arguments]	        ${baseline}=None

    ${baseline}  get argument actual value      ${baseline}
    ${current_exists}       Run Keyword and Return Status       File Should Exist       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
    IF     not ${current_exists}
        Log         Current GA JSON info file not available.
    ELSE
        ${baseline_json_file}=        Get File            ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json
        ${baseline_json_file_json}=        Convert String to JSON          ${baseline_json_file}
        ${baseline_number_of_calls}=       SET VARIABLE            ${baseline_json_file_json['total_ga_calls']}

        ${current_json_file}=        Get File            ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
        ${current_json_file_json}=        Convert String to JSON          ${current_json_file}
        ${current_number_of_calls}=       SET VARIABLE            ${current_json_file_json['total_ga_calls']}

        #Dictionaries Should Be Equal        ${current_json_file_json}      ${baseline_json_file_json}

        ${baseline_ga_calls} =         Get From Dictionary        ${baseline_json_file_json}        ga_calls
        ${current_ga_calls} =         Get From Dictionary        ${current_json_file_json}        ga_calls

        ${baseline_ga_calls_keys} =         Get Dictionary Keys        ${baseline_ga_calls}        sort_keys=False
        ${current_ga_calls_keys} =         Get Dictionary Keys        ${current_ga_calls}        sort_keys=False

        Log         ${baseline_ga_calls_keys}
        Log         ${current_ga_calls_keys}
        ${list_status} =         Run Keyword And Return Status     Lists Should Be Equal        ${baseline_ga_calls_keys}        ${current_ga_calls_keys}
        IF      not ${list_status}
            compare_json_files_hl_method          ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
        END

        FOR    ${key}    IN    @{baseline_ga_calls_keys}
            ${baseline_ga_call} =         Get From Dictionary        ${baseline_ga_calls}        ${key}
            ${current_ga_call} =         Get From Dictionary        ${current_ga_calls}        ${key}
            
            ${baseline_ga_call_keys} =         Get Dictionary Keys        ${baseline_ga_call}        sort_keys=False
            ${current_ga_call_keys} =         Get Dictionary Keys        ${current_ga_call}        sort_keys=False
            
            Log         ${baseline_ga_call_keys}
            Log         ${current_ga_call_keys}
            ${list_status} =         Run Keyword And Return Status     Lists Should Be Equal        ${baseline_ga_call_keys}        ${current_ga_call_keys}
            
            IF      not ${list_status}
                compare_json_files_hl_method          ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
            END
            
            FOR    ${sub_key}    IN    @{baseline_ga_call_keys}
                ${baseline_parameter_value} =         Get From Dictionary        ${baseline_ga_call}        ${sub_key}
                ${current_parameter_value} =         Get From Dictionary        ${current_ga_call}        ${sub_key}

                @{parameters_to_be_skipped} =       Create List        ep.k_session_id        ep.experiment_id
                ...        ep.experiment_variant

                IF    "${sub_key}" in @{parameters_to_be_skipped}
                    Continue For Loop
                END
                
                ${baseline_parameter_value} =         Get From Dictionary        ${baseline_ga_call}        ${sub_key}
                ${current_parameter_value} =         Get From Dictionary        ${current_ga_call}        ${sub_key}

                IF    """${baseline_parameter_value}""" != """${current_parameter_value}"""
                    compare_json_files_hl_method          ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
                END

            END

        END

#        ${compared_differences} =       compare_json_and_write_differences_in_file          ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}.json         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${baseline}_current.json
#        ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${compared_differences}
#
#        IF      not ${isEmpty}
#                Fail    Assertion failure: Baseline and current JSONs are not equal. Differences: ${compared_differences}
#        END

    END

compare_json_files_hl_method
    [Arguments]	        ${baseline}=none        ${current}=none
        ${compared_differences} =       compare_json_and_write_differences_in_file          ${baseline}         ${current}
        ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${compared_differences}

        IF      not ${isEmpty}
            Fail    Assertion failure: Baseline and current JSONs are not equal. Differences: ${compared_differences}
        END

get_ga_prameters_from_request
    [Arguments]	        ${request}=none
    ${ga_parameters} =      Create Dictionary

#    @{params_to_capture} =      Create List     ep.method       ep.environment      up.customer_type        up.uuid
#    ...     ep.store_id     ep.store_name       ep.store_city       epn.store_state     ep.store_country
#    ...     up.order_disposition        up.day_part     pr1     pr2     epn.value

    ${file_exists} =      Run Keyword and Return Status        File Should Exist      ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
    IF     ${file_exists}
        ${ga_calls_parameters_file} =        Get File            ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
        ${ga_calls_parameters_file_json}=        Convert String to JSON          ${ga_calls_parameters_file}

        ${ga_calls_node} =         Get From Dictionary        ${ga_calls_parameters_file_json}        valid_calls_list

        ${valid_calls} =         Get Dictionary Keys        ${ga_calls_node}        sort_keys=False
    ELSE IF    "kiosk" in "${tenant}"
        @{params_to_capture} =       Create List         selection      method      login_location      transaction_id
        ...     store_id        value       virtual_currency        content_type        content_name        item_id
        ...     item_list_id        item_list_name      product_type        stage       item_name       currency
        ...     location_of_recommendation      algorithm_variant       cartsize_variant        product_variant
        ...     algorithm_selection     slot        source      prod_sku        prod_name       description
        ...     customer_type       coupon      discount        payment_type        tax     reorder     coupon_id
        ...     tip     transaction_channel     transaction_day     transaction_hour        k_session_id
        ...     k_language      store_name      kiosk_name      kiosk_id        kiosk_layout        kiosk_machine
        ...     pos_name        experiment_id       experiment_variant
    ELSE
        @{params_to_capture} =      Create List         content_type        item_id     item_list_id        item_list_name
        ...     product_type        store_id        store_name          store_city      store_state     store_country
        ...     order_disposition       order_type      transaction_id      value       virtual_currency        currency
        ...     product_type        items       response_time       location_of_recommendation      algorithm_variant
        ...     cartsize_variant        product_variant     algorithm_selection     slot        source      prod_sku
        ...     prod_name       method      description     payment_type        tax     reorder     shipping        coupon
        ...     coupon_id       tip     transaction_channel     transaction_day         transaction_hour
    END

    FOR             ${querystrings}          IN              @{request['request']['queryString']}
        @{params_to_capture} =      Create List        invalid_call_to_be_removed
        IF      "${querystrings['name']}"=="en"
            IF    "${querystrings['value']}" in @{valid_calls}
                ${ga_call_parameters} =         Get From Dictionary        ${ga_calls_node}        ${querystrings['value']}
                @{params_to_capture} =         Get Dictionary Keys        ${ga_call_parameters}        sort_keys=False
                Exit For Loop
            ELSE
                @{params_to_capture} =      Create List        invalid_call_to_be_removed
                Exit For Loop
            END
        END
    END
    
    FOR             ${querystrings}          IN              @{request['request']['queryString']}
        #Log to console          ${querystrings['name']}
        #Log to console          ${querystrings['value']}
        IF      "${querystrings['name']}"=="en"
            Set To Dictionary       ${ga_parameters}        en=${querystrings['value']}
#        ELSE IF     "${querystrings['name']}"=="dl"
#            Set To Dictionary       ${ga_parameters}        dl=${querystrings['value']}
#        ELSE IF    "${querystrings['name']}" in @{params_to_capture}
#            Set To Dictionary       ${ga_parameters}        ${querystrings['name']}=${querystrings['value']}
        ELSE
#            FOR         ${param}        IN      @{params_to_capture}
#                IF    "${param}" in "${querystrings['name']}"
#                    IF      "transaction_id" in "${querystrings['name']}"
#                        Set To Dictionary       ${ga_parameters}        ${querystrings['name']}=transaction_id
#                    ELSE IF     "transaction_hour" in "${querystrings['name']}"
#                        Set To Dictionary       ${ga_parameters}        ${querystrings['name']}=transaction_hour
#                    ELSE IF     "transaction_day" in "${querystrings['name']}"
#                        Set To Dictionary       ${ga_parameters}        ${querystrings['name']}=transaction_day
#                    ELSE
#                        Set To Dictionary       ${ga_parameters}        ${querystrings['name']}=${querystrings['value']}
#                    END
#                END
#            END
            FOR         ${param}        IN      @{params_to_capture}
                ${query_string_name}        Set Variable        ${querystrings['name']}
                IF        """.""" in """${querystrings['name']}"""
                    ${query_string_name_list}         Split String       ${querystrings['name']}         .
                    ${query_string_name}        Set Variable        ${query_string_name_list[1]}
                END
                IF    "${param}" == "${query_string_name}"
                    Set To Dictionary       ${ga_parameters}        ${querystrings['name']}=${querystrings['value']}
                END
            END
            ${match}   Run Keyword And Return Status       Should Match Regexp  ${querystrings['name']}    pr\\d+
            IF   ${match}
                Set To Dictionary       ${ga_parameters}        ${querystrings['name']}=${querystrings['value']}
            END
        END
    END

    [return]  ${ga_parameters}

get_ga_prameters_from_individual_call_in_composite_request
    [Arguments]	        ${request}=none
    ${ga_parameters} =      Create Dictionary

#    @{params_to_capture} =      Create List     ep.method       ep.environment      up.customer_type        up.uuid
#    ...     ep.store_id     ep.store_name       ep.store_city       epn.store_state     ep.store_country
#    ...     up.order_disposition        up.day_part     pr1     pr2     epn.value

    ${file_exists} =      Run Keyword and Return Status        File Should Exist      ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
    IF     ${file_exists}
        ${ga_calls_parameters_file} =        Get File            ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
        ${ga_calls_parameters_file_json}=        Convert String to JSON          ${ga_calls_parameters_file}

        ${ga_calls_node} =         Get From Dictionary        ${ga_calls_parameters_file_json}        valid_calls_list

        ${valid_calls} =         Get Dictionary Keys        ${ga_calls_node}        sort_keys=False
    ELSE IF    "kiosk" in "${tenant}"
        @{params_to_capture} =       Create List         selection      method      login_location      transaction_id
        ...     store_id        value       virtual_currency        content_type        content_name        item_id
        ...     item_list_id        item_list_name      product_type        stage       item_name       currency
        ...     location_of_recommendation      algorithm_variant       cartsize_variant        product_variant
        ...     algorithm_selection     slot        source      prod_sku        prod_name       description
        ...     customer_type       coupon      discount        payment_type        tax     reorder     coupon_id
        ...     tip     transaction_channel     transaction_day     transaction_hour        k_session_id
        ...     k_language      store_name      kiosk_name      kiosk_id        kiosk_layout        kiosk_machine
        ...     pos_name        experiment_id       experiment_variant
    ELSE
        @{params_to_capture} =      Create List         content_type        item_id     item_list_id        item_list_name
        ...     product_type        store_id        store_name          store_city      store_state     store_country
        ...     order_disposition       order_type      transaction_id      value       virtual_currency        currency
        ...     product_type        items       response_time       location_of_recommendation      algorithm_variant
        ...     cartsize_variant        product_variant     algorithm_selection     slot        source      prod_sku
        ...     prod_name       method      description     payment_type        tax     reorder     shipping        coupon
        ...     coupon_id       tip     transaction_channel     transaction_day         transaction_hour
    END

    @{params_to_capture_old} =      Create List     ep.store_id     ep.store_name       ep.store_city       epn.store_state
    ...     ep.store_country        ep.order_disposition

    ${parameters} =        Split String        ${request}           &
    ${count} =      Get Length      ${parameters}

    FOR             ${patameter}        IN          @{parameters}
        @{params_to_capture} =      Create List        invalid_call_to_be_removed
        ${parameter_split} =      Split String        ${patameter}      =
        IF      "${parameter_split}[0]"=="en"
            IF    "${parameter_split}[1]" in @{valid_calls}
                ${ga_call_parameters} =         Get From Dictionary        ${ga_calls_node}        ${parameter_split}[1]
                @{params_to_capture} =         Get Dictionary Keys        ${ga_call_parameters}        sort_keys=False
                Exit For Loop
            ELSE
                @{params_to_capture} =      Create List        invalid_call_to_be_removed
                Exit For Loop
            END
        END
    END


    FOR         ${patameter}        IN          @{parameters}
        ${parameter_split} =      Split String        ${patameter}      =
        Log         ${parameter_split}[1]
        IF      "${parameter_split}[0]"=="en"
            Set To Dictionary       ${ga_parameters}        en=${parameter_split}[1]
#        ELSE IF     "${parameter_split}[0]"=="dl"
#            Set To Dictionary       ${ga_parameters}        dl=${parameter_split}[1]
#        ELSE IF    "${parameter_split}[0]" in @{params_to_capture}
#            Set To Dictionary       ${ga_parameters}        ${parameter_split}[0]=${parameter_split}[1]
        ELSE
#            FOR         ${param}        IN      @{params_to_capture}
#                IF    "${param}" in "${parameter_split}[0]"
#                    IF      "transaction_id" in "${parameter_split}[0]"
#                        Set To Dictionary       ${ga_parameters}        ${parameter_split}[0]=transaction_id
#                    ELSE IF     "transaction_hour" in "${parameter_split}[0]"
#                        Set To Dictionary       ${ga_parameters}        ${parameter_split}[0]=transaction_hour
#                    ELSE IF     "transaction_day" in "${parameter_split}[0]"
#                        Set To Dictionary       ${ga_parameters}        ${parameter_split}[0]=transaction_day
#                    ELSE
#                        ${new_value} =     decode_url_encoded_value        ${parameter_split}[1]
#                        Set To Dictionary       ${ga_parameters}        ${parameter_split}[0]=${new_value}
#                    END
#                END
#            END
            FOR         ${param}        IN      @{params_to_capture}
                ${query_string_name}        Set Variable        ${parameter_split}[0]
                IF        """.""" in """${parameter_split}[0]"""
                    ${query_string_name_list}         Split String       ${parameter_split}[0]         .
                    ${query_string_name}        Set Variable        ${query_string_name_list[1]}
                END
                IF    "${param}" == "${query_string_name}"
                    IF    "${param}"!="en"
                        ${new_value} =     decode_url_encoded_value        ${parameter_split}[1]
                        Log         ${new_value}
#                        ${contains} =  Evaluate   "\\r" in """${new_value}"""
#                        IF     ${contains}
#                           ${new_value} =     Replace String     ${new_value}     "\r"        ${EMPTY}
#                        END
                        ${new_value} =     Replace String     ${new_value}     \r        ${EMPTY}
                        Set To Dictionary       ${ga_parameters}        ${parameter_split}[0]=${new_value}
                        Log         ${ga_parameters}
                    END
                END
            END
            ${match}   Run Keyword And Return Status       Should Match Regexp  ${parameter_split}[0]    pr\\d+
            IF   ${match}
                ${new_value} =     decode_url_encoded_value        ${parameter_split}[1]
                Log         ${new_value}
#                ${contains} =  Evaluate   "\\r" in """${new_value}"""
#                IF     ${contains}
#                    ${new_value} =     Replace String     ${new_value}     "\r"        ${EMPTY}
#                END
                ${new_value} =     Replace String     ${new_value}     \r        ${EMPTY}
                Set To Dictionary       ${ga_parameters}        ${parameter_split}[0]=${new_value}
                Log         ${ga_parameters}
            END
        END
    END
    Log         ${ga_parameters}
    [return]    ${ga_parameters}


get_ga_calls_from_composite_request
    [Arguments]	        ${request}=none
    ${ga_parameters} =      Create Dictionary
    ${ga_parameters_lit} =      Create List

    #@{params_to_capture} =      Create List     ep.method       ep.environment      up.customer_type        up.uuid
    #...     ep.store_id     ep.store_name       ep.store_city       epn.store_state     ep.store_country
    #...     up.order_disposition        up.day_part     pr1     pr2     epn.value

    #Log         ${request['request']}
    #Log         ${request['request']['postData']}
    #Log         ${request['request']['postData']['text']}
    ${request_info} =         Set Variable        ${request['request']}
    IF      """${request_info.get("postData")}"""=="""${None}"""
        Return From Keyword     no_post_data
    END
    ${post_data_text} =         Set Variable        ${request['request']['postData']['text']}
    Log         ${post_data_text}
    IF      '''${post_data_text}'''=='''${EMPTY}'''
        Log     EMPTY TEXT
        Return From Keyword     no_post_data
    ELSE
        ${post_data_text_list} =        Split String        ${post_data_text}           \n
        Log         ${post_data_text_list}
        ${cnt} =     Get length          ${post_data_text_list}
        Log         ${cnt}
        #call_random_keyword_which_does_not_exist
    END
    [return]  ${post_data_text_list}


add_new_ga_call_to_dict
    [Arguments]	        ${ga_calls}=none     ${ga_parameters}=none
    ${ga_calls_keys} =      Get Dictionary Keys    ${ga_calls}
    ${ga_parameters_keys} =      Get Dictionary Keys    ${ga_parameters}

    ${request_name} =       Set Variable        no_value
    IF      "en" in @{ga_parameters_keys}
        ${request_name} =       Get From Dictionary     ${ga_parameters}        en
    ELSE
        ${request_name} =       Set Variable        No_Event_Name
    END

    ${count_of_calls} =      SET VARIABLE        ${1}
    FOR     ${ga_calls_key}        IN      @{ga_calls_keys}
        ${new_key} =        Remove String Using Regexp         ${ga_calls_key}      _\\d+
        # ${contains_request_name}      Evaluate        "${request_name}" in """${ga_calls_key}"""
        IF      "${new_key}"=="${request_name}"
            ${count_of_calls} =      EVALUATE        ${count_of_calls} + 1
        END
    END

    ${request_name} =       Set Variable        ${request_name}_${count_of_calls}

    Set To Dictionary       ${ga_calls}        ${request_name}=${ga_parameters}

    [return]  ${ga_calls}

validate_ga_json_file
    [Arguments]        ${ga_info_dict}=none
    @{validation_errors} =         Create List
    ${file_exists} =      Run Keyword and Return Status        File Should Exist      ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
    IF     ${file_exists}
        ${ga_calls_parameters_file} =        Get File            ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}gaCallsParameters.json
        ${ga_calls_parameters_file_json}=        Convert String to JSON          ${ga_calls_parameters_file}

        ${ga_calls_node_from_template} =         Get From Dictionary        ${ga_calls_parameters_file_json}        valid_calls_list
        ${valid_calls_list_from_template} =         Get Dictionary Keys        ${ga_calls_node_from_template}        sort_keys=False

        # below 2 lines needs to be deleted
        # ${ga_calls_current_file} =        Get File            ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_ga_files${/}${ga_info_dict}_current.json
        # ${ga_calls_current_file_json}=        Convert String to JSON          ${ga_calls_current_file}
        # above 2 lines needs to be deleted

        ${ga_calls_node_from_actual} =         Get From Dictionary        ${ga_info_dict}        ga_calls
        # for testing
        #${ga_calls_node_from_actual} =         Get From Dictionary        ${ga_calls_current_file_json}        ga_calls
        ${valid_calls_list_from_actual} =         Get Dictionary Keys        ${ga_calls_node_from_actual}        sort_keys=False

        FOR             ${ga_call_actual}          IN              @{valid_calls_list_from_actual}
            ${new_key} =        Remove String Using Regexp         ${ga_call_actual}      _\\d+
            ${ga_call_node_from_template} =         Get From Dictionary        ${ga_calls_node_from_template}        ${new_key}
            ${ga_call_node_from_actual} =         Get From Dictionary        ${ga_calls_node_from_actual}        ${ga_call_actual}

            ${parameters_list_from_template} =         Get Dictionary Keys        ${ga_call_node_from_template}        sort_keys=True
            ${parameters_list_from_actual} =         Get Dictionary Keys        ${ga_call_node_from_actual}        sort_keys=True

            # Lists Should Be Equal        ${parameters_list_from_template}        ${parameters_list_from_actual}
            FOR         ${parameter_template}        IN         @{parameters_list_from_template}
                ${parameter_template_exists} =         Set Variable        False
                FOR         ${parameter_actual}        IN         @{parameters_list_from_actual}
                    IF         "${parameter_template}"=="en"
                        IF        "${parameter_template}"=="${parameter_actual}"
                            ${parameter_template_exists} =         Set Variable        True

                            # checking for not null
                            #DEBUG
                            ${parameter_template_value} =         Get From Dictionary        ${ga_call_node_from_template}        ${parameter_template}
                            ${parameter_template_value_list} =        Split String        ${parameter_template_value}           ,
                            IF         "not null" in ${parameter_template_value_list} or " not null" in ${parameter_template_value_list}
                                ${parameter_actual_value} =         Get From Dictionary        ${ga_call_node_from_actual}        ${parameter_actual}
                                IF         """${parameter_actual_value}"""=="""${EMPTY}"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF        """${parameter_actual_value}"""=="""null"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF        """${parameter_actual_value}"""=="""NULL"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF        """${parameter_actual_value}"""=="""Null"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF         """${parameter_actual_value}"""=="""${None}"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF         """${parameter_actual_value}"""=="""N/A"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                END
                            ELSE IF         " null" in ${parameter_template_value_list} or "null" in ${parameter_template_value_list}
                                ${parameter_actual_value} =         Get From Dictionary        ${ga_call_node_from_actual}        ${parameter_actual}
#                                IF         """${parameter_actual_value}"""!="""N/A"""
#                                    Append To List        ${validation_errors}        ${ga_call_actual} does not contain null value for the parameter ${parameter_template}
#                                END
                                IF         """${parameter_actual_value}"""=="""N/A"""
                                    Log        "Pass"
                                ELSE IF        """${parameter_actual_value}"""=="""${EMPTY}"""
                                    Log        "Pass"
                                ELSE
                                    Append To List        ${validation_errors}        ${ga_call_actual} does not contain null value for the parameter ${parameter_template}
                                END
                            END

                            Exit For Loop
                        END
                    ELSE
                        IF        "${parameter_template}" in "${parameter_actual}"
                            ${parameter_template_exists} =         Set Variable        True

                            # checking for not null
                            ${parameter_template_value} =         Get From Dictionary        ${ga_call_node_from_template}        ${parameter_template}
                            ${parameter_template_value_list} =        Split String        ${parameter_template_value}           ,
                            IF         "not null" in ${parameter_template_value_list} or " not null" in ${parameter_template_value_list}
                                ${parameter_actual_value} =         Get From Dictionary        ${ga_call_node_from_actual}        ${parameter_actual}
                                IF         """${parameter_actual_value}"""=="""${EMPTY}"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF        """${parameter_actual_value}"""=="""null"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF        """${parameter_actual_value}"""=="""NULL"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF        """${parameter_actual_value}"""=="""Null"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF         """${parameter_actual_value}"""=="""${None}"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                ELSE IF         """${parameter_actual_value}"""=="""N/A"""
                                    Append To List        ${validation_errors}        ${ga_call_actual} contains null value for the parameter ${parameter_template}
                                END
                            ELSE IF         " null" in ${parameter_template_value_list} or "null" in ${parameter_template_value_list}
                                ${parameter_actual_value} =         Get From Dictionary        ${ga_call_node_from_actual}        ${parameter_actual}
#                                IF         """${parameter_actual_value}"""!="""N/A"""
#                                    Append To List        ${validation_errors}        ${ga_call_actual} does not contain null value for the parameter ${parameter_template}
#                                END
                                IF         """${parameter_actual_value}"""=="""N/A"""
                                    Log         Pass
                                ELSE IF        """${parameter_actual_value}"""=="""${EMPTY}"""
                                    Log         Pass
                                ELSE
                                    Append To List        ${validation_errors}        ${ga_call_actual} does not contain null value for the parameter ${parameter_template}
                                END
                            END

                            Exit For Loop
                        END
                    END
                END
                IF     not ${parameter_template_exists}
                    # add in validation errors list
                    Append To List        ${validation_errors}        ${ga_call_actual} does not contain the parameter ${parameter_template}
                END
            END
            
        END

        ${validation_errors_length} =         Get Length        ${validation_errors}
        IF        "${validation_errors_length}"!="0"
            Log         ${validation_errors}
             Fail    Assertion failure: Generated JSON file validation failed with following errors: ${validation_errors}
        END
    END

get_session_id_from_dict
    [Arguments]        ${input_dict}=none
    ${input_dict_keys} =         Get Dictionary Keys        ${input_dict}        sort_keys=False
    FOR    ${key}    IN    @{input_dict}
        ${parameters_of_dict_call} =         Get From Dictionary        ${input_dict}        ${key}
        ${parameters_of_dict_call_keys} =         Get Dictionary Keys        ${parameters_of_dict_call}        sort_keys=True
        FOR        ${parameter}    IN    @{parameters_of_dict_call_keys}
            IF         """session""" in """${parameter}"""
                ${value} =         Get From Dictionary        ${parameters_of_dict_call}        ${parameter}
                RETURN      ${value}
            END
        END
    END
    RETURN      ${EMPTY}


close_current_context
    [Arguments]
    Close Context       CURRENT