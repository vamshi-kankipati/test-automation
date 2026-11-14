*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
user_switches_to_a_new_window
    [Documentation]         keyword to switch between windows
	[Arguments]	    ${platform_specific_test_step}=none             ${web_new}=NEW          ${mobile_locator}=locator
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${web_new}  get argument actual value      ${web_new}
        ${page_found} =       Set Variable     False
        #Added static wait to handle new tab loading time.
        Sleep   10s
        ${id}=     Get Page Ids    ALL   ALL    ALL
        IF      '${web_new}'=='NEW'
            Switch Page     ${web_new}
        ELSE IF      '${web_new}'=='MAIN'
                Switch Page     ${id}[0]
        ELSE
                FOR     ${page}     IN    @{id}
                    ${result}       Run Keyword And Return Status   Switch page         ${page}
                    IF      ${result}
                        ${actual_title}         Get Title
                        IF     '${actual_title}'=='${web_new}'
                            ${page_found}=      Set Variable        True
                            EXIT FOR LOOP
                        END
                    END
                END
                IF      not ${page_found}
                    Fail    Assertion failure: ${web_new} page not found
                END
        END
    END


web__go_back_to_previous_page_using_browser_back_button
    [Documentation]         Navigate using browser back button
    [Arguments]	    ${platform_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        Go Back
    END

web__go_back_to_previous_page_using_browser_forward_button
    [Documentation]         Navigate using browser back button
    [Arguments]	    ${platform_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        Go Forward
    END


web__open_a_new_tab_in_browser_and_load_the_new_url
    [Documentation]         Opens the url in a new tab
	[Arguments]	    ${platform_specific_test_step}=none         ${new_url}=new_url
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
	    ${new_url}      get argument actual value     ${new_url}
        New Page        ${new_url}
    END

web__load_the_new_url_in_current_tab
    [Documentation]         Opens the new url in the current tab
	[Arguments]	    ${platform_specific_test_step}=none             ${new_url}=new_url
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
	    ${new_url}      get argument actual value     ${new_url}
        Go To        ${new_url}
    END

web__close_the_page_with_window_title
    [Documentation]         Close the page based on a given window title
	[Arguments]	    ${platform_specific_test_step}=none         ${window_title}=CURRENT
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${window_title}  get argument actual value      ${window_title}
        ${page_found} =       Set Variable     False
        ${id}=     Get Page Ids    ALL   ALL    ALL
        IF      '${window_title}'=='CURRENT'
                Close Page     CURRENT
        ELSE
                FOR     ${page}     IN      @{id}
                    ${result}       Run Keyword And Return Status    Switch page         ${page}
                    IF      ${result}
                        ${actual_title}         Get Title
                        IF     '${actual_title}'=='${window_title}'
                            Close Page          ${page}
                            ${page_found}=      Set Variable        True
                            EXIT FOR LOOP
                        END
                    END
                END
                IF      not ${page_found}
                    Fail    Assertion failure: ${window_title} page not found
                END
        END
    END

switch_to_a_different_language
    [Documentation]         Loads the specified i18n file
    [Arguments]	    ${platform_specific_test_step}=none             ${default_nondefault_lang}=Non_Default           ${i18_file}=NON_DEFAULT_LANG_i18N           ${lang_locator}=locator               ${web_click_method}=default      ${mobile_click_method}=default          ${mobile_x_coordinates}=none	    ${mobile_y_coordinates}=none         ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${i18_file}     get argument actual value      ${i18_file}
        ${lang_locator}     get argument actual value      ${lang_locator}
        ${i18_file}     get argument actual value      ${i18_file}
        click_on_element_locator        ${platform_specific_test_step}            ${lang_locator}        ${web_click_method}	    ${mobile_click_method}	    ${mobile_os_specific_test_step}	    ${mobile_x_coordinates}	    ${mobile_y_coordinates}
    #    ${clone_fe_repo_switch_lang}        SET VARIABLE            False
        ${data}     ${differences}=        fetch_i18_files               ${clone_fe_repo_non_default_lang}       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}fe_repo               ${FE_REPO}          ${i18_file}        ${default_nondefault_lang}      ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}
        Set global variable    ${global_json_object}       ${data}
    END

web__execute_javascript_in_browser_console
    [Documentation]         To execute javascript command in browser console
	[Arguments]     ${platform_specific_test_step}=none         ${script}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${script}        get argument actual value      ${script}
        Evaluate JavaScript     ${None}     ${script}
    END


