*** Settings ***
Documentation
Library         yaml
Library         OperatingSystem
Library         Collections
Library         FakerLibrary
Library         String
Library         AppiumLibrary     timeout=${TIMEOUT}            #run_on_failure=commonKeywordsMobile.take_screenshot_for_failed_tests
Library         Dialogs
Library         ImapLibrary2
Library         JSONLibrary
Library         CustomLibrary.py    ${github_username}          ${github_password}
Library         DebugLibrary
Library         DocTest.VisualTest           take_screenshots=true        embed_screenshots=True      #show_diff=true       screenshot_format=png

#Resource	../../resources${/}modules${/}${highlevel_methods_path}${/}${tenant}.robot
Resource    ../../resources${/}common${/}${resources_path}${/}appEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}clickEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}inputEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}assertEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}emailEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}getEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}keyboardEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}listEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}scrollEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}switchEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}waitEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}tenantsEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}stringEvents.robot
Resource    ../../resources${/}common${/}${resources_path}${/}compareImages.robot
Resource	../../resources${/}modules${/}shared_modules${/}${shared_tc_repo}_${platform}${/}resources.robot


Resource    ../../resources${/}common${/}commonKeywordsAPI.robot


*** Variables ***
${global_current_context} =     None


*** Keywords ***

load_the_application
    [Documentation]         For setting the pre-requisites and opening page
    [Arguments]	    ${location_latitude}=Default	    ${location_longitude}=Default
    #    Import Variables        ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}elementLocators.yaml
    #    Import Variables        ${EXECDIR}${/}tenants${/}${tenant}${/}data${/}${environment}${/}testData.yaml
        IF      "${OS}"=="Android"
            load_application_on_android     ${location_latitude}     ${location_longitude}
        ELSE IF     "${OS}"=="iOS"
            load_application_on_browserstack_iOS        ${location_latitude}     ${location_longitude}
        END
        get_the_driver_instance
        &{contexts_dictionary}=    Create Dictionary       NATIVE_VIEW=NATIVE_APP
        Set Global Variable         ${contexts_dict}       ${contexts_dictionary}

load_application_on_android
    [Documentation]         Launch app on Android
    [Arguments]     ${location_latitude}=Default     ${location_longitude}=Default
    IF      "${execution_environment}"=="Browserstack"
        load_application_on_browserstack_android        ${location_latitude}     ${location_longitude}
    ELSE IF         "${execution_environment}"=="Simulator"
        load_application_on_simulator_android           ${location_latitude}     ${location_longitude}
    END

load_application_on_simulator_android
    [Documentation]         Launch App on Android Simulator
    [Arguments]     ${location_latitude}=Default     ${location_longitude}=Default
    ${remote_url}       Set Variable        http://localhost:4723/wd/hub
    log         ${apk_file_path}
    Open Application    ${remote_url}
    ...                 platformName=${OS}
    ...                 platformVersion=${os_version}
    ...                 device=${device}
    ...                 app=${apk_file_path}
    ...                 appPackage=${app_package}
    ...                 appActivity=${app_activity}
    ...                 automationName=UiAutomator2
    ...                 startIWDP=true
    ...                 newCommandTimeout=60
    ...                 noReset=false
    ...                 unicodeKeyboard=true
    ...                 resetKeyboard=true
    wait_until_page_loads

load_application_on_browserstack_android
    [Documentation]
    [Arguments]     ${location_latitude}=Default     ${location_longitude}=Default
    Log To Console          In Android BS Method
    Log          In Android BS Method
    Log         ${app_url}
    Log         ${download_latest_build}
    ${remote_url}       Set Variable        http://ankurbhalla2:o96zXU5P5nj3qjxnz3xq@hub-cloud.browserstack.com/wd/hub
    #&{desiredCapabilities}      Create Dictionary   platformName=${OS}     os_version=10.0     device=${device}   app=${app_url}    project=${tenant}   name=${TEST NAME}   build=${build_version}      browserstack.local=${local_testing_enabled}     browserstack.localIdentifier=${local_identifier}
    #Open Application    ${remote_url}       desired_capabilities=${desiredCapabilities}
    &{desiredCapabilities}      Create Dictionary       platformName=${OS}
    ...                                                 os_version=${os_version}
    ...                                                 deviceName=${device}
    ...                                                 app=${app_url}
    ...                                                 project=${tenant}
    ...                                                 name=${TEST NAME}
    ...                                                 build=${build_version}
    ...                                                 browserstack.idleTimeout=120
    ...                                                 browserstack.interactiveDebugging=True
    ...                                                 enforceXPath1=true
    #...                                                 browserstack.local=${local_testing_enabled}
    #...                                                 browserstack.localIdentifier=${local_identifier}
    #...                                                 browserstack.networkLogs=true
    #...                                                 browserstack.networkLogsOptions.captureContent=true
    IF      '${geo_location}'!='None'
        Set To Dictionary       ${desiredCapabilities}      browserstack.geoLocation=${geo_location}
    END
    IF      '${location_latitude}'!='Default'
        ${location_latitude}     get argument actual value       ${location_latitude}
        ${location_longitude}     get argument actual value       ${location_longitude}
        Set To Dictionary       ${desiredCapabilities}      browserstack.gpsLocation=${location_latitude},${location_longitude}
    END
    Open Application    ${remote_url}       &{desiredCapabilities}
