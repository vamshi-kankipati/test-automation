*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
open_mailbox_and_wait_for_email_host_emailaddress_password_from_email_partial_subject_to_email
    [Documentation]         Open mailbox, wait for the email based on the email UID, store the email body, subject and UID in global veriables
	[Arguments]	${host}=imap.gmail.com	${emailaddress}=emailaddress	${password}=password        ${from_email}=from_email        ${partial_subject}=${None}    ${to_email}=${None}
	${host}      get argument actual value     ${host}
	${emailaddress}      get argument actual value     ${emailaddress}
	${password}      get argument actual value     ${password}
	${from_email}      get argument actual value     ${from_email}

	IF      '${partial_subject}'=='None'
	    ${partial_subject}      SET VARIABLE        ${None}
    ELSE
	    ${partial_subject}      get argument actual value     ${partial_subject}
    END
 	IF      '${to_email}'=='None'
	    ${to_email}      SET VARIABLE        ${None}
    ELSE
	    ${to_email}      get argument actual value     ${to_email}
    END
	Open Mailbox        host=${host}          user=${emailaddress}        password=${password}       port=993       folder=Inbox
    ${UID_of_first_email}=            Wait For Email          poll_frequency=1         timeout=2         status=UID *:*
    ${UID_of_upcoming_email}     Evaluate     ${UID_of_first_email}+1
    ${LATEST_EMAIL_RECEIVED}=            Run Keyword And Return Status      Wait For Email          poll_frequency=5      timeout=120        status=UID ${UID_of_upcoming_email}         sender=${from_email}        recipient=${to_email}
    ${subject_match}            SET VARIABLE        False

    IF          '${LATEST_EMAIL_RECEIVED}'=='True'
        ${LATEST_EMAIL_RECEIVED}=            Wait For Email          poll_frequency=0      timeout=1        status=UID ${UID_of_upcoming_email}         sender=${from_email}            recipient=${to_email}
        parse_email         ${LATEST_EMAIL_RECEIVED}
        IF          '${partial_subject}'!='${None}'
            ${subject_match}   Run Keyword And Return Status       Should Contain    ${global_emailsubject}      ${partial_subject}
        ELSE
            ${subject_match}        SET VARIABLE        True
        END
    END
    IF      '${LATEST_EMAIL_RECEIVED}'=='False' or '${subject_match}'=='False'
          ${email_found}    SET VARIABLE        False
          FOR       ${i}    IN RANGE        7
                ${UID_of_upcoming_email}     Evaluate     ${UID_of_upcoming_email} - 1
                ${OLD_EMAIL}=            Run Keyword And Return Status          Wait For Email          poll_frequency=2      timeout=4        status=UID ${UID_of_upcoming_email}         sender=${from_email}          recipient=${to_email}
                IF              '${OLD_EMAIL}'=='True'
                    ${OLD_EMAIL}=            Wait For Email          poll_frequency=2      timeout=4        status=UID ${UID_of_upcoming_email}         sender=${from_email}          recipient=${to_email}
                    parse_email         ${OLD_EMAIL}
                    ${subject_match}   Run Keyword And Return Status       Should Contain   ${global_emailsubject}      ${partial_subject}
                    IF      ${subject_match}
                        ${email_found}      SET VARIABLE        True
                        EXIT FOR LOOP
                    END
                END
          END
          IF        not ${email_found}
                FAIL          No email received
          END
    END

parse_email
    [Documentation]         Parse the multipart email
	[Arguments]	${CURRENT_EMAIL}=${EMAIL}
    ${parts} =          Walk Multipart Email        ${CURRENT_EMAIL}
    FOR     ${i}        IN RANGE            ${parts}
            Walk Multipart Email        ${CURRENT_EMAIL}
            ${raw_emailsubject}      Get Multipart Field         Subject
            ${emailsubject}     decode_email_header      ${raw_emailsubject}
            ${ctype} =          Get Multipart Content Type
            Continue For Loop If            '${ctype}' != 'text/html'
            ${payload_raw} =            Get Multipart Payload           decode=True
            ${payload_htmltags_removed}=      Evaluate          re.sub(r'<.*?>', '', '''${payload_raw}''')          re
            ${emailpayload}=          Evaluate        html.unescape('''${payload_htmltags_removed}''')        html
            Set Test variable        ${global_latestemailUID}       ${CURRENT_EMAIL}
            Set Test variable       ${global_emailpayload}     ${emailpayload}
            Set Test variable       ${global_emailsubject}     ${emailsubject}
    END


verify_email_header_contains_expected_message
    [Documentation]         Verify that the email header contains the expected header value
	[Arguments]	${header}=Subject	${expected_message}=message
	${header}      get argument actual value     ${header}
	${expected_message}      get argument actual value     ${expected_message}
    IF          '${header}'=='Subject'
        ${match}   Run Keyword And Return Status       Should Contain  ${global_emailsubject}    ${expected_message}
        IF      not ${match}
            Fail    Assertion failure: ${global_emailsubject} is not present in ${expected_message}
        END
    END

