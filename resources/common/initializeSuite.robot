*** Settings ***
Documentation
Library         Collections
Library             pabot.PabotLib
Library         String
Library         CryptoLibrary           variable_decryption=True       key_path=${EXECDIR}${/}resources${/}common${/}crypto_keys
#Library         OperatingSystem
#Library         DateTime
Library         CustomLibrary.py        ${github_username}          ${github_password}

Resource    ${EXECDIR}${/}resources${/}common${/}testRunUpdate.robot


*** Variables ***
${tenant} =
${environment} =
${url} =
${browser} =    chromium
${headless} =   False
${execution_mode} =     Debug
${TIMEOUT} =        120
${BROWSER_LAUNCH_TIMEOUT} =         120
${PAGE_WIDTH_GLOBAL} =     Default
${PAGE_HEIGHT_GLOBAL} =    Default
#${userAgent}=       # Chrome Windows: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4863.0 Safari/537.36"       # Default value = Firefox Android: "Mozilla/5.0 (Android 12; Mobile; rv:102.0) Gecko/102.0 Firefox/102.0"
${current_browser} =    Default
${clone_fe_repo} =      False    #Set clone_fe_repo to True, only when needed to fetch the latest i18n keys from the fe repository and create a baseline, else set it to False
${clone_fe_repo_non_default_lang} =         False       #Set clone_fe_repo for non-default lang to True, only when needed to fetch the latest i18n keys from the fe repository and create a baseline, else set it to False
${clone_tenant_config} =    False          #Set clone_tenant_config to True, only when needed to fetch the latest tenant config file from the fe repository, else set it to False
${get_test_id_mappings} =       True
${test_run_id} =        NA    # For e.g.: 683988
${project_id} =     NA        # For e.g.: 333502
${reset_test_run_result} =      NA
${shared_tc_repo} =   None
${platform} =       None
${geo_location} =       None  # Only for tests/environments needed to be executed on a specific country code (ex: US)
${skip_visual_test_step} =      False
${generate_central_resource_file} =      False  # Set this to True, only when you want to generate a central resource file programmatically that contains the paths of all the files inside shared_modules folder.

# variables for mobile execution
${app_url} =        bs://022dd2ce22d579e7098ea9c2a3501bf649477899
${OS} =     Android
${device} =     Samsung Galaxy S24
${os_version} =     14.0
${execution_environment} =      Browserstack   # Valid options: Browserstack, Simulator
${app_package} =
${app_activity} =
${apk_file_path} =
${build_version} =      local112
${local_testing_enabled} =      True
${local_identifier} =       Slave5
${download_latest_build} =  False
${test_fairy_project} =     NA
${test_run_description} =        Default

${github_username}=         crypt:nD1/kx3maOuXSOZcM1xKHuBBuCTG5FkHe4Zlugw9Zy8QFPKzm+fptnL6jbolDHr6V9z7HcQ93rbMR3qWRg==
${github_password}=         crypt:Nxqnu9BlgxMjM3ROcD626WiFq0t1pKCQU6eo3v3zK1g4GLOO+OzW7+OFl4qmFdX17mVR6aIIdzHjn15gcon0EYzmS1Zk/eXPrlyvFy/oRQda4niX4+meow==


*** Keywords ***

Import File for execution
    [Documentation]     This keyword imports the resource file based on application type
    ${is_web_tenant} =          SET VARIABLE      False
    ${is_mobile_tenant} =       SET VARIABLE      False

    # If test cases are shared across web and mobile, then tenant folder name does not contain platform information. In that case, "platform" value is passed in the command line argument.
    IF      '${platform}'=='None'
        ${is_web_tenant} =        Evaluate        "web" in """${tenant}"""
        Log         ${is_web_tenant}
        ${is_mobile_tenant} =       Evaluate        "mobile" in """${tenant}"""
        Log         ${is_mobile_tenant}
    ELSE
        ${platform_lower}       Convert To Lower Case       ${platform}
        IF      '${platform_lower}'=='web'
            ${is_web_tenant} =        SET VARIABLE      True
        ELSE IF     '${platform_lower}'=='mobile'
            ${is_mobile_tenant} =       SET VARIABLE      True
        END
