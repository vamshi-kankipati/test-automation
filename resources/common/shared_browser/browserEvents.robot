*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
web__refresh_current_page
    [Documentation]         Refresh the current page of application
	[Arguments]     ${platform_specific_test_step}=none
    IF         "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        Reload
    END

upload_file
    [Documentation]         Uploads file from path to file input element matched by selector.
	[Arguments]         ${platform_specific_test_step}=none         ${source_file_path}=file_path     ${web_locator}=locator      ${mobile_upload_path_device}=None       ${mobile_os_specific_test_step}=none
	IF         "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
	    ${web_locator}     get argument actual value       ${web_locator}
	    ${source_file_path}      get argument actual value     ${source_file_path}
        Upload File By Selector             ${web_locator}              ${EXECDIR}${/}${source_file_path}
    END

web__close_the_page
    [Documentation]         Close the page
    [Arguments]     ${platform_specific_test_step}=none         ${page}=CURRENT              ${context}=CURRENT         ${browser}=CURRENT
    IF         "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${page}     get argument actual value       ${page}
        ${context}     get argument actual value       ${context}
        ${browser}     get argument actual value       ${browser}
        Close Page           ${page}          ${context}          ${browser}
    END

web__set_the_network_status_offline
    [Documentation]         Set's the network status to be online or offline
    [Arguments]     ${platform_specific_test_step}=none         ${offline}=True
    IF         "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${offline}     get argument actual value       ${offline}
        Set Offline          ${offline}
    END

web__set_viewport
   [Documentation]         Sets the desired viewport for the browser session
   [Arguments]         ${platform_specific_test_step}=none          ${width}=4880            ${height}=2559        ${store_current_width_for_later_use}=none           ${store_current_height_for_later_use}=none
   IF         "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
       ${width}     get argument actual value       ${width}
       ${height}     get argument actual value       ${height}
       IF           "${store_current_width_for_later_use}"!="none" or "${store_current_height_for_later_use}"!="none"
           ${store_current_width_for_later_use}     get argument actual value       ${store_current_width_for_later_use}
           ${store_current_height_for_later_use}     get argument actual value       ${store_current_height_for_later_use}

           ${current_viewport_width}         Get Viewport Size       width
           ${current_viewport_height}         Get Viewport Size       height

           Set test variable    ${${store_current_width_for_later_use}}     ${current_viewport_width}
           Set test variable    ${${store_current_height_for_later_use}}     ${current_viewport_height}
       END
       Set Viewport Size           ${width}            ${height}
   END



