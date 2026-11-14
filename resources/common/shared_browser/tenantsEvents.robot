*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
# Below method is created for BR for MFA
# commented the below method as it was not being used
sign_in_with_or_without_mfa
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none    ${emailaddress}=EMAILADDRESS_DEFAULT_VALUE
    ...             ${password}=PASSWORD_DEFAULT_VALUE    ${login_securitycode_textbox}=LOGIN_SECURITYCODE_TEXTBOX
    ...             ${login_securitycode_default_value}=LOGIN_SECURITYCODE_DEFAULT_VALUE    ${mobile_os_specific_test_step}=none
    IF        "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        IF        "${mobile_os_specific_test_step}"=="none" or "${mobile_os_specific_test_step}"=="${OS}"
            ${LOGIN_SECURITYCODE_TEXTBOX}           get argument actual value   ${LOGIN_SECURITYCODE_TEXTBOX}
            ${LOGIN_SECURITYCODE_DEFAULT_VALUE}     get argument actual value   ${LOGIN_SECURITYCODE_DEFAULT_VALUE}
            ${LOGIN_SIGNIN_BUTTON}                  get argument actual value   ${LOGIN_SIGNIN_BUTTON}
            ${LOGIN_SENDCODE_BUTTON}                  get argument actual value   ${LOGIN_SENDCODE_BUTTON}
            ${HEADER_LOGIN_BUTTON}                  get argument actual value   ${HEADER_LOGIN_BUTTON}
            wait_until_page_loads
            Given enter_testdata_in_locator_field   none    ${emailaddress}     LOGIN_EMAILADDRESS_TEXTBOX
            And enter_testdata_in_locator_field     none    ${password}         LOGIN_PASSWORD_TEXTBOX
            And click_on_element_locator            none    LOGIN_SIGNIN_BUTTON     javascript
            wait_until_page_loads
            Sleep       2s
            ${present}=       Run Keyword And Return Status       Wait For Elements State       ${LOGIN_SENDCODE_BUTTON}
            IF      ${present}
                click_on_element_locator    none    LOGIN_SENDCODE_BUTTON   javascript
                wait_until_page_loads
                ${elements}=    Get Elements    ${LOGIN_SECURITYCODE_TEXTBOX}
                ${securitycode_iterator}=    SET VARIABLE         0

                FOR    ${LOGIN_SECURITYCODE_TEXTBOX_element}       IN      @{elements}
                    Type Text	    ${LOGIN_SECURITYCODE_TEXTBOX_element}         ${LOGIN_SECURITYCODE_DEFAULT_VALUE}[${securitycode_iterator}]
                   ${securitycode_iterator}=    Evaluate    ${securitycode_iterator} + 1
                END
                click_on_element_locator    none  LOGIN_CONFIRMCODE_BUTTON
            END
        END
    END

# Below method is created for BR for MFA
enter_mfa_code_and_submit_the_code
    [Documentation]
	[Arguments]     ${platform_specific_test_step}=none 	${security_code_elements}=locators        ${security_code_value}=testdata
	...             ${mandatory_field}=true         ${send_code_button}=locator        ${mfa_confirm_button}=MFA_CONFIRM_BUTTON        ${web_click_method}=default
	...             ${mobile_click_method}=default        ${mobile_os_specific_test_step}=none      ${mobile_x_coordinates}=none	${mobile_y_coordinates}=none
	IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
	    ${security_code_elements}      get argument actual value     ${security_code_elements}
        ${security_code_value}      get argument actual value     ${security_code_value}
	    ${send_code_button}      get argument actual value     ${send_code_button}
	    ${mfa_confirm_button}      get argument actual value     ${mfa_confirm_button}

        #${confirm_code_visibility_status}=          SET VARIABLE        false
        ${confirm_code_visibility_status}=          Create List         Default
        Sleep   5s
        IF      '${mandatory_field}'=='false'
            ${confirm_code_visibility_status}=        get_states_for_element_with_locator      ${send_code_button}
        END

        IF            'visible' in ${confirm_code_visibility_status} or '${mandatory_field}'=='true'
	        wait_until_page_loads
	        click_on_element_locator	${platform_specific_test_step}      ${send_code_button}     ${web_click_method}	    ${mobile_click_method}	    ${mobile_os_specific_test_step}	    ${mobile_x_coordinates}	    ${mobile_y_coordinates}
	        ${elements}=    Get Elements    ${security_code_elements}
            ${securitycode_iterator}=    SET VARIABLE         0
                FOR    ${security_code_element}       IN      @{elements}
                    Type Text	    ${security_code_element}         ${security_code_value}[${securitycode_iterator}]
                   ${securitycode_iterator}=    Evaluate    ${securitycode_iterator} + 1
                END
                click_on_element_locator        ${platform_specific_test_step}  	${mfa_confirm_button}       ${web_click_method}	    ${mobile_click_method}	    ${mobile_os_specific_test_step}	    ${mobile_x_coordinates}	    ${mobile_y_coordinates}
        END
    END
