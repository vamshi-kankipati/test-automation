*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
get argument actual value
    [Documentation]         Keyword that checks whether a variable or raw value is passed as an argument
    [Arguments]	    ${data}
	${result}       GetVariableValue    ${${data}}
    IF      '''${result}'''!="None"
        ${data}      SETVARIABLE     ${${data}}
    ELSE
        ${OS_Specific_Variable}=    Catenate    SEPARATOR=_   ${data}      ${global_temp_OS}
        ${result}       GetVariableValue    ${${OS_Specific_Variable}}
        IF      """${result}"""!="None"
            ${data}      SETVARIABLE     ${${OS_Specific_Variable}}
        END
    END
    ${is_i18_key}       Evaluate        "_i18" in """${data}"""
    ${type}=    Evaluate     type($data).__name__
    IF  ${is_i18_key} and "${type}"!="list"
          ${contains_single_quote}      Evaluate        "'" in """${data}"""
          IF    ${contains_single_quote}
                ${split_by_char}        Set Variable        '
          ELSE
                ${split_by_char}        Set Variable        "
          END
          ${locators_list}         Split String       ${data}         ${split_by_char}
          FOR             ${items_in_list}       IN           @{locators_list}
          ${is_i18}       Evaluate        "_i18" in """${items_in_list}"""
              IF      ${is_i18}
                    ${i18_key}      Remove String        ${items_in_list}       _i18
                    ${i18_value_in_list}         Get Value From Json           ${global_json_object}       $.."${i18_key}"
                    ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${i18_value_in_list}
                    IF         ${isEmpty}
                        ${i18_value_in_list}         Get Value From Json           ${global_json_object}       $..${i18_key}
                    END
                    ${i18_value}        Get From List             ${i18_value_in_list}         0
                    ${data}                 REPLACE STRING        ${data}        ${items_in_list}        ${i18_value}
              END
          END
    END
    [return]         ${data}

get_states_for_element_with_locator
    [Documentation]
    [Arguments]     ${locator}
    ${locator}     get argument actual value       ${locator}
    ${states}=      Get Element States      ${locator}
    [Return]   ${states}

get_editable_non_editable_value_from_the_locator_and_save_it_in_a_variable_for_comparison
    [Documentation]    Keyword that gets the value from the application and stores in a variable
	[Arguments]	    ${platform_specific_test_step}=none     ${editable_non_editable}=Editable/NonEditable	${locator}=locator	${variable}=variable    ${ignore_specific_text_optional}=none       ${xpath_text_optional}=none     ${mobile_os_specific_test_step}=none
	IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}      get argument actual value      ${locator}
        ${editable_non_editable}    get argument actual value    ${editable_non_editable}
        ${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
        IF      '''"''' in '''${xpath_text_optional}'''
            ${locator} =        Replace String      ${locator}     "      '
        ELSE IF         """'""" in """${xpath_text_optional}"""
            ${locator} =        Replace String      ${locator}     '      "
        END
        ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
        Log         ${locator}
        IF      "${editable_non_editable}"=="Editable"
            ${Temp}      Get Property      ${locator}        value
        ELSE IF     "${editable_non_editable}"=="NonEditable"
            ${Temp}        Get Text        ${locator}
        END
        IF      "${ignore_specific_text_optional}"!="none"
            ${ignore_specific_text_optional}      get argument actual value      ${ignore_specific_text_optional}
            ${Temp} =           Remove String      ${Temp}          ${ignore_specific_text_optional}
            ${Temp} =       Strip String          ${SPACE}${Temp}${SPACE}
        END
        Set Test Variable    ${${variable}}     ${Temp}
    END


get_element_text_and_compare_value
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none     ${locator}=         ${value}=       ${match_type}=          ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${text} =       Get Text        ${locator}
        ${return_value} =       Set Variable     False
        IF      '${match_type}'=='not equal'
            IF      '${text}'=='${value}'
                ${return_value} =       Set Variable     False
            Else
                ${return_value} =       Set Variable     True
            END
        END
        [Return]        ${return_value}
    END

web_get_matching_text_from_url_and_save_it_in_a_variable
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none         ${pattern}=none     ${variable}=variable
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${pattern}      get argument actual value      ${pattern}
        Log to console        ${pattern}
        ${url} =        Get URL
        #${url} =        Set Variable        https://www-a-qa-br-us.tillster.com/confirm?orderId=27790
        ${extracted_value} =        Get Regexp Matches      ${url}      ${pattern}      1
        log          ${extracted_value}[0]
        Set global variable    ${${variable}}     ${extracted_value}[0]
    END