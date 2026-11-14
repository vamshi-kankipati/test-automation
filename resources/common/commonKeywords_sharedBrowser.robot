*** Settings ***
Documentation
Library         yaml
Library         OperatingSystem
Library         Collections
#Library         SeleniumLibrary
Library         FakerLibrary
Library         String
Library         Browser     timeout=${TIMEOUT}      strict=False        #run_on_failure=take_screenshot_for_failed_tests
Library         Dialogs
Library         ImapLibrary2
Library         JSONLibrary
Library         CustomLibrary.py        ${github_username}          ${github_password}
Library         RequestsLibrary
Library         DebugLibrary
Library         DocTest.VisualTest           take_screenshots=true     embed_screenshots=True       #show_diff=true   screenshot_format=jpg
#Library         DateTime


Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}AddItemToCart.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}Checkout.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}CreateAccount.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}FacebookUser.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}LocalizeToStore.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}Payment.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}PlaceOrder.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}SavedAddresses.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}SavePayment.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}Login.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}Email.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}VerifyPages.robot
Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}GoogleUser.robot
Resource        ../../resources${/}modules${/}${highlevel_methods_path}${/}AccountInfo.robot


Resource    ../../resources${/}common${/}${resources_path}${/}clickEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}inputEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}assertEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}emailEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}getEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}listEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}scrollEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}switchEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}waitEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}tenantsEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}stringEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}browserEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}compareImages.robot
Resource    ../../resources${/}common${/}${resources_path}${/}notApplicableWebEvents.robot

# importing the belwo file from browser folder to avoid duplicating GA methods. In future we need to duplicate the file in shared_browser
Resource    ../../resources${/}common${/}browser${/}gaEvents.robot

Resource    ../../resources${/}common${/}commonKeywordsAPI.robot

Resource    ../../resources${/}modules${/}${highlevel_methods_path}${/}shared_keys.robot

*** Variables ***


