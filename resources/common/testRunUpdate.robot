*** Settings ***
Documentation

*** Variables ***
${access-token}=        b-wbGptET4JYIuWzyV69jg
${client}=      iM64VMT8A0J0ebSq3FJCPg
${uid}=     srajendran@tillster.com
${x-csrf-token}=        YST1MpZm2ZMSUb5L4pA842K9AnEF5oeLwsWBUBCHOxN077lOcRML89vyWsB0DXTIfk0KRr7s/BGNAN9WpN66gw==

*** Keywords ***
reset_test_run_results_cs
    [Documentation]         keyword to reset the test results from previous build before updating the results from the current build
    [Arguments]
    #Reset test results before executing automation
    ${header}=        Create Dictionary     Content-Type=application/json; charset=utf-8
    ...         Accept=application/vnd.api+json; version=1
    ...         Accept-Encoding=gzip, deflate, br
    ...         x-csrf-token=${x-csrf-token}
    ...         Cookie=_ga=GA1.1.790119628.1742277948; hui=eyJfcmFpbHMiOnsibWVzc2FnZSI6Iklqa3lOakExSWc9PSIsImV4cCI6bnVsbCwicHVyIjoiY29va2llLmh1aSJ9fQ%3D%3D--bfd1ebe7d06b4d1cc79d79a0627f262fddef1aaa; user_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6Ik9USTJNRFU9IiwiZXhwIjpudWxsLCJwdXIiOiJjb29raWUudXNlcl9pZCJ9fQ%3D%3D--10bc16562430def1337c002ea2f1f2ef60be559d; _ga_E1081Q014T=GS1.1.1742277970.1.1.1742278467.0.0.0; _ga_Q17C4B81S5=GS1.1.1742277948.1.1.1742280743.0.0.0; _app_session=e9BJhG6%2BxcP9048QKoc1oPVwM0n4fJZLd3qoLhGlbqRrpoiSC1Lz4EdbxfAnxxTk3s0u8MpguMSLIS8xtfmYO5Rc8WqIyfN7RahSdxzXJQsk8gCjOhQiUnNrOIrf2%2F8HiE5gFSeiXmqY%2FYPut8KiWhgA9O1%2BXq55ok3716iguv9wxuNii1M5UQqeCoMo79qCxYgR%2BD%2BTwkXXIxq6o3ukRlJWCTInm3Ws6zsa5jX4JQw6YA2iYzyWy5nyN9hkjzGLX9BLLQwUvf3MyHbuUuhXLMno02RV9g%2FUHJl1nyRWhYhZCuRObobEfrVGgzH07ht4xe2kh32UvvoOdhGho9tCraii6CeAH0yZEAXEBqltP5a5rAaRnxb0nKDrC%2FIk%2FYV7pl8QDb6vo5qGudjn--Cs%2BoXqZDt0vSm8QP--jICocn%2F2YJbdDMZdBlugxQ%3D%3D

    ${response} =       Wait Until Keyword Succeeds     10 sec      1 sec   GET        https://studio.cucumberstudio.com/test_runs/${test_run_id}                    headers=${header}
    Should Be Equal As Numbers        200      ${response.status_code}
    ${uid}=     SET VARIABLE            ${response.json()}[test_run][uid]
    ${project_id}=      SET VARIABLE            ${response.json()}[test_run][project_id]
    ${first_execution_environment_id}=      SET VARIABLE            ${response.json()}[test_run][first_execution_environment_id]
#    Log to Console      ${response.json()}
#    Log to console          ${uid} - ${project_id} - ${first_execution_environment_id}

    @{list} =	Create List	        resetAllTests       ${uid}      ${first_execution_environment_id}
#    Log to Console          ${list}

    &{body}=        Create Dictionary        script_elements=${list}
#    Log to Console         ${body}

    ${reset_response} =       Wait Until Keyword Succeeds     5 sec      1 sec   POST        https://studio.cucumberstudio.com/projects/${project_id}/timeline                headers=${header}          json=${body}
    Should Be Equal As Numbers        200      ${reset_response.status_code}
#    Log to Console          ${reset_response.json()}
    Set global variable    ${reset_test_run_result}         NA