#        Import Resource    ../../resources${/}common${/}web_mobile_translator.robot
    END


    IF      ${is_web_tenant}

#        ${today}=    Get Current Date    result_format=%Y-%m-%d
#        Run Keyword And Continue On Failure             Create Directory            ${EXECDIR}${/}results${/}Test_execution_video_${today}
#        ${video_directory}=          Set Variable           Test_execution_video_${today}
#        Set global variable    ${global_video_directory}         ${video_directory}

        # Config files when no sharing test case between web and mobile or no sharing test cases between tenants
        IF              '${shared_tc_repo}'=='None' and '${platform}'=='None'
                ${tenant_path}              SET VARIABLE            tenants
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData.yaml
                ${temp_OS}           SET VARIABLE            ${platform}
                Import Variables        ${EXECDIR}${/}${ELEMENTLOCATOR_PATH}
                ${highlevel_methods_path}       SET VARIABLE            browser
                ${resources_path}           SET VARIABLE            browser
                Import Resource         ${EXECDIR}${/}resources${/}common${/}commonKeywordsBrowser.robot
       # Config files when sharing test cases between web and mobile
        ELSE IF         '${platform}'!='None' and '${shared_tc_repo}'=='None'
                ${tenant_path}         SET VARIABLE            tenants
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData_common.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData_osSpecific.yaml
                ${temp_OS}           SET VARIABLE            ${platform}                       #For web, OS is same as platform. Specifying the OS, so the testdata for web can be identified in the oSSpecific.yaml file. For mobile, OS is provided in the command line argument
                ${is_native_app}         Evaluate        "platform" in """${ELEMENTLOCATOR_PATH}"""
               IF      ${is_native_app}
                    ${highlevel_methods_path}       SET VARIABLE            shared_modules${/}${tenant}_native
                ELSE
                    ${highlevel_methods_path}       SET VARIABLE            shared_modules${/}${tenant}
                END
                ${ELEMENTLOCATOR_PATH}      Replace String          ${ELEMENTLOCATOR_PATH}          platform            ${platform}
                Import Variables        ${EXECDIR}${/}${ELEMENTLOCATOR_PATH}
                ${resources_path}           SET VARIABLE            shared_browser
                Import Resource         ${EXECDIR}${/}resources${/}common${/}commonKeywords_sharedBrowser.robot
       # Config files when sharing test cases between tenants, tenant path would be tenants/name of the shared repo
        ELSE IF        '${shared_tc_repo}'!='None' and '${platform}'!='None'
                ${tenant_path}         SET VARIABLE            tenants${/}${shared_tc_repo}
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData_osSpecific.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${platform}${/}feature_arguments.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${platform}${/}verification_arguments.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${platform}${/}feature_config.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${platform}${/}verification_config.yaml
                ${temp_OS}           SET VARIABLE            ${platform}                       #For web, OS is same as platform. Specifying the OS, so the testdata for web can be identified in the oSSpecific.yaml file
                Log to Console          ${ELEMENTLOCATOR_PATH}
                ${ELEMENTLOCATOR_PATH}      Replace String          ${ELEMENTLOCATOR_PATH}          platform            ${platform}
                Import Variables        ${EXECDIR}${/}${ELEMENTLOCATOR_PATH}

                #${highlevel_methods_path}       SET VARIABLE            shared_modules${/}${shared_tc_repo}
                ${highlevel_methods_path}       SET VARIABLE            shared_modules//${shared_tc_repo}_${platform}
                Log    ${highlevel_methods_path}
                Log    ${shared_tc_repo}
                IF          ${generate_central_resource_file}
                    ${shared_modules_dir}           SET VARIABLE            ${EXECDIR}${/}resources${/}modules${/}${highlevel_methods_path}
                    #${common_modules_dir}           SET VARIABLE            ${EXECDIR}${/}resources${/}modules${/}shared_modules${/}common_code
                    ${central_resource_file}           SET VARIABLE            ${EXECDIR}${/}resources${/}modules${/}shared_modules${/}${shared_tc_repo}_${platform}${/}resources.robot

                    ${resource_file_list}           find_resource_files         ${shared_modules_dir}
                    #${common_resource_file_list}           find_resource_files         ${common_modules_dir}
                    write_central_resource         ${resource_file_list}           ${central_resource_file}         ${shared_tc_repo}_${platform}
                    Log To Console            Central resource file created at : ${central_resource_file}
                END

                ${resources_path}           SET VARIABLE            unifying_tenants_browser
                Import Resource         ${EXECDIR}${/}resources${/}common${/}commonKeywords_unifying_tenants_Browser.robot
        END

    ELSE IF     ${is_mobile_tenant}
        IF              '${shared_tc_repo}'=='None' and '${platform}'=='None'
                ${tenant_path}              SET VARIABLE            tenants
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData.yaml
                ${temp_OS}           SET VARIABLE            ${OS}
                Import Variables        ${EXECDIR}${/}${ELEMENTLOCATOR_PATH}
                ${highlevel_methods_path}       SET VARIABLE            mobile
                ${resources_path}           SET VARIABLE            mobile
                Import Resource         ${EXECDIR}${/}resources${/}common${/}commonKeywordsMobile.robot
       # Config files when sharing test cases between web and mobile
        ELSE IF         '${platform}'!='None' and '${shared_tc_repo}'=='None'
                ${tenant_path}         SET VARIABLE            tenants
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData_common.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData_osSpecific.yaml
                ${temp_OS}           SET VARIABLE            ${OS}
                ${is_native_app}         Evaluate        "platform" in """${ELEMENTLOCATOR_PATH}"""
                IF      ${is_native_app}
                    ${highlevel_methods_path}       SET VARIABLE            shared_modules${/}${tenant}_native
                    ${resources_path}           SET VARIABLE            shared_mobile_native
                ELSE
                    ${highlevel_methods_path}       SET VARIABLE            shared_modules${/}${tenant}
                    ${resources_path}           SET VARIABLE            shared_mobile
                END
                ${ELEMENTLOCATOR_PATH}      Replace String          ${ELEMENTLOCATOR_PATH}          platform            ${OS}
                Import Variables        ${EXECDIR}${/}${ELEMENTLOCATOR_PATH}
                Import Resource         ${EXECDIR}${/}resources${/}common${/}commonKeywords_sharedMobile.robot
       # Config files when sharing test cases between tenants, tenant path would be tenants/name of the shared repo
        ELSE IF        '${shared_tc_repo}'!='None' and '${platform}'!='None'
                ${tenant_path}         SET VARIABLE            tenants${/}${shared_tc_repo}
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}testData_osSpecific.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${platform}${/}feature_arguments.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${platform}${/}verification_arguments.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${platform}${/}feature_config.yaml
                Import Variables        ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${platform}${/}verification_config.yaml
                ${temp_OS}           SET VARIABLE            ${OS}
                Log to Console          ${ELEMENTLOCATOR_PATH}
                ${ELEMENTLOCATOR_PATH}      Replace String          ${ELEMENTLOCATOR_PATH}          platform            ${OS}
                Import Variables        ${EXECDIR}${/}${ELEMENTLOCATOR_PATH}

                #${highlevel_methods_path}       SET VARIABLE            shared_modules${/}${shared_tc_repo}
                ${highlevel_methods_path}       SET VARIABLE            shared_modules//${shared_tc_repo}_${platform}
                Log    ${highlevel_methods_path}
                Log    ${shared_tc_repo}
                IF          ${generate_central_resource_file}
                    ${shared_modules_dir}           SET VARIABLE            ${EXECDIR}${/}resources${/}modules${/}${highlevel_methods_path}
                    #${common_modules_dir}           SET VARIABLE            ${EXECDIR}${/}resources${/}modules${/}shared_modules${/}common_code
                    ${central_resource_file}           SET VARIABLE            ${EXECDIR}${/}resources${/}modules${/}shared_modules${/}${shared_tc_repo}_${platform}${/}resources.robot

                    ${resource_file_list}           find_resource_files         ${shared_modules_dir}
                    #${common_resource_file_list}           find_resource_files         ${common_modules_dir}
                    write_central_resource         ${resource_file_list}           ${central_resource_file}         ${shared_tc_repo}_${platform}
                    Log To Console            Central resource file created at : ${central_resource_file}
                END

                ${resources_path}           SET VARIABLE            unifying_tenants_mobile
                Import Resource         ${EXECDIR}${/}resources${/}common${/}commonKeywords_unifying_tenants_Mobile.robot
        END
    END
    #In the case of sharing test cases between tenants, load the test case file
    ${file_exists}      Run Keyword and Return Status       File Should Exist           ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}config.csv
    IF              ${file_exists}
            ${csv}    Get File     ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}config.csv
            @{read}     Create list                ${csv}
