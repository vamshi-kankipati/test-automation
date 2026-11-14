*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
refresh_current_page
    [Documentation]         Refresh the current page of application
	[Arguments]
    Reload

upload_the_file_by_selector
    [Documentation]         Uploads file from path to file input element matched by selector.
	[Arguments]         ${locator}=locator              ${file_path}=file_path
	${locator}     get argument actual value       ${locator}
	${file_path}      get argument actual value     ${file_path}
    Upload File By Selector             ${locator}              ${EXECDIR}${/}${file_path}

close_the_page
    [Documentation]         Close the page
    [Arguments]         ${page}=CURRENT              ${context}=CURRENT         ${browser}=CURRENT
	${page}     get argument actual value       ${page}
	${context}     get argument actual value       ${context}
	${browser}     get argument actual value       ${browser}
	Close Page           ${page}          ${context}          ${browser}

set_the_network_status_offline
    [Documentation]         Set's the network status to be online or offline
    [Arguments]         ${offline}=True
    ${offline}     get argument actual value       ${offline}
    Set Offline          ${offline}

set_viewport
   [Documentation]         Sets the desired viewport for the browser session
   [Arguments]         ${width}=4880            ${height}=2559        ${store_current_width_for_later_use}=none           ${store_current_height_for_later_use}=none
   ${width}     get argument actual value       ${width}
   ${height}     get argument actual value       ${height}
   IF           "${store_current_width_for_later_use}"!="none" or "${store_current_height_for_later_use}"!="none"
       ${current_viewport_width}         Get Viewport Size       width
       Set test variable    ${${store_current_width_for_later_use}}     ${current_viewport_width}
       ${current_viewport_height}         Get Viewport Size       height
       Set test variable    ${${store_current_height_for_later_use}}     ${current_viewport_height}
   END
   Set Viewport Size           ${width}            ${height}