verify_email_header_contains_expected_regex_pattern
    [Documentation]         Verify that the email header contains the expected header value
	[Arguments]	${header}=Subject	${expected_message}=message
	${header}      get argument actual value     ${header}
	${expected_message}      get argument actual value     ${expected_message}
    IF          '${header}'=='Subject'
        ${match}   Run Keyword And Return Status       Should Match Regexp  ${global_emailsubject}    ${expected_message}
        IF      not ${match}
            Fail    Assertion failure: Actual:${global_emailsubject} Expected:${expected_message} are not equal
        END
    END


verify_email_body_contains_expected_message
    [Documentation]         Verify that the email body contains the expected messasge
    [Arguments]	      ${expected_message}=message       ${text_to_substitute}=none
	${expected_message}      get argument actual value     ${expected_message}
	${text_to_substitute}      get argument actual value     ${text_to_substitute}
	${expected_message} =        Replace String      ${expected_message}     %s      ${text_to_substitute}
    ${emailpayload_normalized_spaces}=          Evaluate        re.sub(r'[ \t]{2,}', '', '''${global_emailpayload}''')        re
    ${match}        Run Keyword And Return Status           Should Contain       ${emailpayload_normalized_spaces}        ${expected_message}       collapse_spaces=True
    IF      not ${match}
        Fail    Assertion failure: ${expected_message} is not present in ${emailpayload_normalized_spaces}
    END

verify_email_body_does_not_contain_expected_message
    [Documentation]         Verify that the email body does not contain the expected messasge
    [Arguments]	      ${expected_message}=message
	${expected_message}      get argument actual value     ${expected_message}
    ${emailpayload_normalized_spaces}=          Evaluate        re.sub(r'[ \t]{2,}', '', '''${global_emailpayload}''')        re
    ${match}        Run Keyword And Return Status           Should Not Contain       ${emailpayload_normalized_spaces}        ${expected_message}       collapse_spaces=True
    IF      not ${match}
        Fail    Assertion failure: ${expected_message} is not present in ${emailpayload_normalized_spaces}
    END


verify_email_body_contains_expected_regex_pattern
    [Documentation]         Verify that the email body contains the expected messasge
    [Arguments]	      ${expected_message}=message
	${expected_message}      get argument actual value     ${expected_message}
    ${emailpayload_normalized_spaces}=          Evaluate        re.sub(r'[ \t]{2,}', '', '''${global_emailpayload}''')        re
    ${match}        Run Keyword And Return Status           Should Match Regexp       ${emailpayload_normalized_spaces}        ${expected_message}
    IF      not ${match}
        Fail    Assertion failure: ${expected_message} is not present in ${emailpayload_normalized_spaces}
    END



verify_email_body_contains_expected_link
    [Documentation]         Verify that the email body contains the expected link
	[Arguments]	${expected_link}=link
	${expected_link}      get argument actual value     ${expected_link}
	${link_found}=      Set Variable        False
    ${actual_links}=                Get Links From Email	    ${global_latestemailUID}
    FOR     ${actual_link}        IN            @{actual_links}
        ${match}        Run Keyword And Return Status           Should Contain        ${actual_link}       ${expected_link}
            IF     ${match}
                ${link_found}=      Set Variable        True
                EXIT FOR LOOP
            END
    END
    IF      not ${link_found}
        Fail    Assertion failure: ${expected_link} is not present in any of the url's ${actual_links} in the email
    END

open_link_in_email
    [Documentation]         If the email body contains expected link, then opens that link in a new page
	[Arguments]	${expected_link}=link
	${expected_link}      get argument actual value     ${expected_link}
	${link_found}=      Set Variable        False
    ${actual_links}=                Get Links From Email	    ${global_latestemailUID}
    FOR     ${actual_link}        IN            @{actual_links}
        ${match} =        Run Keyword And Return Status           Should Contain        ${actual_link}       ${expected_link}
            IF     ${match}
                ${link_found}=      Set Variable        True
                New Page        ${actual_link}
                Sleep   2s
                EXIT FOR LOOP
            END
    END
    IF      not ${link_found}
        Fail    Assertion failure: ${expected_link} is not present in any of the url's ${actual_links} in the email
    END


get_content_from_email
    [Documentation]         Retrieves data from email and stores in a temp variable
    [Arguments]	      ${regex_pattern}=pattern          ${store_variable_for_later_use}=None
	${regex_pattern}      get argument actual value     ${regex_pattern}
    ${emailpayload_normalized_spaces}=          Evaluate        re.sub(r'[ \t]{2,}', '', '''${global_emailpayload}''')        re
    ${match_list}        get regexp matches       ${emailpayload_normalized_spaces}        ${regex_pattern}
    ${match}        Get From List           ${match_list}        0
    IF      "${match}"=="${EMPTY}"
        Fail    Assertion failure: ${regex_pattern} is not present in ${emailpayload_normalized_spaces}
    ELSE
        Set Test variable    ${${store_variable_for_later_use}}       ${match}
    END


close_the_mailbox
    [Documentation]         Close the mailbox after verification is done
	[Arguments]
    Close Mailbox