reset_test_run_results
    [Documentation]         keyword to reset the test results from previous build before updating the results from the current build
    [Arguments]
    #Reset test results before executing automation
    ${header}=        Create Dictionary     Content-Type=application/json; charset=utf-8
    ...         Accept=application/vnd.api+json; version=1
    ...         Accept-Encoding=gzip, deflate, br
    ...         x-csrf-token=${x-csrf-token}
    ...         Cookie=_ga=GA1.1.790119628.1742277948; hui=eyJfcmFpbHMiOnsibWVzc2FnZSI6Iklqa3lOakExSWc9PSIsImV4cCI6bnVsbCwicHVyIjoiY29va2llLmh1aSJ9fQ%3D%3D--bfd1ebe7d06b4d1cc79d79a0627f262fddef1aaa; user_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6Ik9USTJNRFU9IiwiZXhwIjpudWxsLCJwdXIiOiJjb29raWUudXNlcl9pZCJ9fQ%3D%3D--10bc16562430def1337c002ea2f1f2ef60be559d; _ga_E1081Q014T=GS1.1.1742277970.1.1.1742278467.0.0.0; _ga_Q17C4B81S5=GS1.1.1742277948.1.1.1742280743.0.0.0; _app_session=e9BJhG6%2BxcP9048QKoc1oPVwM0n4fJZLd3qoLhGlbqRrpoiSC1Lz4EdbxfAnxxTk3s0u8MpguMSLIS8xtfmYO5Rc8WqIyfN7RahSdxzXJQsk8gCjOhQiUnNrOIrf2%2F8HiE5gFSeiXmqY%2FYPut8KiWhgA9O1%2BXq55ok3716iguv9wxuNii1M5UQqeCoMo79qCxYgR%2BD%2BTwkXXIxq6o3ukRlJWCTInm3Ws6zsa5jX4JQw6YA2iYzyWy5nyN9hkjzGLX9BLLQwUvf3MyHbuUuhXLMno02RV9g%2FUHJl1nyRWhYhZCuRObobEfrVGgzH07ht4xe2kh32UvvoOdhGho9tCraii6CeAH0yZEAXEBqltP5a5rAaRnxb0nKDrC%2FIk%2FYV7pl8QDb6vo5qGudjn--Cs%2BoXqZDt0vSm8QP--jICocn%2F2YJbdDMZdBlugxQ%3D%3D


    #${reset_response} =       Wait Until Keyword Succeeds     5 sec      1 sec   POST        https://studio.cucumberstudio.com/projects/${project_id}/timeline                headers=${header}          json=${body}
    ${reset_response} =       Wait Until Keyword Succeeds     5 sec      1 sec   POST        https://praxis.tillster.com/api/projects/${project_id}/test_runs/${test_run_id}/reset
    Should Be Equal As Numbers        200      ${reset_response.status_code}
#    Log to Console          ${reset_response.json()}
    Set global variable    ${reset_test_run_result}         NA



get_tests_from_test_run_CS
    [Documentation]         keywordto get all the tests of a test run
    [Arguments]
    # CS API Token valid till 23-May-2025
    ${header}=      Create Dictionary       Content-Type=application/json; charset=utf-8
    ...         Accept=application/vnd.api+json; version=1
    ...         access-token=${access-token}
    ...         client=${client}
    ...         uid=${uid}

    ${response} =       Wait Until Keyword Succeeds     10 sec      1 sec   GET        https://studio.cucumberstudio.com/api/projects/${project_id}/test_runs/${test_run_id}/test_snapshots     headers=${header}
    Should Be Equal As Numbers        200      ${response.status_code}
    ${temp_test_id_mappings} =        get_test_id_mappings        ${response.json()}
    Log         ${temp_test_id_mappings}
    Set global variable    ${test_id_mappings}       ${temp_test_id_mappings}

