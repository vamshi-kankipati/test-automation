*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
scroll_to_element_during_lazy_loading
    [Documentation]         scroll to element in the case of lazy loading
	[Arguments]	        ${locator}=                 ${xpath_text_optional}=none
	${locator}      get argument actual value     ${locator}
	${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
	IF      '''"''' in '''${xpath_text_optional}'''
	    ${locator} =        Replace String      ${locator}     "      '
	ELSE IF         """'""" in """${xpath_text_optional}"""
	    ${locator} =        Replace String      ${locator}     '      "
	END
	${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
    FOR    ${i}    IN RANGE    35
            wait_for_number_seconds     5
            ${element_present} =        Get Element Count          ${locator}
            IF        ${element_present}>0
                    wait_for_number_seconds	2
                    Scroll To Element          ${locator}
                    Exit For Loop
            ELSE
                Scroll by          ${None}            3%
            END
    END