#            Log to Console      @{read}
            @{lines}=    Split To Lines    @{read}
#            Log to Console      @{lines}
            Set global variable         @{lines}
    END


    #Set clone_fe_repo to True, only when needed to fetch the latest i18n keys from the fe repository, else set it to False
    Log         ${clone_fe_repo}
    Acquire Lock        CloneLock
    ${data}     ${differences}=        fetch_i18_files       ${clone_fe_repo}            ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}fe_repo         ${FE_REPO}          ${DEFAULT_LANG_i18N}        Default     ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}
    Log         ${clone_fe_repo}
    Set global variable    ${global_json_object}       ${data}
    Set global variable    ${clone_fe_repo}         False
    Set global variable    ${global_tenant_path}         ${tenant_path}
    Set global variable    ${global_temp_OS}         ${temp_OS}
    Log         ${clone_fe_repo}

    #Set clone_tenant_config to True, only when needed to fetch the latest tenant config file from the fe repository, else set it to False
    IF        '${shared_tc_repo}'!='None' and '${platform}'!='None'
        ${fe_tenant_config}     ${tenant_differences}=        fetch_i18_files       ${clone_tenant_config}            ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}fe_repo         ${FE_REPO}          ${DEFAULT_TENANT_CONFIG}        config     ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}
        Log         ${clone_fe_repo}
        Set global variable    ${global_tenant_fe_config_object}       ${fe_tenant_config}
        Set global variable    ${clone_tenant_config}         False
    END

    Log     ${reset_test_run_result}
    IF      "${reset_test_run_result}" != "NA"
        reset_test_run_results
    END

    Release Lock        CloneLock
