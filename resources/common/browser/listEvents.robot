*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
choose_testdata_by_text_from_list_locator
    [Documentation]         Keyword for selecting a value from a list
	[Arguments]	${testdata}=testdata	${locator}=locator      ${dropdown_type}=list       ${match_type}=exact
	${locator}      get argument actual value     ${locator}
	${testdata}      get argument actual value     ${testdata}
	${dropdown_type}        get argument actual value     ${dropdown_type}
	Wait For Elements State       ${locator}         visible
	IF      '${dropdown_type}'=='list' or '${dropdown_type}'=='List'
            ${list} =        Get Elements     ${locator}
            ${selected} =       Set Variable     False
            FOR     ${list_element}    IN      @{list}
                ${element_text} =      Get Text        ${list_element}
                Log         ${element_text}
                Log         ${testdata}
                IF      '${match_type}' == 'exact'
                    Run Keyword If      """${element_text}""" == """${testdata}"""        click_on_element_locator       ${list_element}
                    IF      """${element_text}""" == """${testdata}"""
                        ${selected} =       Set Variable        True
                    END
                    Exit For Loop If    """${element_text}""" == """${testdata}"""
                ELSE
                    Run Keyword If      """${testdata}""" in """${element_text}"""        click_on_element_locator       ${list_element}
                    IF      """${testdata}""" in """${element_text}"""
                        ${selected} =       Set Variable        True
                    END
                    Exit For Loop If    '${testdata}' in '${element_text}'
                END
            END
    ELSE IF     '${dropdown_type}'=='option' or '${dropdown_type}'=='Option'
            ${dd_options} =         Get Select Options      ${locator}
            Log         ${dd_options}
            IF      '${match_type}' == 'exact'
                ${option_selected}=         Run Keyword And Return Status       Select Options By       ${locator}       text       ${testdata}
                IF      ${option_selected}
                        ${selected} =       Set Variable        True
                END
            ELSE
                FOR     ${dd_option}    IN      @{dd_options}
                    ${match}    Run Keyword And Return Status   should contain     ${dd_option}[label]     ${testdata}
                    IF      ${match}
                        ${testdata}     Set Variable        ${dd_option}[label]
                        Exit For Loop
                    END
                END
                ${option_selected}=         Run Keyword And Return Status       Select Options By       ${locator}       text       ${testdata}
                IF      ${option_selected}
                        ${selected} =       Set Variable        True
                END
            END
    END
    Log     ${selected}
    IF      not ${selected}
        Fail    Selection Failure: Unable to select '${testdata}' from list
    END

choose_an_option_by_index_value_from_list_locator
    [Documentation]         keyword to select an element from list based on index
	#[Arguments]	${index_value}=random	${list_locator}=list locator
	[Arguments]	${locator}=locator	${index_value}=value             ${dropdown_type}=list      ${click_method}=javascript
	#Wait Until Element Is Visible       ${${list_locator}}       ${TIMEOUT}
	#verify_locator_is_present       ${locator}
	${locator}      get argument actual value     ${locator}
	${index_value}      get argument actual value     ${index_value}
    ${dropdown_type}     get argument actual value     ${dropdown_type}
	IF      '${dropdown_type}'=='list' or '${dropdown_type}'=='List'
        ${list} =        Get Elements     ${locator}
        ${count} =      Get Length      ${list}
        Log     ${count}
        IF      '${index_value}' == 'random'
            ${index_value} =        Evaluate        random.randint(1, ${count})
        END
        #click locator using javascript      //*[@data-qa-label='FutureDeliveryDatesDdl']
        #Select From List By Index       ${${list_locator}}      3
        #click using javascript     ${list}[${index_value}]
        click_on_element_locator        ${list}[${index_value}]         ${click_method}
    ELSE IF         '${dropdown_type}'=='option' or '${dropdown_type}'=='Option'
            Select Options By       ${locator}       index       ${index_value}
    END


select_option_by_attribute_value_from_multiple_selection_dropdown_locator
    [Documentation]
	[Arguments]	${option}=testdata	${attribute_value}=value	${locator}=locator
	${locator}      get argument actual value     ${locator}
	${attribute_value}      get argument actual value     ${attribute_value}
	${option}      get argument actual value     ${option}
	Log         ${locator}
	Log         ${attribute_value}
	Log         ${option}
    Select Options By       ${locator}       ${attribute_value}       ${option}


