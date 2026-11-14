*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
#Sleep_for_the_given_time_period
#    [Documentation]         Pause execution for given period of time
#	[Arguments]	${time_period}=
#	${time_period}      get argument actual value     ${time_period}
#	Sleep      ${time_period}


wait_until_locator_does_not_contain_exact_text_value
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none             ${locator}=locator                 ${value}=value           ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}     get argument actual value       ${locator}
        ${value}     get argument actual value       ${value}
        Wait Until Keyword Succeeds         1 min       1 sec       get_element_text_and_compare_value      ${locator}      ${value}        not equal
    END


wait_until_page_loads
    [Documentation]     Let's the page load by waiting until the network is idle
    [Arguments]         ${platform_specific_test_step}=none         ${mobile_locator}=None          ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        #Wait Until Keyword Succeeds     1 min    1 sec        Wait Until Network Is Idle
        Run Keyword And Warn On Failure        Wait Until Network Is Idle           timeout=${timeout}
    END

#Need to revisit
wait_for_element_state
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none         ${locator}=locator            ${state}=state          ${xpath_text_optional}=none         ${timeout}=50s        ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}     get argument actual value       ${locator}
        ${state}     get argument actual value       ${state}
        ${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
        IF      '''"''' in '''${xpath_text_optional}'''
            ${locator} =        Replace String      ${locator}     "      '
        ELSE IF         """'""" in """${xpath_text_optional}"""
            ${locator} =        Replace String      ${locator}     '      "
        END
        ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
        Wait For Elements State       ${locator}         ${state}           ${timeout}
    END


wait_for_number_seconds
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none     ${number}=20           ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${number}     get argument actual value       ${number}
        Sleep       ${number}s
    END