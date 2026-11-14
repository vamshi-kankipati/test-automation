*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
click_on_element_locator
    [Documentation]         Keyword to click on an element
    [Arguments]     ${locator}=locator      ${click_method}=default
    ${locator}      get argument actual value     ${locator}
    IF      '${click_method}' == 'default'
        click_on_element_locator_default        ${locator}
    ELSE IF     '${click_method}' == 'javascript'
        click using javascript      ${locator}
    END

click_on_element_locator_default
    [Documentation]         Keyword to click an element using locator
	[Arguments]	${locator}=locator
    #${locator}      get argument actual value     ${locator}
    Click       ${locator}


click using javascript
    [Documentation]         Keyword to click using JavaScript
    [Arguments]         ${locator}=locator
    Evaluate JavaScript      ${locator}     (elem) => elem.click()

click_on_element_locator_if_visible
    [Documentation]         Keyword to click an element if locator is visible in native view
	[Arguments] 	${locator}=locator      ${click_method}=default        ${wait_time_seconds}=10
    ${locator}      get argument actual value     ${locator}
    ${click_method}      get argument actual value     ${click_method}
    FOR    ${index}  IN RANGE  ${wait_time_seconds}
        ${exists}=    Run Keyword And Return Status    Element Should Be Present    ${locator}
        ${states} =         Get Element States      ${locator}
        IF      'visible' in ${states} or ${exists}
            click_on_element_locator    ${locator}    ${click_method}
            Exit For Loop
        END
        Sleep         1s
    END

click_on_element_locator_with_text_value
	[Documentation]         keyword to click on an element based on text
	[Arguments]	${locator}=locator	${text}=text        ${click_method}=default
	${locator}      get argument actual value     ${locator}
	${text}      get argument actual value     ${text}
	IF      '''"''' in '''${text}'''
	    ${locator} =        Replace String      ${locator}     "      '
	ELSE IF         """'""" in """${text}"""
	    ${locator} =        Replace String      ${locator}     '      "
	END
	${locator} =        Replace String      ${locator}     %s      ${text}
    IF      '${click_method}' == 'default'
        click_on_element_locator_default        ${locator}
    ELSE IF     '${click_method}' == 'javascript'
        click using javascript      ${locator}
    END


# Handle Browser alerts
click_on_element_locator_and_accept_decline_the_application_alert
    [Documentation]
	[Arguments]	${locator}=locator	        ${accept_decline}=ALERT_ACCEPT      ${xpath_text_optional}=none
	${locator}     get argument actual value       ${locator}
	${accept_decline}      get argument actual value     ${accept_decline}
	${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
	IF      '''"''' in '''${xpath_text_optional}'''
	    ${locator} =        Replace String      ${locator}     "      '
	ELSE IF         """'""" in """${xpath_text_optional}"""
	    ${locator} =        Replace String      ${locator}     '      "
	END
    ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
    ${promise} =         Promise To         Wait For Alert          action=${accept_decline}
	And click_on_element_locator	${locator}
	${text} =            Wait For      ${promise}
	log         ${text}

press_keys_on_the_keyboard
    [Documentation]
	[Arguments]	${locator}=locator	        ${keys_to_press}=key
	${locator}     get argument actual value       ${locator}
	${keys_to_press}     get argument actual value       ${keys_to_press}
	Press Keys          ${locator}          ${keys_to_press}

# this method is created because it existed in mobile.
click_on_element_locator_until_element_becomes_invisible
    [Documentation]         Keyword to click an element using locator if the element is still visible
	[Arguments]	${locator}=locator	     ${click_method}=default
	${locator}      get argument actual value     ${locator}
	${click_method}      get argument actual value     ${click_method}
    FOR    ${index}    IN RANGE    4
        ${states} =         Get Element States      ${locator}
        IF      'visible' in ${states}
            click_on_element_locator	${locator}      ${click_method}
        END
    END
