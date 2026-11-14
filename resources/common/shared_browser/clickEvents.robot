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
	[Arguments]	${platform_specific_test_step}=none	    ${locator}=locator	    ${web_click_method}=default	    ${mobile_click_method}=default	    ${mobile_os_specific_test_step}=none	${mobile_x_coordinates}=none	${mobile_y_coordinates}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}      get argument actual value     ${locator}
        ${web_click_method}     get argument actual value       ${web_click_method}
        IF      '${web_click_method}' == 'default'
            click_on_element_locator_default        ${locator}
        ELSE IF     '${web_click_method}' == 'javascript'
            click_using_javascript      ${locator}
        END
    END

click_on_element_locator_default
    [Documentation]         Keyword to click an element using locator
	[Arguments]	${locator}=locator
    #${locator}      get argument actual value     ${locator}
    Click       ${locator}


click_using_javascript
    [Documentation]         Keyword to click using JavaScript
    [Arguments]         ${locator}=locator
    Evaluate JavaScript      ${locator}     (elem) => elem.click()

click_on_element_locator_if_visible
    [Documentation]         Keyword to click an element if locator is visible in native view
	[Arguments]     ${platform_specific_test_step}=none 	${locator}=locator      ${web_click_method}=default     ${mobile_click_method}=default      ${mobile_os_specific_test_step}=none       ${mobile_x_coordinates}=none	    ${mobile_y_coordinates}=none
	IF        "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
	    ${locator}      get argument actual value     ${locator}
        ${web_click_method}      get argument actual value     ${web_click_method}
        ${states} =         Get Element States      ${locator}
        IF      'visible' in ${states}
            click_on_element_locator    ${platform_specific_test_step}    ${locator}    ${web_click_method}     ${mobile_click_method}	    ${mobile_os_specific_test_step}         ${mobile_x_coordinates}	    ${mobile_y_coordinates}
        END
    END

click_on_element_locator_with_text_value
	[Documentation]         keyword to click on an element based on text
	[Arguments]	    ${platform_specific_test_step}=none     ${locator}=locator	    ${text}=text        ${web_click_method}=default     ${mobile_click_method}=default      ${mobile_os_specific_test_step}=none       ${mobile_x_coordinates}=none	    ${mobile_y_coordinates}=none
	IF        "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}      get argument actual value     ${locator}
        ${text}      get argument actual value     ${text}
        IF      '''"''' in '''${text}'''
            ${locator} =        Replace String      ${locator}     "      '
        ELSE IF         """'""" in """${text}"""
            ${locator} =        Replace String      ${locator}     '      "
        END
        ${locator} =        Replace String      ${locator}     %s      ${text}
        click_on_element_locator    ${platform_specific_test_step}    ${locator}    ${web_click_method}     ${mobile_click_method}	    ${mobile_os_specific_test_step}         ${mobile_x_coordinates}	    ${mobile_y_coordinates}
    END


# Handle Browser alerts
web__click_on_element_locator_and_accept_decline_the_application_alert
    [Documentation]
	[Arguments]	    ${platform_specific_test_step}=none     ${locator}=locator	        ${accept_decline}=ALERT_ACCEPT      ${xpath_text_optional}=none     ${web_click_method}=default
	IF        "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
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
        And click_on_element_locator	${platform_specific_test_step}    ${locator}    ${web_click_method}
        ${text} =            Wait For      ${promise}
        log         ${text}
    END

web_android_press_keys_on_the_keyboard
    [Documentation]
	[Arguments]     ${platform_specific_test_step}=none 	${web_locator}=locator	        ${keys_to_press}=key        ${mobile_os_specific_test_step}=none
	IF        "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
	    ${web_locator}     get argument actual value       ${web_locator}
	    ${keys_to_press}     get argument actual value       ${keys_to_press}
	    Press Keys          ${web_locator}          ${keys_to_press}
    END

click_on_element_locator_until_element_becomes_invisible
    [Documentation]         Keyword to click an element using locator if the element is still visible
	[Arguments]     ${platform_specific_test_step}=none 	${locator}=locator	     ${web_click_method}=default        ${mobile_click_method}=default        ${mobile_os_specific_test_step}=none      ${mobile_x_coordinates}=none	${mobile_y_coordinates}=none
	IF        "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
	    ${locator}      get argument actual value     ${locator}
	    ${click_method}      get argument actual value     ${click_method}
        FOR    ${index}    IN RANGE    5
           ${exists}=    Run Keyword And Return Status    Element Should Be Present    ${locator}
            ${states} =         Get Element States      ${locator}
            IF      'visible' in ${states} or ${exists}
                click_on_element_locator    ${platform_specific_test_step}  	${locator}      ${web_click_method}     ${mobile_click_method}     ${mobile_os_specific_test_step}      ${mobile_x_coordinates} 	${mobile_y_coordinates}
                Exit For Loop
            END
            Sleep    1s
        END
    END