#    Open Application    ${remote_url}
#    ...                 platformName=${OS}
#    ...                 os_version=${os_version}
#    ...                 device=${device}
#    ...                 app=${app_url}
#    ...                 project=${tenant}
#    ...                 name=${TEST NAME}
#    ...                 build=${build_version}
#    ...                 browserstack.local=${local_testing_enabled}
#    ...                 browserstack.localIdentifier=${local_identifier}
    #...                 browserstack.networkLogs=true
    wait_until_page_loads


load_application_on_browserstack_iOS
    [Documentation]
    [Arguments]     ${location_latitude}=Default     ${location_longitude}=Default
    ${remote_url}       Set Variable        http://ankurbhalla2:o96zXU5P5nj3qjxnz3xq@hub-cloud.browserstack.com/wd/hub
    #&{desiredCapabilities}      Create Dictionary   platformName=${OS}     os_version=12     device=${device}   app=${app_url}    project=${tenant}   name=${TEST NAME}   build=${build_version}      browserstack.local=${local_testing_enabled}     browserstack.localIdentifier=${local_identifier}
    &{desiredCapabilities}      Create Dictionary       platformName=${OS}
    ...                                                 os_version=${os_version}
    ...                                                 deviceName=${device}
    ...                                                 app=${app_url}
    ...                                                 project=${tenant}
    ...                                                 name=${TEST NAME}
    ...                                                 build=${build_version}
    ...                                                 browserstack.idleTimeout=120
    ...                                                 browserstack.interactiveDebugging=True
    ...                                                 enforceXPath1=true
    ...                                                 includeSafariInWebviews=true
    #...                                                 browserstack.local=${local_testing_enabled}
    #...                                                 browserstack.localIdentifier=${local_identifier}
    #...                                                 browserstack.networkLogs=true
    #...                                                 browserstack.networkLogsOptions.captureContent=true
    ${resignapp}=    Get Variable Value    ${BS_RESIGNAPP}    true    #This will keep its value if ${BS_RESIGNAPP} is defined else default set to true.
    IF      '${resignapp}'=='false' or '${resignapp}'=='False'
        Set To Dictionary       ${desiredCapabilities}      browserstack.resignApp=false
    ELSE
        Set To Dictionary       ${desiredCapabilities}      browserstack.resignApp=true
    END
    IF      '${geo_location}'!='None'
        Set To Dictionary       ${desiredCapabilities}      browserstack.geoLocation=${geo_location}
    END
    IF      '${location_latitude}'!='Default'
        ${location_latitude}     get argument actual value       ${location_latitude}
        ${location_longitude}     get argument actual value       ${location_longitude}
        Set To Dictionary       ${desiredCapabilities}      browserstack.gpsLocation=${location_latitude},${location_longitude}
    END
    Open Application    ${remote_url}       &{desiredCapabilities}
#    Open Application    ${remote_url}
#    ...                 platformName=${OS}
#    ...                 os_version=${os_version}
#    ...                 device=${device}
#    ...                 app=${app_url}
#    ...                 project=${tenant}
#    ...                 name=${TEST NAME}
#    ...                 build=${build_version}
#    ...                 browserstack.local=${local_testing_enabled}
#    ...                 browserstack.localIdentifier=${local_identifier}
    #...                 browserstack.networkLogs=true
    wait_until_page_loads

take_screenshot_for_failed_tests
    ${path}=       SET VARIABLE      ${EXECDIR}/results
    ${random_int}=      Get Time    epoch
    Capture Page Screenshot            ${path}/screenshot_${random_int}.png
    capture_screenshot             ${path}/screenshot_${random_int}.png

close_session
    [Documentation]
    #update_test_status
    Close Application
    Log         test completed

take_screenshot_for_failed_tests_to_attach_in_cs
    [Documentation]
    ${path}=       SET VARIABLE      ${EXECDIR}/results
    ${random_int}=      Get Time    epoch
    ${complete_path} =      Set Variable        ${path}/screenshot_${random_int}.png
    Capture Page Screenshot            ${complete_path}
    [Return]   ${complete_path}