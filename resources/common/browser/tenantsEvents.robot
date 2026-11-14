*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
# Below method is created for BR for MFA
sign_in_with_or_without_mfa
    [Documentation]
	[Arguments]	${emailaddress_locator}=LOGIN_EMAILADDRESS_TEXTBOX      ${emailaddress}=EMAILADDRESS_DEFAULT_VALUE	${password_locator}=LOGIN_PASSWORD_TEXTBOX      ${password}=PASSWORD_DEFAULT_VALUE
	${LOGIN_SECURITYCODE_TEXTBOX}      get argument actual value     ${LOGIN_SECURITYCODE_TEXTBOX}
	${LOGIN_SECURITYCODE_DEFAULT_VALUE}      get argument actual value     ${LOGIN_SECURITYCODE_DEFAULT_VALUE}
	#${emailaddress}      get argument actual value     ${emailaddress}
	#${password}      get argument actual value     ${password}
	Given enter_testdata_in_locator_field	${emailaddress}	LOGIN_EMAILADDRESS_TEXTBOX
	And enter_testdata_in_locator_field	${password}	LOGIN_PASSWORD_TEXTBOX
	And click_on_element_locator	LOGIN_SIGNIN_BUTTON
	wait_until_page_loads
	Sleep       2s
	${send_code_states}=        get_states_for_element_with_locator     LOGIN_SENDCODE_BUTTON
	IF      'visible' in ${send_code_states}
	    click_on_element_locator	LOGIN_SENDCODE_BUTTON
	    wait_until_page_loads
	    ${elements}=    Get Elements    ${LOGIN_SECURITYCODE_TEXTBOX}
        ${securitycode_iterator}=    SET VARIABLE         0

        FOR    ${LOGIN_SECURITYCODE_TEXTBOX_element}       IN      @{elements}
           Type Text	    ${LOGIN_SECURITYCODE_TEXTBOX_element}         ${LOGIN_SECURITYCODE_DEFAULT_VALUE}[${securitycode_iterator}]
           ${securitycode_iterator}=    Evaluate    ${securitycode_iterator} + 1
        END
	    click_on_element_locator	LOGIN_CONFIRMCODE_BUTTON
    END


# Below method is created for BR for MFA
enter_mfa_code_and_submit_the_code_brusw
    [Documentation]
	[Arguments]	${security_code_elements}=locators        ${security_code_value}=testdata        ${mandatory_field}=true         ${send_code_button}=locator
	${security_code_elements}      get argument actual value     ${security_code_elements}
    ${security_code_value}      get argument actual value     ${security_code_value}
	${send_code_button}      get argument actual value     ${send_code_button}

    #${confirm_code_visibility_status}=          SET VARIABLE        false
    ${confirm_code_visibility_status}=          Create List         Default
    Sleep   5s
    IF      '${mandatory_field}'=='false'
        ${confirm_code_visibility_status}=        get_states_for_element_with_locator      ${send_code_button}
    END

    IF            'visible' in ${confirm_code_visibility_status} or '${mandatory_field}'=='true'
	    wait_until_page_loads
	    click_on_element_locator	${send_code_button}
	    ${elements}=    Get Elements    ${security_code_elements}
        ${securitycode_iterator}=    SET VARIABLE         0
            FOR    ${security_code_element}       IN      @{elements}
                   Type Text	    ${security_code_element}         ${security_code_value}[${securitycode_iterator}]
                   ${securitycode_iterator}=    Evaluate    ${securitycode_iterator} + 1
            END
            click_on_element_locator	MFA_CONFIRM_BUTTON
    END

