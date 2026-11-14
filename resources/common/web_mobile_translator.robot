*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
common__load_the_application
	[Arguments]	${platform_specific_test_step}=none	${web_execution_browser}=Default	${viewport}=Default	${location_latitude}=Default	${location_longitude}=Default	${web_user_agent}=Default	${web_lbs_enabled}=False
	IF              "${platform}"=="web"
        IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            load_the_application        ${web_execution_browser}       ${viewport}     ${location_latitude}        ${location_longitude}       ${web_user_agent}       ${web_lbs_enabled}
        END
    ELSE IF        "${platform}"=="mobile"
        IF             "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            load_the_application        ${location_latitude}     ${location_longitude}
        END
    END


common__click_on_element_locator
	[Arguments]	    ${platform_specific_test_step}=none	    ${locator}=locator	    ${web_click_method}=default	${mobile_click_method}=default	${mobile_os_specific_test_step}=none	${mobile_x_coordinates}=	${mobile_y_coordinates}=
	IF              "${platform}"=="web"
        IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            click_on_element_locator        ${locator}          ${web_click_method}
        END
    ELSE IF        "${platform}"=="mobile"
        IF             "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            click_on_element_locator        ${locator}         ${mobile_os_specific_test_step}       ${mobile_click_method}        ${mobile_x_coordinates}      ${mobile_y_coordinates}
        END
    END

common__enter_testdata_in_locator_field
	[Arguments]	${platform_specific_test_step}=none	${testdata}=data	${locator}=locator	${web_xpath_text_optional}=none	${web_delay}=0 ms
	IF              "${platform}"=="web"
        IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            enter_testdata_in_locator_field        ${testdata}          ${locator}          ${web_xpath_text_optional}         ${web_delay}
        END
    ELSE IF        "${platform}"=="mobile"
        IF             "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            enter_testdata_in_locator_field          ${testdata}          ${locator}
        END
    END

common__enter_random_testdata_type_in_locator_field_length_optional
	[Arguments]	${platform_specific_test_step}=none	${testdata_type}=testdata_type	${locator}=locator	${length_optional}=
	IF              "${platform}"=="web"
        IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            enter_random_testdata_type_in_locator_field_length_optional        ${testdata_type}          ${locator}          ${length_optional}
        END
    ELSE IF        "${platform}"=="mobile"
        IF             "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            enter_random_testdata_type_in_locator_field_length_optional          ${testdata_type}          ${locator}          ${length_optional}
        END
    END

common__enter_random_phone_number_length_with_web_prefixed_area_code_in_the_phone_number_locator_field
	[Arguments]	${platform_specific_test_step}=none	${phone_number_length}=PHONENUMBER_LENGTH	${web_prefixed_area_code}=PREFIXED_AREA_CODE	${phone_number_locator}=LOCATOR
	IF              "${platform}"=="web"
        IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            enter_random_phone_number_length_with_prefixed_area_code_in_the_phone_number_locator_field        ${phone_number_length}       ${web_prefixed_area_code}         ${phone_number_locator}
        END
    ELSE IF        "${platform}"=="mobile"
        IF             "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            enter_random_phone_number_length_with_prefixed_area_code_in_the_phone_number_locator_field          ${testdata}          ${locator}${phone_number_length}       ${web_prefixed_area_code}         ${phone_number_locator}
        END
    END

common__get_editable_non_editable_value_from_the_locator_and_save_it_in_a_variable_for_comparison
	[Arguments]	${platform_specific_test_step}=none	${editable_non_editable}=NonEditable	${locator}=locator	${variable}=variable	${ignore_specific_text_optional}=none	${web_xpath_text_optional}=none


common__verify_locator_is_present
	[Arguments]	${platform_specific_test_step}=none	${locator}=locator	${xpath_text_optional}=none


common__verify_locator_contains_the_partial_expected_message
	[Arguments]	${platform_specific_test_step}=none	${locator}=locator	${message}=message	${web_xpath_text_optional}=none	${mobile_editable_non_editable}=Editable_NonEditable	${mobile_ignore_specific_text_optional}=ignore_specific_text_optional


mobile__switch_view
	[Arguments]	${platform_specific_test_step}=none	${view}=WEB_VIEW
	IF              "${platform}"=="mobile"
        IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
            switch_view       ${view}
        END
    END