#       Do not delete below lines as it might be used in future (for picking latest mobile build)
#    IF     ${is_mobile_tenant}
#        Acquire Lock        DownloadLock
#        Log To Console     ${app_url}
#        Log To Console     ${download_latest_build}
#        Log      ${app_url}
#        Log      ${download_latest_build}
#        IF      "${download_latest_build}"=="True"
#            Log To Console      Inside the IF to download
#            Log To Console      ${test_fairy_project}
#            Log To Console      ${environment}
#            Log       Inside the IF to download
#            Log       ${test_fairy_project}
#            Log       ${environment}
#            ${app_url_temp} =        get_latest_build        ${test_fairy_project}       ${environment}
#            Set global variable    ${app_url}       ${app_url_temp}
#            Set global variable    ${download_latest_build}       False
#        END
#        Log To Console     ${app_url}
#        Log To Console      ${test_fairy_project}
#        Log      ${app_url}
#        Log       ${test_fairy_project}
#        Release Lock        DownloadLock
#    END

    IF      "${test_run_id}" != "NA" and ${get_test_id_mappings}
        get_tests_from_test_run
        Log         ${test_id_mappings}
        Set global variable    ${get_test_id_mappings}         False
    END

    Log      ${test_run_description}
    IF      "${test_run_description}" != "Default"
        update_test_run_description
        Set global variable    ${test_run_description}         Default
    END

execute_test_steps   #TO BE DELETED
    [Documentation]         Executes test steps for a given test case
    [Arguments]     ${test_case_identifier}=None