get_tests_from_test_run
    [Documentation]         keywordto get all the tests of a test run
    [Arguments]
    # CS API Token valid till 23-May-2025
    ${header}=      Create Dictionary       Content-Type=application/json; charset=utf-8
    ...         Accept=application/vnd.api+json; version=1
    ...         access-token=${access-token}
    ...         client=${client}
    ...         uid=${uid}

    ${response} =       Wait Until Keyword Succeeds     10 sec      1 sec   GET        https://praxis.tillster.com/api/projects/${project_id}/test_runs/${test_run_id}/test_snapshots     headers=${header}
    Should Be Equal As Numbers        200      ${response.status_code}
    ${temp_test_id_mappings} =        get_test_id_mappings        ${response.json()}
    Log         ${temp_test_id_mappings}
    Set global variable    ${test_id_mappings}       ${temp_test_id_mappings}

update_test_status_cs
    [Documentation]         keyword to update test result
    [Arguments]
    Log         ${TEST STATUS}
    Log         ${TEST MESSAGE}
    Log         ${TEST NAME}
    Log to console      Test Details --- ${TEST NAME} --- ${TEST STATUS}
    ${split_name}       Split String        ${TEST NAME}        (uid:
    Log         ${split_name}
    ${test_snapshot_id} =       Set Variable        ${split_name}[1]
    ${test_snapshot_id} =       Replace String      ${test_snapshot_id}     )       ${EMPTY}
    Log         ${split_name}

    ${result} =         GetVariableValue    ${test_id_mappings}
    IF      '''${result}'''!="None"
        ${test_snapshot_id} =       Set Variable        ${test_id_mappings}[${split_name}[0]]
        # CS API Token valid till 23-May-2025
        ${header}=      Create Dictionary       Content-Type=application/json; charset=utf-8
        ...         Accept=application/vnd.api+json; version=1
        ...         access-token=${access-token}
        ...         client=${client}
        ...         uid=${uid}

        ${test_result} =        get_test_result
        ${test_attributes} =        Create Dictionary       status=${test_result}       status-author=TestAutomation        description=${TEST MESSAGE}
        ${test_data} =      Create Dictionary       type=test-results       attributes=${test_attributes}
        ${body} =       Create Dictionary       data=${test_data}
        ${response} =       Wait Until Keyword Succeeds     10 sec      1 sec   POST        https://studio.cucumberstudio.com/api/projects/${project_id}/test_runs/${test_run_id}/test_snapshots/${test_snapshot_id}/test_results     json=${body}       headers=${header}

        Should Be Equal As Numbers        201      ${response.status_code}
        ${result_id} =      Set Variable        ${response.json()}[data][id]

        # upload screenshot
        IF     '''${TEST STATUS}''' == '''FAIL'''
            ${screenshot_file} =        take_screenshot_for_failed_tests_to_attach_in_cs
            #${file} =    Get File For Streaming Upload      ${screenshot_file}
            # CS API Token valid till 23-May-2025
            ${header2}=      Create Dictionary       Accept=application/vnd.api+json; version=1
            ...         access-token=${access-token}
            ...         client=${client}
            ...         uid=${uid}

            # ${failure_screenshot} is taken in the close_session method
            attach_screenshot_in_cs     https://studio.cucumberstudio.com/api/projects/${project_id}/test_runs/${test_run_id}/test_snapshots/${test_snapshot_id}/test_results/${result_id}/attachments     ${header2}      ${screenshot_file}
            Remove File         ${screenshot_file}
        END
    END

