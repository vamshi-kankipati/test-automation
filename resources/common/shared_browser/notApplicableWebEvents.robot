*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
mobile__switch_view
    [Documentation]         Pause execution for given period of time
	[Arguments]	    ${platform_specific_test_step}=none	    ${view}=WEB_VIEW	${mobile_os_specific_test_step}=none        ${can_switch_views}=True
	No Operation

mobile__switch_application_package_name
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none         ${package_name}=none            ${mobile_os_specific_test_step}=none
    No Operation

mobile__hide_keyboard_from_screen
    [Documentation]         Keyword to hide the keyboard from view
    [Arguments]	    ${platform_specific_test_step}=none         ${key_name}=none            ${mobile_os_specific_test_step}=none
    No Operation

mobile__scroll_down_to_an_element
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none     ${locator}=locator      ${xpath_text_optional}=none         ${mobile_os_specific_test_step}=none
    No Operation

mobile__swipe_to_position
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none         ${position}=none         ${mobile_os_specific_test_step}=none
    No Operation

mobile__scroll_the_page_vertically_to_get_to_an_element
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none     ${locator}=locator          ${start_percentage_x}=90         ${start_percentage_y}=90         ${end_percentage_x}=90           ${end_percentage_y}=20       ${xpath_text_optional}=none     ${mobile_os_specific_test_step}=none        ${can_switch_views}=True
    No Operation

mobile__scroll_the_scrollbar_horizontally_to_get_to_an_element
    [Documentation]
    [Arguments]     ${platform_specific_test_step}=none     ${scrollbar_element_from_native_view}=locator              ${scroll_to_locator}=locator                  ${xpath_text_optional}=none           ${mobile_os_specific_test_step}=none             ${can_switch_views}=True
    No Operation

mobile__scroll_the_images_horizontally_if_scrollbar_element_is_not_present
    [Documentation]
    [Arguments]	    ${platform_specific_test_step}=none     ${scroll_from_locator_native_view}=locator              ${scroll_to_locator}=locator         ${xpath_text_optional}=none          ${mobile_os_specific_test_step}=none          ${can_switch_views}=True           ${scroll_direction}=left
    No Operation

mobile__scroll_the_page_horizontally_to_get_to_an_element
    [Documentation]
    [Arguments]	    ${platform_specific_test_step}=none     ${locator}=locator               ${start_percentage_x}=90         ${start_percentage_y}=50         ${end_percentage_x}=20           ${end_percentage_y}=50       ${xpath_text_optional}=none       ${mobile_os_specific_test_step}=none             ${can_switch_views}=True
    No Operation

mobile__kill_the_app_on_the_phone
    [Documentation]     Kills any app that is currently running
    [Arguments]     ${platform_specific_test_step}=none         ${package_name}=default         ${mobile_os_specific_test_step}=none
    No Operation

mobile__activate_the_app_on_the_phone
    [Documentation]     Launches any app on the device
    [Arguments]     ${platform_specific_test_step}=none         ${package_name}=default         ${mobile_os_specific_test_step}=none
    No Operation


mobile__scroll_up_to_an_element
    [Documentation]     Scroll up to an element
    [Arguments]	${platform_specific_test_step}=none     ${locator}=locator      ${xpath_text_optional}=none         ${mobile_os_specific_test_step}=none
    No Operation

tap_the_element_ios_only
    [Documentation]         keyword to click on an element based on text
    [Arguments]	    ${platform_specific_test_step}=none     ${locator}=locator	    ${text}=text           ${count}=1     ${mobile_os_specific_test_step}=none
    No Operation

mobile__trigger_deeplink
    [Documentation]    Send app to background and triggers deep link from testData
    ...  To use the default package_name keep AUT_PACKAGE_NAME_iOS and AUT_PACKAGE_NAME_Android in testData accordingly
    [Arguments]     ${deeplink_url}=deeplink_url    ${platform_specific_test_step}=none     ${package_name}=AUT_PACKAGE_NAME    ${mobile_os_specific_test_step}=none
    No Operation