#   Loop through every row in the csv file
    FOR    ${line_csv}    IN    @{lines}
            @{ROWS}    Split String     ${line_csv}          separator=,
#           Check if the test case number in a row matches with the expected test case number
            ${status}       Run Keyword and Return status       List Should Contain Value       ${ROWS}     ${test_case_identifier}
#           If test case number in a row matches with the expected test case number, then remove the test case number that is present in the 0th index and store the steps that starts from the 1st index
            IF      ${status}
                Remove from List        ${ROWS}         0
#               Loop through every step
                FOR     ${data}     IN      @{ROWS}
#                   Check if the step is a High Level method
                    ${is_HL_result}             Run Keyword And Return Status    Should Contain    ${data}    HL
#                   If HL method, then get the test steps inside the High level method in a list
                    IF          ${is_HL_result}
                            @{test_steps_in_HL}         GetVariableValue    ${${data}}
#                           Loop through every step inside the High level method
                            FOR     ${test_step_in_HL}    IN      @{test_steps_in_HL}
                                @{base_method}       GetVariableValue    ${${test_step_in_HL}}
#                               Copy the arguments that need to be passed to a method in a temporary list, as Run keyword takes the arguments only in the list format
                                @{temp}         Copy List        ${base_method}[1]
                                Run Keyword         ${base_method}[0]           @{temp}
                            END
                    ELSE
#                           Get the base method and the arguments for a particular test step in the yaml file under Modules/Browser folder
                            @{base_method}       GetVariableValue    ${${data}}
#                           Copy the arguments that need to be passed to a method in a temporary list, as Run keyword takes the arguments only in the list format
                            @{temp}         Copy List        ${base_method}[1]
                            Run Keyword         ${base_method}[0]           @{temp}
                    END
                END
            END
    END

check config
    [Documentation]         Keyword that checks the config fiel to determine whether the test step needs to be skipped or executed for a tenant
    [Arguments]	    ${data}
        ${config_value}                    Get Value From Json           ${global_tenant_fe_config_object}       $..${data}
        ${result}    Run Keyword And Return Status    Should Not Be Empty      ${config_value}              #This line of code is used, if FE config is used. In that case, if True, then value exists in the FE config. If not true, then check the internal config file
        IF         not ${result}
            ${actual_value}       GetVariableValue    ${${data}}
            IF      '''${actual_value}'''== "yes" or ${{$actual_value is not None}}                         #actual=='yes - determines whether the step inside the HL method needs to be executed or not. ${{$actual_value is not None}} is used to determine whether the step in the test case needs to be executed or not. Ex., guest user can be entered on cart for some tenants and others on the cart
                ${result}      SETVARIABLE     True
            ELSE
                ${result}      SETVARIABLE     False
            END
        END
        [return]         ${result}

call_the_function
    [Documentation]         generic function caller
    [Arguments]     ${function_name}=none        ${config}=none    ${arguments}=none
	${config_value}      get argument actual value     ${config}
	IF  '''${config_value}'''!='''${config}'''                     # Scenario: test step is not applicable to a tenant. In this case, config variable is not added to that specific tenant config.yaml. In the runtime, if the config variable is not found, then the code returns the variable name(ie., key) itself, else returns the actual value of the config variable and executes the test step.
	    ${arguments_value}      get argument actual value     ${arguments}
	    IF      '''${arguments_value}'''=='''none''' or '''${arguments_value}'''=='''${arguments}'''         # Scenario: HL methods without arguments (Ex., Navigation to login HL method does not require arguments). In this case, argument variable is not sent/passed to this 'call_the_function' method. Hence, ${arguments} in this method takes the default value 'none' and executes the flow of function without arguments.      # Scenario2: In HL methods, some variations require arguments, but others may not. When arguments are not needed, argument variable is not added to that specific argument file. In the runtime, if the argument variable is not found, then the code returns the variable name(ie., key) itself and executes the flow of function without arguments. Else returns the actual value of the argument variable and executes the flow of function with arguments.
	        Run Keyword         ${function_name}_${config_value}
        ELSE
            Run Keyword         ${function_name}_${config_value}        &{arguments_value}
        END
    END