*** Keywords ***
load_the_application
    [Documentation]         For setting the pre-requisites and opening page
	[Arguments]	    ${platform_specific_test_step}=none	    	 ${location_latitude}=Default	${location_longitude}=Default	${web_execution_browser}=Default	${web_viewport}=Default     ${web_user_agent}=Default	${web_lbs_enabled}=False
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        Log         ${tenant}
        #${page_width}     get argument actual value       ${page_width}
        #${page_height}     get argument actual value       ${page_height}

        ${permissions}=     Set Variable        None
        IF    '${web_lbs_enabled}' == 'True' or '${web_lbs_enabled}' == 'true'
            ${permissions} =    Create List    geolocation
        ELSE IF    '${web_lbs_enabled}' == 'Block' or '${web_lbs_enabled}' == 'block'
            ${permissions} =    Create List    # empty list for block location
        END

        ${geolocation}=     Set Variable        None
        IF      '${location_latitude}'!='Default'
            ${location_latitude}     get argument actual value       ${location_latitude}
            ${location_longitude}     get argument actual value       ${location_longitude}
            ${geolocation} =        Create Dictionary       latitude=${location_latitude}       longitude=${location_longitude}
        END

    #    ${web_viewport} =       Create Dictionary       width=1280      height=720
    #    IF      "${page_width}"=="Default"
    #        IF      "${PAGE_WIDTH_GLOBAL}"=="Default"
    #            #New Context     web_viewport=${web_viewport}        permissions=['geolocation']         httpCredentials={'username': '${HTTP_USERNAME}', 'password': '${HTTP_PASSWORD}'}        web_user_agent=${web_user_agent}      geolocation=${geolocation}      #{'latitude': 14.5395658, 'longitude': 120.9812688}
    #            Log     Default View Port
    #        ELSE
    #            ${web_viewport} =       Create Dictionary       width=${PAGE_WIDTH_GLOBAL}      height=${PAGE_HEIGHT_GLOBAL}
    #        END
    #    ELSE
    #        ${web_viewport} =       Create Dictionary       width=${page_width}      height=${page_height}
    #    END

        IF      "${web_user_agent}"=="Default" and "${web_viewport}"=="Default"
            ${web_viewport} =       Create Dictionary       width=1280      height=720
            ${web_user_agent} =      Set Variable        ${EMPTY}
        ELSE IF         "${web_user_agent}"!="Default"
            ${web_user_agent}       get argument actual value       ${web_user_agent}
            ${web_viewport}       get argument actual value       ${web_viewport}
        ELSE IF         "${web_user_agent}"=="Default" and "${web_viewport}"!="Default"
            ${web_user_agent} =      Set Variable        ${EMPTY}
            ${web_viewport}       get argument actual value       ${web_viewport}
        END

    #    IF      '${web_user_agent}'!='${EMPTY}'
    #        ${web_user_agent}       get argument actual value       ${web_user_agent}
    #    END
        Log         ${web_user_agent}
        #New Context
        #New Page        ${url}
        ${web_execution_browser}      get argument actual value     ${web_execution_browser}
        ${HTTP_USERNAME}        GetVariableValue     ${HTTP_USERNAME}
        ${HTTP_PASSWORD}        GetVariableValue     ${HTTP_PASSWORD}
        IF      "${web_execution_browser}"!="Default"
            Log     ${web_execution_browser}
            ${status1}       ${message1}      Run Keyword And Ignore Error        Close Browser     ALL
            Log         ${status1}
            Log         ${message1}
            ${browsers_active} =      Get Browser Ids         ACTIVE
            Log        ${browsers_active}
            New Browser         browser=${web_execution_browser}      headless=${headless}    timeout=${BROWSER_LAUNCH_TIMEOUT}
            New Context     permissions=['geolocation']  # is it required
            ${browsers_active} =      Get Browser Ids         ACTIVE
            Log        ${browsers_active}
            Log         ${current_browser}
            ${current_browser} =    Set Test Variable        ${web_execution_browser}
            Log         ${current_browser}
        END
        IF      "${execution_mode}"!="Debug123"         # temporarily disabling the debug mode
            ${browsers} =      Get Browser Ids         ALL
            Log        ${browsers}
            ${browsers_all} =      Get Browser Ids         ALL
            Log        ${browsers_all}
            ${browsers_active} =      Get Browser Ids         ACTIVE
            Log        ${browsers_active}
            ${len} =        Get Length      ${browsers_active}
            IF      ${len} == 0
                New Browser         browser=${browser}      headless=${headless}    timeout=${BROWSER_LAUNCH_TIMEOUT}
            END
            ${status}       ${message}      Run Keyword And Ignore Error        New Context     permissions=['geolocation']
            Log         ${status}
            Log         ${message}
            IF      "${status}" == "FAIL" and "${message}" == "Error: : Target page, context or browser has been closed"
                New Browser         browser=${browser}      headless=${headless}        timeout=${BROWSER_LAUNCH_TIMEOUT}
            ELSE IF     "${status}" == "FAIL" and "${message}" != "Error: : Target page, context or browser has been closed"
                Fail    ${message}
            END
            # creating the actual context below
            ${pwd} =     Set Variable     ${HTTP_PASSWORD}
            ${username} =     Set Variable     ${HTTP_USERNAME}
            IF		"${pwd}" == "None"
                ${pwd} = 	SetVariable	some_password
	        END

#            # Creating a temporary folder and passing it to recordvideo argument, so the captured video is stored in the temp folder. NOTE: Since video file name contains random numbers, providing a temp folder to capture the file.
#            ${random_number_1}=    Evaluate    random.randint(1000, 999999)    random
#            ${random_number_2}=    Evaluate    random.randint(1000, 999999)    random
#            # Creating directory to pass is to to recordvideo argument
#            ${temp_video_directory_name}=              Set Variable        Temp_test_execution_video_${random_number_1}_${random_number_2}
#            ${temp_video_directory_path}=          Set Variable            ${EXECDIR}${/}results${/}${global_video_directory}${/}${temp_video_directory_name}
#            &{recordVideo}             Create Dictionary    dir=${temp_video_directory_path}
#
#            Run Keyword And Warn On Failure     Set Global variable    ${global_temp_video_directory_name}         ${temp_video_directory_name}
#            Run Keyword And Warn On Failure     Set Global variable    ${global_temp_video_directory_path}         ${temp_video_directory_path}
#
#            New Context     viewport=${web_viewport}        permissions=${permissions}         httpCredentials={'username': '${username}', 'password': '$pwd'}        userAgent=${web_user_agent}      geolocation=${geolocation}      recordVideo=${recordVideo}   #{'latitude': 14.5395658, 'longitude': 120.9812688}
            New Context     viewport=${web_viewport}        permissions=${permissions}         httpCredentials={'username': '${username}', 'password': '$pwd'}        userAgent=${web_user_agent}      geolocation=${geolocation}      #{'latitude': 14.5395658, 'longitude': 120.9812688}
            New Page        ${url}
            Log         Not Debug
            wait_until_page_loads
        END

    END

