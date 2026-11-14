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
    END
    #${is_i18_key}       Evaluate        "_i18" in """${data}"""
    ${is_i18_key} =     Run Keyword And Return Status    Should Contain    ${data}    _i18
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
	[Arguments]	${editable_non_editable}=Editable/NonEditable	${locator}=locator	${variable}=variable    ${ignore_specific_text_optional}=none       ${xpath_text_optional}=none
	${locator}      get argument actual value      ${locator}
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



get_element_text_and_compare_value
    [Documentation]
    [Arguments]     ${locator}=         ${value}=       ${match_type}=
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

get_matching_text_from_url_and_save_it_in_a_variable
    [Documentation]
    [Arguments]     ${pattern}=none     ${variable}=variable
    ${pattern}      get argument actual value      ${pattern}
    Log to console        ${pattern}
    ${url} =        Get URL
    #${url} =        Set Variable        https://www-a-qa-br-us.tillster.com/confirm?orderId=27790
    ${extracted_value} =        Get Regexp Matches      ${url}      ${pattern}      1
    log          ${extracted_value}[0]
    Set global variable    ${${variable}}     ${extracted_value}[0]

get_visible_element_count_for_locator
    [Documentation]
    [Arguments]     ${locator}=locator      ${variable}=not_specified
    ${locator}      get argument actual value      ${locator}
    ${element_count} =      Set Variable        0
    ${elements} =       Get Elements        ${locator}
    IF      '''${variable}'''=='''not_specified'''
        ${element_count}       GetVariableValue    ${RECOMMENDED_ITEMS_COUNT}
        IF      '''${element_count}'''=="None"
            ${element_count} =      Set Variable        0
        END
    ELSE
        ${element_count}       GetVariableValue    ${{variable}}
        IF      '''${element_count}'''=="None"
            ${element_count} =      Set Variable        0
        END
    END

    ${list_elements_count} =      Get Length      ${elements}

    # below line of code calculates the total elements without considering the hidden items
    #${element_count} =      Evaluate        ${element_count}+${list_elements_count}

    # below code is for removing the hidden elements. however the GA calls are sent for the hidden items also
    FOR             ${element}       IN           @{elements}
        ${states} =         Get Element States      ${element}
	    #Debug
	    ${present} =    Set Variable        False
	    IF      'visible' in ${states}
            ${present} =        Set Variable    True
            ${element_count} =      Evaluate        ${element_count}+1
	    END
    END
    # above code is for removing the hidden elements. however the GA calls are sent for the hidden items also


    IF      '''${variable}'''=='''not_specified'''
        Set Test Variable       ${RECOMMENDED_ITEMS_COUNT}     ${element_count}
    ELSE
        Set Test Variable       ${{variable}}     ${element_count}
    END