update_test_status
    [Documentation]         keyword to update test result
    [Arguments]
    Log         ${TEST STATUS}
    Log         ${TEST MESSAGE}
    Log         ${TEST NAME}
    Log to console      Test Details --- ${TEST NAME} --- ${TEST STATUS}
    ${split_name}       Split String        ${TEST NAME}        (uid:
    Log         ${split_name}
    ${test_snapshot_id} =       Set Variable        ${split_name}[1]
    ${test_snapshot_id} =       Replace String      ${test_snapshot_id}     )       ${EMPTY}
    Log         ${split_name}

    ${result} =         GetVariableValue    ${test_id_mappings}
    IF      '''${result}'''!="None"
        ${test_snapshot_id} =       Set Variable        ${test_id_mappings}[${split_name}[0]]
        # CS API Token valid till 23-May-2025
        ${header}=      Create Dictionary       Content-Type=application/json; charset=utf-8
        ...         Accept=application/vnd.api+json; version=1
        ...         access-token=${access-token}
        ...         client=${client}
        ...         uid=${uid}

        ${test_result} =        get_test_result
        ${test_attributes} =        Create Dictionary       status=${test_result}       status-author=TestAutomation        description=${TEST MESSAGE}
        ${test_data} =      Create Dictionary       type=test-results       attributes=${test_attributes}
        ${body} =       Create Dictionary       data=${test_data}
        ${response} =       Wait Until Keyword Succeeds     10 sec      1 sec   POST        https://praxis.tillster.com/api/projects/${project_id}/test_runs/${test_run_id}/test_snapshots/${test_snapshot_id}/test_results     json=${body}       headers=${header}

        Should Be Equal As Numbers        201      ${response.status_code}
        ${result_id} =      Set Variable        ${response.json()}[data][id]

        # upload screenshot
        IF     '''${TEST STATUS}''' == '''FAIL'''
            ${screenshot_file} =        take_screenshot_for_failed_tests_to_attach_in_cs
            #${file} =    Get File For Streaming Upload      ${screenshot_file}
            # CS API Token valid till 23-May-2025
            ${header2}=      Create Dictionary       Accept=application/vnd.api+json; version=1
            ...         access-token=${access-token}
            ...         client=${client}
            ...         uid=${uid}

            # ${failure_screenshot} is taken in the close_session method
            ${attach_response_code}        ${attach_response} =         attach_screenshot_in_cs     https://praxis.tillster.com/api/projects/${project_id}/test_runs/${test_run_id}/test_snapshots/${test_snapshot_id}/test_results/${result_id}/attachments     ${header2}      ${screenshot_file}
            Log         ${attach_response}
            Log         ${attach_response_code}
            Remove File         ${screenshot_file}
        END
    END

get_test_result
    [Documentation]         keyword to get test result
    [Arguments]
    ${test_result} =        Set Variable        null
    IF      '''${TEST STATUS}''' == '''PASS'''
        ${test_result} =        Set Variable        passed
    ELSE IF     '''${TEST STATUS}''' == '''FAIL'''
        ${test_result} =        Set Variable        failed
    ELSE IF     '''${TEST STATUS}''' == '''SKIP'''
        ${test_result} =        Set Variable        skipped
    END
    [Return]   ${test_result}

update_test_run_description
    [Arguments]
    # CS API Token valid till 23-May-2025
    ${header}=      Create Dictionary       Content-Type=application/json; charset=utf-8
    ...         Accept=application/vnd.api+json; version=1
    ...         access-token=${access-token}
    ...         client=${client}
    ...         uid=${uid}

    ${attributes} =        Create Dictionary       description=${test_run_description}
    ${data_fields} =         Create Dictionary      type=test_runs      id=${test_run_id}       attributes=${attributes}
    ${body} =       Create Dictionary       data=${data_fields}
    ${response} =       Wait Until Keyword Succeeds     10 sec      1 sec   PATCH        https://studio.cucumberstudio.com/api/projects/${project_id}/test_runs/${test_run_id}     json=${body}       headers=${header}
    Should Be Equal As Numbers        200      ${response.status_code}

# below method needs to be deleted
attach_screenshot_for_failed_test
    [Documentation]         Keyword to attach screenshot for failed test case
    [Arguments]
    ${path}=       SET VARIABLE      ${EXECDIR}/results
    ${random_int}=      Get Time    epoch
    Take screenshot            filename=${path}/screenshot_${random_int}.png

    # CS API Token valid till 23-May-2025
    ${header}=      Create Dictionary       Content-Type=application/json; charset=utf-8
    ...         Accept=application/vnd.api+json; version=1
    ...         access-token=${access-token}
    ...         client=${client}
    ...         uid=${uid}

    ${split_name}       Split String        ${TEST NAME}        (uid:
    ${test_snapshot_id} =       Set Variable        ${test_id_mappings}[${split_name}[0]]

    ${response} =       Wait Until Keyword Succeeds     10 sec      1 sec   POST        https://studio.cucumberstudio.com/api/projects/${project_id}/test_runs/${test_run_id}/test_snapshots/${test_snapshot_id}/test_results