load_the_application_on_mobile_browser
    [Documentation]         For setting the pre-requisites and opening page
    [Arguments]        ${platform_specific_test_step}=none          ${execution_browser}=webkit          ${userAgent}=None        ${viewport}=None
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${execution_browser}      get argument actual value     ${execution_browser}
        ${userAgent}      get argument actual value     ${userAgent}
        ${viewport}      get argument actual value     ${viewport}
        Log         ${tenant}
        New Browser             ${execution_browser}        headless=False       timeout=${BROWSER_LAUNCH_TIMEOUT}
        New Context         userAgent=${userAgent}         isMobile=true       viewport=${viewport}
        New Page        ${url}
    END

web__load_the_application_on_non_incognito_mode
    [Documentation]         For setting the pre-requisites and opening page
    [Arguments]             ${platform_specific_test_step}=none     ${location_latitude}=Default	${location_longitude}=Default     ${web_execution_browser}=chromium          ${web_userAgent}=None        ${web_viewport}=None
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${web_execution_browser}      get argument actual value     ${web_execution_browser}
        ${web_userAgent}      get argument actual value     ${web_userAgent}
        ${web_viewport}      get argument actual value     ${web_viewport}
        New Persistent Context         url=${url}           browser=${web_execution_browser}        headless=${headless}       userAgent=${web_userAgent}                viewport=${web_viewport}
    END

close_session
    [Documentation]
    Log         ${current_browser}
    IF      "${current_browser}"!="Default"
        Close Browser       ALL
        #${current_browser} =        Set Test Variable        Default
        Log         ${current_browser}
    END
    Log         test completed

    update_test_status
#    # Extracting the video file name from the temp folder.
#    @{video_files}=    List Files In Directory    ${global_temp_video_directory_path}     *.webm
#    ${extracted_video_file_name}=         Set Variable            ${video_files}[0]
#
#    Sleep   3s
##    When scripts are locally, to view video uncomment the line below. Once the execution is complete, in the command line type python3 -m http.server 8000 .. Load localhost:8000 and navigate to the log.html to view the videos in the log file. Type Crtl + C in the command line to terinate the local server and release the port.
#    Log    <video style="width:100%; height:auto;" controls><source src="/results${/}${global_video_directory}${/}${global_temp_video_directory_name}${/}${extracted_video_file_name}" type="video/webm">Your browser does not support the video tag.</video>      html=True
#
##    gha
#    Log    <video style="width:100%; height:auto;" controls><source src="https://reports.qa.tillster.com${/}${tenant}${/}robot-reports${/}${global_video_directory}${/}${global_temp_video_directory_name}${/}${extracted_video_file_name}" type="video/webm">Your browser does not support the video tag.</video>      html=True


take_screenshot_for_failed_tests
    [Documentation]
    Take screenshot            EMBED

take_screenshot_for_failed_tests_to_attach_in_cs
    [Documentation]
    ${path}=       SET VARIABLE      ${EXECDIR}/results
    ${random_int}=      Get Time    epoch
    ${complete_path} =      Set Variable        ${path}/screenshot_${random_int}.png
    Take screenshot            filename=${complete_path}        fullPage=True
    [Return]   ${complete_path}

set_the_log_level
    [Documentation]     Set Log Level to temporarily change how much information is logged and overrides the log level from command line argument during a specific test case or keyword. The available levels are TRACE, DEBUG, INFO (default), WARN, ERROR and NONE (no logging).
    [Arguments]     ${platform_specific_test_step}=none         ${log_level}=INFO          ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        IF              "${mobile_os_specific_test_step}"=="none" or "${mobile_os_specific_test_step}"=="${OS}"
            ${log_level}     get argument actual value      ${log_level}
            Set Log Level       ${log_level}
        END
    END
