*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
enter_testdata_in_locator_field
    [Documentation]         Keyword to enter test data in a text field specified by locator
	[Arguments]	${platform_specific_test_step}=none     ${testdata}=testdata	    ${locator}=locator          ${xpath_text_optional}=none             ${web_delay}=0 ms       ${mobile_os_specific_test_step}=none            ${clear_text}=no
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}      get argument actual value     ${locator}
        ${testdata}      get argument actual value     ${testdata}
        ${is_int}=      Evaluate    isinstance($testdata, list)
        IF      ${is_int}
                ${testdata}      Random Element     ${testdata}
        END
        ${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
        ${clear_text}      get argument actual value     ${clear_text}
        IF      '''"''' in '''${xpath_text_optional}'''
            ${locator} =        Replace String      ${locator}     "      '
        ELSE IF         """'""" in """${xpath_text_optional}"""
            ${locator} =        Replace String      ${locator}     '      "
        END
        ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
        Type Text       ${locator}      ${testdata}         ${web_delay}            clear=${clear_text}
    END

enter_random_phone_number_length_with_prefixed_area_code_in_the_phone_number_locator_field
    [Documentation]         Keyword to enter random phone number with the prefixed value in a text field specified by locator
	 [Arguments]	    ${platform_specific_test_step}=none         ${phone_number_length}=PHONENUMBER_LENGTH        ${prefixed_area_code}=PREFIXED_AREA_CODE      ${phone_number_locator}=LOCATOR      ${web_delay}=0 ms       ${store_value_for_later_use}=none      ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${phone_number_length}      get argument actual value     ${phone_number_length}
        Log         ${phone_number_length}    # to be removed
        ${prefixed_area_code}      get argument actual value     ${prefixed_area_code}
        Log         ${prefixed_area_code}  #  to be removed
        ${randomNumber}   FakerLibrary.Random Number       ${phone_number_length}           fix_len=True
        ${PrefixListLength}     Get Length      ${prefixed_area_code}
        ${PrefixIndex}   FakerLibrary.Random Int     0       ${PrefixListLength-1}
        ${Result}       Set Variable        ${prefixed_area_code}[${PrefixIndex}]${randomNumber}
        #Input Text    ${phone_number_locator}      ${Result}        clear=True
        enter_testdata_in_locator_field         ${platform_specific_test_step}            ${Result}       ${phone_number_locator}	none	${web_delay}
        IF      "${store_value_for_later_use}"!="none"
            Set test variable    ${${store_value_for_later_use}}     ${Result}
        END
    END

enter_random_testdata_type_in_locator_field_length_optional
    [Documentation]         Keyword to enter random data in a text field specified by locator
    [Arguments]	${platform_specific_test_step}=none	${testdata_type}=testdata_type	${locator}=locator	${length_optional}=5        ${store_value_for_later_use}=none        ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}      get argument actual value     ${locator}
        ${length_optional}      get argument actual value     ${length_optional}
        ${testdata_type}      get argument actual value     ${testdata_type}
        ${value} =          Set Variable        0
        IF        "${testdata_type}"=="email"
                ${value}        Get Time        epoch
                # enter_testdata_in_locator_field      automation_${value}@simulator.amazonses.com        ${locator}
                 ${value}    Set Variable    tillstertest${value}@simulator.amazonses.com
                enter_testdata_in_locator_field      ${platform_specific_test_step}           ${value}        ${locator}
        ELSE IF     "${testdata_type}"=="text"
                ${value}        FakerLibrary.Pystr      max_chars=${length_optional}
                enter_testdata_in_locator_field      ${platform_specific_test_step}           ${value}        ${locator}
        ELSE IF     "${testdata_type}"=="alphanumeric"
                #${value}        Evaluate          ''.join(random.sample(string.ascii_letters+string.digits,${length_optional}))          random
                #enter_testdata_in_locator_field      ${value}        ${locator}
                ${char_length} =        Evaluate        ${length_optional}-3
            ${random_lowercase} =      Generate Random String      ${char_length}      [LOWER]
            ${random_uppercase} =      Generate Random String      1      [UPPER]
            ${random_number} =      Generate Random String      1      [NUMBERS]
            ${random_symbol} =      Generate Random String      1      !@/#$%^&*()
            ${value} =      Catenate        SEPARATOR=        ${random_lowercase}        ${random_number}        ${random_symbol}        ${random_uppercase}
                enter_testdata_in_locator_field      ${platform_specific_test_step}           ${value}        ${locator}
        ELSE IF     "${testdata_type}"=="number"
                ${char_length}      get argument actual value     ${length_optional}
                ${value}   FakerLibrary.Random Number       ${char_length}           fix_len=True
                enter_testdata_in_locator_field      ${platform_specific_test_step}           ${value}        ${locator}
        END
        IF      "${store_value_for_later_use}"!="none"
            Set test variable    ${${store_value_for_later_use}}     ${value}
        END
    END

clear_value_from_locator
	[Arguments]	    ${platform_specific_test_step}=none     ${locator}=none     ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}      get argument actual value     ${locator}
        Clear Text      ${locator}
    END


enter_specific_email_with_random_number_appended_to_username
    [Documentation]         Keyword to enter specific email with random number appended to the username in the email address
	#[Arguments]	${locator}=locator	${testdata_type}=email	${length_optional}=
	[Arguments]     ${platform_specific_test_step}=none 	${locator}=locator	        ${email_address_to_use}=none          ${random_number_limit}=3          ${case}=none        ${store_value_for_later_use}=none      ${mobile_os_specific_test_step}=none
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${locator}      get argument actual value     ${locator}
        ${email_address_to_use}      get argument actual value     ${email_address_to_use}
        ${random_number_limit}      get argument actual value     ${random_number_limit}
        ${case}      get argument actual value     ${case}

        ${value}        Generate Random String      ${random_number_limit}     [NUMBERS]
        ${username}         Fetch From Left         ${email_address_to_use}        @
        ${domain}           Fetch From Right        ${email_address_to_use}        @
        ${updated_case}      Convert To Lower Case          ${case}
        IF         "${updated_case}"=="upper"
            ${username} =	    Convert To Upper Case	${username}
        ELSE IF             "${updated_case}"=="lower"
            ${username} =	    Convert To Lower Case	    ${username}
        ELSE IF         "${updated_case}"=="none"
            ${username}=            SET VARIABLE        ${username}
        END
        ${email_address}    Format String           ${username}${value}@${domain}
        Type Text           ${locator}          ${email_address}
        IF      "${store_value_for_later_use}"!="none"
            Set test variable    ${${store_value_for_later_use}}     ${email_address}
        END
    END