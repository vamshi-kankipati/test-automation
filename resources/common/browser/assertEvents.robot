*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
verify_locator_contains_the_exact_expected_message
	[Documentation]         keyword to verify message
	[Arguments]	${locator}=locator	${message}=message	${ignore_case_optional}=false       ${xpath_text_optional}=none   ${ignore_specific_text_optional}=ignore_specific_text_optional
	${locator}      get argument actual value     ${locator}
	${message}      get argument actual value     ${message}
    ${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
    IF      '''"''' in '''${xpath_text_optional}'''
        ${locator} =        Replace String      ${locator}     "      '
    ELSE IF         """'""" in """${xpath_text_optional}"""
        ${locator} =        Replace String      ${locator}     '      "
    END
    ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
	${ignore_specific_text_optional}      get argument actual value     ${ignore_specific_text_optional}
	${ignore_case_optional}      get argument actual value     ${ignore_case_optional}
	Wait For Elements State       ${locator}         visible
	#${text} =       Get Text        ${locator}      ==      ${message}         Assertion failure: Actual:${text} Expected:${message} are not equal
	${text} =       Get Text        ${locator}
	Log         ${text}
	Log         ${message}
	${match} =      Set Variable        False
	${mod_text} =   Replace String      ${text}     ${ignore_specific_text_optional}     ${EMPTY}
	IF      '${ignore_case_optional}' == 'false' or '${ignore_case_optional}' == 'False'
	        ${match}    Run Keyword And Return Status   should be equal     ${mod_text.strip()}     ${message}
    ELSE
            ${mod_text} =       Convert To Lower Case       ${mod_text}
            ${message} =       Convert To Lower Case       ${message}
            ${match}    Run Keyword And Return Status   should be equal     ${mod_text.strip()}     ${message}
    END
	# ${match}    Run Keyword And Return Status   should be equal     ${text.strip()}     ${message}
    IF      not ${match}
        Fail    Assertion failure: Actual:${mod_text} Expected:${message} are not equal
    END

verify_locator_contains_the_partial_expected_message
    [Documentation]         keyword to verify partial message
	[Arguments]	${locator}=locator	${message}=message      ${xpath_text_optional}=none
	${locator}      get argument actual value     ${locator}
	${message}      get argument actual value     ${message}
	${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
	IF      '''"''' in '''${xpath_text_optional}'''
	    ${locator} =        Replace String      ${locator}     "      '
	ELSE IF         """'""" in """${xpath_text_optional}"""
	    ${locator} =        Replace String      ${locator}     '      "
	END
	${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
	#${text} =       Get Text        ${locator}      ==      ${message}         Assertion failure: Actual:${text} Expected:${message} are not equal
	${text} =       Get Text        ${locator}
	Log         ${text}
	Log         ${message}
	${match}    Run Keyword And Return Status   should contain     ${text.strip()}     ${message.strip()}
    IF      not ${match}
        Fail    Assertion failure: Actual:${text} does not contain Expected:${message}
    END


#verify_locator_contains_expected_dynamic_value_using_regular_expression
verify_locator_value_matches_the_expected_pattern
	[Documentation]         keyword to verify dynamic values using regular expression
	[Arguments]	${locator}=locator	${message}=message      ${xpath_text_optional}=none
	#Pause Execution
	${locator}      get argument actual value     ${locator}
	${message}      get argument actual value     ${message}
	${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
	IF      '''"''' in '''${xpath_text_optional}'''
	    ${locator} =        Replace String      ${locator}     "      '
	ELSE IF         """'""" in """${xpath_text_optional}"""
	    ${locator} =        Replace String      ${locator}     '      "
	END
    ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
	${text} =       Get Text        ${locator}
	${pattern}=    Set Variable    (?s)^${message}$
    ${match}   Run Keyword And Return Status       Should Match Regexp  ${text}    ${pattern}
    IF  not ${match}
        Fail    Assertion failure: Actual:${text} Expected:${message} are not equal
    END

verify_partial_expected_value_is_present_in_actual_value
    [Documentation]         keyword to varify actual value contains the partial expected value
	[Arguments]	${expected_value}=message	${actual_value}=message
	${expected_value}      get argument actual value     ${expected_value}
	${expected_value} =       Strip String          ${SPACE}${expected_value}${SPACE}
	${actual_value}      get argument actual value     ${actual_value}
	${match}    Run Keyword And Return Status   should contain     ${actual_value}      ${expected_value}
    IF      not ${match}
        Fail    Assertion failure: Partial_expected:${expected_value} is not present in Actual:${actual_value}
    END

verify_exact_expected_value_matches_with_actual_value
    [Documentation]         keyword to varify actual value contains the partial expected value
	[Arguments]	${expected_value}=message	${actual_value}=message      ${ignore_case_optional}=false
	${expected_value}      get argument actual value     ${expected_value}
	${actual_value}      get argument actual value     ${actual_value}
    IF      '${ignore_case_optional}' == 'false'
	        ${match}    Run Keyword And Return Status   should be equal     ${actual_value}      ${expected_value}
    ELSE
            ${actual_value}  =       Convert To Lower Case       ${actual_value}
            ${expected_value} =       Convert To Lower Case       ${expected_value}
            ${match}    Run Keyword And Return Status   should be equal     ${actual_value}      ${expected_value}
    END
    IF      not ${match}
        Fail    Exact_expected:${expected_value} is not present in Actual:${actual_value}
    END

verify_locator_is_present
    [Documentation]         keyword to verify the existance of the specified locator
    [Arguments]	    ${locator}=locator      ${xpath_text_optional}=none
    ${locator}      get argument actual value     ${locator}
    ${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
    IF      '''"''' in '''${xpath_text_optional}'''
        ${locator} =        Replace String      ${locator}     "      '
    ELSE IF         """'""" in """${xpath_text_optional}"""
        ${locator} =        Replace String      ${locator}     '      "
    END
    ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
    # ${present}    Run Keyword And Return Status    wait until page contains element       ${${locator}}     ${TIMEOUT}
    ${present}    Run Keyword And Return Status    Wait For Elements State       ${locator}         visible
    IF      not ${present}
        Fail    Assertion failure: ${locator} is not present
    END

verify_locator_is_not_present
    [Documentation]         keyword to verify non existance of the specified locator
	[Arguments]	${locator}=locator      ${xpath_text_optional}=none
	${locator}      get argument actual value     ${locator}
	${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
	IF      '''"''' in '''${xpath_text_optional}'''
	    ${locator} =        Replace String      ${locator}     "      '
	ELSE IF         """'""" in """${xpath_text_optional}"""
	    ${locator} =        Replace String      ${locator}     '      "
	END
	${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
	#${present}    Run Keyword And Return Status    Get Element State       ${locator}         visible       ==      False
	${states} =         Get Element States      ${locator}
	${present} =    Set Variable        False
	IF      'visible' in ${states}
        ${present} =        Set Variable    True
	END
	IF      ${present}
	    Fail        Assertion failure: ${locator} is present. Expected: ${locator} should not be present
	END

verify_locator_is_visible
    [Documentation]         keyword to verify the existance of the specified locator
    [Arguments]	    ${locator}=locator      ${xpath_text_optional}=none         ${mobile_os_specific_test_step}=none
    ${locator}      get argument actual value     ${locator}
    ${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
    IF      '''"''' in '''${xpath_text_optional}'''
        ${locator} =        Replace String      ${locator}     "      '
    ELSE IF         """'""" in """${xpath_text_optional}"""
        ${locator} =        Replace String      ${locator}     '      "
    END
    ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
    # ${present}    Run Keyword And Return Status    wait until page contains element       ${${locator}}     ${TIMEOUT}
    ${present}    Run Keyword And Return Status    Wait For Elements State       ${locator}         visible         timeout=10
    IF      not ${present}
        Fail    Assertion failure: ${locator} is not visible
    END


verify_locator_is_not_visible
    [Documentation]         keyword to verify non existance of the specified locator
	[Arguments]	    ${locator}=locator      ${xpath_text_optional}=none         ${mobile_os_specific_test_step}=none
    ${locator}      get argument actual value     ${locator}
    ${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
    IF      '''"''' in '''${xpath_text_optional}'''
        ${locator} =        Replace String      ${locator}     "      '
    ELSE IF         """'""" in """${xpath_text_optional}"""
        ${locator} =        Replace String      ${locator}     '      "
    END
    ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
    ${is_visible}    Run Keyword And Return Status    Wait For Elements State       ${locator}         visible          timeout=10
    IF       ${is_visible}
        Fail        Assertion failure: ${locator} is visible
    END


verify_user_is_directed_to_window_title
	[Arguments]	    ${window_title}=
	${window_title}      get argument actual value     ${window_title}
	${current_title} =      Get Title
	Log         ${current_title}
	# The following IF condition handles the scenario in which the page is not loaded and the title did not appear.
	# Browser library does not wait for the page to load before verifying the title. Hence added wait
	IF      "${current_title}"=="${EMPTY}" or "${current_title}"!="${window_title}"
	    Sleep       ${TIMEOUT}s
	    ${current_title} =      Get Title
	    Log         ${current_title}
    END
	${match}    Run Keyword And Return Status   should be equal     ${current_title}     ${window_title}
    IF      not ${match}
        Fail    Assertion failure: Actual Title:${current_title} Expected Title:${window_title} are not equal
    END


verify_saved_variable_value_matches_with_the_current_value_of_the_locator
    [Documentation]    Keyword that checks saved value matches with current value on the application
    [Arguments]		${saved_value}=saved_value         ${locator}=locator
    ${locator}      get argument actual value      ${locator}
	${current_value} =       Get Text        ${locator}
#	Log To Console  values ${current_value} ${${saved_value}}
    ${match}    Run Keyword And Return Status   should be equal     ${${saved_value}}     ${current_value}
    IF      not ${match}
        Fail    Assertion failure: Actual:${current_value} Expected:${${saved_value}} are not equal
    END

verify_attribute_name_contains_expected_value_for_the_locator
    [Documentation]    Checks that given attribute has expected value on the application
	[Arguments]		${attribute_name}=attribute_name	${expected_attribute_value}=value   ${locator}=locator      ${type}='attribute'
	${attribute_name}  get argument actual value      ${attribute_name}
	${expected_attribute_value}  get argument actual value      ${expected_attribute_value}
	${locator}  get argument actual value      ${locator}
	${actual_attribute_value} =         Set Variable        ${EMPTY}
	IF      '${type}'=='attribute'
	    ${actual_attribute_value}     Get Attribute      ${locator}        ${attribute_name}
    ELSE IF         '${type}'=='property'
        ${actual_attribute_value}     Get Property      ${locator}        ${attribute_name}
    END
    ${match}    Run Keyword And Return Status   should be equal     ${actual_attribute_value}     ${expected_attribute_value}
    IF      not ${match}
        Fail    Assertion failure: Actual:${actual_attribute_value} Expected:${expected_attribute_value} are not equal
    END

#verify_dropdown_list_locator_contains_expected_option
verify_list_locator_contains_the_exact_expected_option
    [Documentation]     Verifies that the list contains expected option
	[Arguments]	${locator}=locator	${option}=option        ${ignore_case_optional}=false       ${xpath_text_optional}=none
	${locator}      get argument actual value     ${locator}
	${option}      get argument actual value     ${option}
	${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
	IF      '''"''' in '''${xpath_text_optional}'''
	    ${locator} =        Replace String      ${locator}     "      '
	ELSE IF         """'""" in """${xpath_text_optional}"""
	    ${locator} =        Replace String      ${locator}     '      "
	END
    ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
	Wait For Elements State       ${locator}         visible
	${list} =        Get Elements     ${locator}
	${selected} =       Set Variable     False
	FOR     ${list_element}    IN      @{list}
	    ${element_text} =      Get Text        ${list_element}
	    Log         ${element_text}
	    Log         ${option}
        IF      '${ignore_case_optional}' == 'false'
                ${selected}    Run Keyword And Return Status   should be equal     ${element_text.strip()}     ${option}
        ELSE
                ${element_text} =       Convert To Lower Case       ${element_text}
                ${option} =       Convert To Lower Case       ${option}
                ${selected}    Run Keyword And Return Status   should be equal     ${element_text.strip()}     ${option}
        END
        IF      ${selected}
                Exit For Loop
        END
    END
    Log     ${selected}
    IF      not ${selected}
	    Fail    Option Failure: The option '${option}' does not exist in list
	END



verify_list_locator_contains_the_partial_expected_option
    [Documentation]     Verifies that the list contains expected option
	[Arguments]	${locator}=locator	${option}=option        ${ignore_case_optional}=false       ${xpath_text_optional}=none
	${locator}      get argument actual value     ${locator}
	${option}      get argument actual value     ${option}
	${xpath_text_optional}      get argument actual value     ${xpath_text_optional}
	IF      '''"''' in '''${xpath_text_optional}'''
	    ${locator} =        Replace String      ${locator}     "      '
	ELSE IF         """'""" in """${xpath_text_optional}"""
	    ${locator} =        Replace String      ${locator}     '      "
	END
    ${locator} =        Replace String      ${locator}     %s      ${xpath_text_optional}
	Wait For Elements State       ${locator}         visible
	${list} =        Get Elements     ${locator}
	${selected} =       Set Variable     False
	FOR     ${list_element}    IN      @{list}
	    ${element_text} =      Get Text        ${list_element}
	    Log         ${element_text}
	    Log         ${option}
        IF      '${ignore_case_optional}' == 'false'
                ${selected}    Run Keyword And Return Status   should contain     ${element_text.strip()}     ${option}
        ELSE
                ${element_text} =       Convert To Lower Case       ${element_text}
                ${option} =       Convert To Lower Case       ${option}
                ${selected}    Run Keyword And Return Status   should contain     ${element_text.strip()}     ${option}
        END
        IF      ${selected}
                ${selected} =               Set Variable            True
                Exit For Loop
	    END
	END
	Log     ${selected}
	IF      not ${selected}
	    Fail    Option Failure: The option '${option}' does not exist in list
    END

verify_expected_options_are_present_in_the_list
    [Documentation]         keyword to verify that the list contains all the specified expected options
    [Arguments]	${locator}=locator	${expected_list_options}=expected_list_options
    ${locator}      get argument actual value     ${locator}
	${expected_list_options}      get argument actual value     ${expected_list_options}

	${actual_list_options} =        Get Elements     ${locator}
	@{missing_expected_options} =       Create List
	${test_fail} =       Set Variable     False
	FOR     ${expected_list_option}     IN      @{expected_list_options}
	    ${expected_list_option}      get argument actual value     ${expected_list_option}
	    ${option_exist} =       Set Variable     False

	    FOR     ${actual_list_option}   IN      @{actual_list_options}
            ${actual_option_text} =      Get Text        ${actual_list_option}

	        IF      "${actual_option_text}" == "${expected_list_option}"
	            ${option_exist} =       Set Variable        True
	            Exit For Loop
	        END
	    END

	    IF      not ${option_exist}
	        Append To List      ${missing_expected_options}     ${expected_list_option}
	        ${test_fail} =       Set Variable     True
	    END
	END

	IF      ${test_fail}
	    Fail    Option Failure: The options '${missing_expected_options}' does not exist in list
	END


verify_all_matched_locators_contains_the_partial_expected_testdata
    [Documentation]     Verifies that all matched locators contains expected test data
	[Arguments]	${locators}=locator	    ${testdata}=testdata       ${ignore_case_optional}=false
	${locators}      get argument actual value     ${locators}
	${testdata}      get argument actual value     ${testdata}

	Wait For Elements State       ${locators}         visible
	${list} =        Get Elements     ${locators}

	FOR     ${list_element}    IN      @{list}
	    ${element_text} =      Get Text        ${list_element}
        IF      '${ignore_case_optional}' == 'false'
                ${selected}    Run Keyword And Return Status   should contain     ${element_text.strip()}     ${testdata}
        ELSE
                ${element_text} =       Convert To Lower Case       ${element_text}
                ${testdata} =       Convert To Lower Case       ${testdata}
                ${selected}    Run Keyword And Return Status   should contain     ${element_text.strip()}     ${testdata}
        END
        IF      not ${selected}
	            Fail    Option Failure: The option '${testdata}' does not exist in list
	    END
	END

verify_all_matched_locators_contains_the_partial_expected_list_of_testdata
    [Documentation]     Verifies that all matched locators contains expected list of test data
	[Arguments]	${locators}=locator	    ${testdata}=testdata_list       ${ignore_case_optional}=false
	${locators}      get argument actual value     ${locators}
	${testdata}      get argument actual value     ${testdata}

	Wait For Elements State       ${locators}         visible
	${list} =        Get Elements     ${locators}
    ${testdata_iterator}=    SET VARIABLE         0

	FOR     ${testdata_single_element}      IN      @{testdata}
	    FOR     ${list_element}    IN      @{list}
	        ${element_text} =      Get Text        ${list_element}
	        IF      '${ignore_case_optional}' == 'false'
	            ${selected}    Run Keyword And Return Status   should contain     ${element_text.strip()}     ${testdata_single_element}
            ELSE
                ${element_text} =       Convert To Lower Case       ${element_text}
                ${lowercase_testdata} =       Convert To Lower Case       ${testdata_single_element}
                ${selected}    Run Keyword And Return Status   should contain     ${element_text.strip()}     ${lowercase_testdata}
            END

            IF      not ${selected}
                Fail    Option Failure: The option '${testdata_single_element}' does not exist in or more items in list
            END
        END
	END

verify_one_of_the_matched_locators_contains_the_partial_expected_list_of_testdata
    [Documentation]     Verifies that all matched locators contains expected list of test data
	[Arguments]	${locators}=locator	    ${testdata}=testdata_list       ${ignore_case_optional}=false       ${number_of_results_to_check}=Default
	${locators}      get argument actual value     ${locators}
	${testdata}      get argument actual value     ${testdata}

	Wait For Elements State       ${locators}         visible
	${list} =        Get Elements     ${locators}
    ${testdata_iterator}=    SET VARIABLE         1

	FOR     ${testdata_single_element}      IN      @{testdata}
	    ${selected} =       Set Variable     False
	    FOR     ${list_element}    IN      @{list}
	        ${element_text} =      Get Text        ${list_element}
            IF      '${ignore_case_optional}' == 'false'
                    ${selected}    Run Keyword And Return Status   should contain     ${element_text.strip()}     ${testdata_single_element}

            ELSE
                    ${element_text} =       Convert To Lower Case       ${element_text}
                    ${lowercase_testdata} =       Convert To Lower Case       ${testdata_single_element}
                    #Insert Into List        ${testdata}         ${testdata_iterator}        ${lowercase_testdata}
                    ${selected}    Run Keyword And Return Status   should contain     ${element_text.strip()}     ${lowercase_testdata}
            END
            IF      ${selected}
                Exit For Loop
            END
            ${testdata_iterator}=    Evaluate    ${testdata_iterator} + 1
            IF      ${number_of_results_to_check}!='Default' and ${testdata_iterator}==${number_of_results_to_check}
                Exit For Loop
            END

	    END

	    IF      not ${selected}
	                Fail    Option Failure: The option '${testdata}[${testdata_iterator}]' does not exist in list
        END
    END


verify_list_locator_does_not_contain_the_exact_expected_option
    [Documentation]     Verifies that the list does not contains expected option
	[Arguments]	${locator}=locator	${option}=option
	${locator}      get argument actual value     ${locator}
	${option}      get argument actual value     ${option}
	Wait For Elements State       ${locator}         visible
	${list} =        Get Elements     ${locator}
	${selected} =       Set Variable     False
	FOR     ${list_element}    IN      @{list}
	    ${element_text} =      Get Text        ${list_element}
	    Log         ${element_text}
	    Log         ${option}
	    IF      "${element_text}" == "${option}"
	        ${selected} =       Set Variable        True
	        Exit For Loop
	    END
	END
	Log     ${selected}
	IF      ${selected}
	    Fail    Option Failure: The option '${option}' exists in list
	END

verify_cart_displays_correct_subtotal
    [Documentation]         Verify that items and mods price adds up to correct subtotal and it matches with subtotal returned from POS
	[Arguments]	${cart_main_item_price_locator}=CART_MAINITEMPRICE_LOCATOR	${cart_mod_item_price_locator}=None	${cart_coupons_locator}=None	${cart_subtotal_locator}=CART_SUBTOTAL_LOCATOR
	${cart_main_item_price_locator}     get argument actual value       ${cart_main_item_price_locator}
	${cart_mod_item_price_locator}     get argument actual value       ${cart_mod_item_price_locator}
	${cart_coupons_locator}     get argument actual value       ${cart_coupons_locator}
	${cart_subtotal_locator}     get argument actual value       ${cart_subtotal_locator}
    #Sleep       3s      # Temp fix to handle Proceed to checkout in BP
	${expected_subtotal}        SET VARIABLE        0
	@{line_item_price}       Create List	            ${cart_main_item_price_locator}         ${cart_mod_item_price_locator}

    FOR     ${item_has_price}     IN      @{line_item_price}
        IF      """${item_has_price}"""!="""None"""
            ${main_items_price}     Get Elements        ${item_has_price}
            FOR     ${main_item_price}     IN      @{main_items_price}
                ${main_item_price}     Get Text        ${main_item_price}
                ${main_item_price_stripped_symbols}          Replace String Using Regexp     ${main_item_price}      [^\\d.]         ${EMPTY}
                ${main_item_price_stripped_spaces}         Strip String          ${SPACE}${main_item_price_stripped_symbols}${SPACE}
                ${expected_subtotal}            EVALUATE        ${expected_subtotal}+${main_item_price_stripped_spaces}
            END
        END
    END

    IF      "${cart_coupons_locator}"!="None"
        ${coupons}     Get Elements        ${cart_coupons_locator}
        FOR     ${coupon_value}     IN      @{coupons}
                    ${coupon_value}     Get Text        ${coupon_value}
                    ${coupon_value_stripped_symbols}          Replace String Using Regexp     ${coupon_value}      [^\\d.]         ${EMPTY}
                    ${coupon_value_stripped_spaces}         Strip String          ${SPACE}${coupon_value_stripped_symbols}${SPACE}
                    ${expected_subtotal}            EVALUATE        ${expected_subtotal}-${coupon_value_stripped_spaces}
        END
    END
	${actual_subtotal_from_pos_raw_value}     Get Text        ${cart_subtotal_locator}
	${actual_subtotal_from_pos_stripped_symbols}          Replace String Using Regexp     ${actual_subtotal_from_pos_raw_value}      [^\\d.]         ${EMPTY}
    ${actual_subtotal_from_pos}         Strip String          ${SPACE}${actual_subtotal_from_pos_stripped_symbols}${SPACE}

	${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${expected_subtotal}     ${actual_subtotal_from_pos}
    IF      not ${match}
        Fail    Assertion failure: Actual subtotal:${actual_subtotal_from_pos} Expected subtotal:${expected_subtotal} are not equal
    END

verify_pwd_and_src_discounts_are_calculated_accurately
	[Documentation]         Keyword to verify the SRC and PWD discount applied is correct
	[Arguments]	${number_of_discounts_applied}=NUMBER_OF_DISCOUNTS_DEFAULT_VALUE	${cart_subtotal_locator}=CART_SUBTOTAL_LOCATOR	${cart_va_tprice_locator}=CART_VATPRICE_LOCATOR	${cart_discountprice_locator}=CART_DISCOUNTPRICE_LOCATOR
	#Get Text        //*[@data-qa-label='123']
	${cart_subtotal_locator}     get argument actual value       ${cart_subtotal_locator}
	${cart_va_tprice_locator}     get argument actual value       ${cart_va_tprice_locator}
	${cart_discountprice_locator}     get argument actual value       ${cart_discountprice_locator}
	${number_of_discounts_applied}     get argument actual value       ${number_of_discounts_applied}
	${subtotal} =       Get Text        ${cart_subtotal_locator}
	${subtotal} =       Replace String Using Regexp     ${subtotal}      [^\\d.]         ${EMPTY}
	${subtotal} =       Strip String          ${SPACE}${subtotal}${SPACE}
	Log        ${subtotal}

	#${discountable_order_amount}        SET VARIABLE        0
	${discountable_order_amount}        EVALUATE        ${number_of_discounts_applied}*${MEMC_Value}
	Log         ${discountable_order_amount}
	IF      ${discountable_order_amount}>${subtotal}
	    ${discountable_order_amount}        SET VARIABLE          ${subtotal}
    END
    ${discountable_order_amount}=       Evaluate        "%.2f" % ${discountable_order_amount}
    Log         ${discountable_order_amount}

    ${minus_tax} =          EVALUATE        ${discountable_order_amount}/1.12
    ${minus_tax}=       Evaluate        "%.2f" % ${minus_tax}
    Log         ${minus_tax}
    ${calculated_vat_amount} =      EVALUATE        ${discountable_order_amount}-${minus_tax}
    ${calculated_vat_amount}=       Evaluate        "%.2f" % ${calculated_vat_amount}
    Log         ${calculated_vat_amount}

    ${calculated_discount} =            EVALUATE        ${minus_tax}*0.2
    ${calculated_discount}=       Evaluate        "%.2f" % ${calculated_discount}
    Log         ${calculated_discount}

    wait_until_locator_does_not_contain_exact_text_value     ${cart_va_tprice_locator}      ${CART_VATPRICE_INITIAL_VALUE}

    ${displayed_vat} =       Get Text        ${cart_va_tprice_locator}
	${displayed_vat} =       Replace String Using Regexp     ${displayed_vat}      [^\\d.]         ${EMPTY}
	${displayed_vat} =       Strip String          ${SPACE}${displayed_vat}${SPACE}
	${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${calculated_vat_amount}     ${displayed_vat}
    IF      not ${match}
        Fail    Assertion failure: Actual Less VAT:${displayed_vat} Expected Less VAT:${calculated_vat_amount} are not equal
    END

    ${displayed_discount} =       Get Text        ${cart_discountprice_locator}
	${displayed_discount} =       Replace String Using Regexp     ${displayed_discount}      [^\\d.]         ${EMPTY}
	${displayed_discount} =       Strip String          ${SPACE}${displayed_discount}${SPACE}
	${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${calculated_discount}     ${displayed_discount}
    IF      not ${match}
        Fail    Assertion failure: Actual Discount:${displayed_discount} Expected Discount:${calculated_discount} are not equal
    END

# This method is temporarily created.
verify_pwd_and_src_discounts_are_calculated_accurately__grnw
	[Documentation]         Keyword to verify the SRC and PWD discount applied is correct
	[Arguments]	${number_of_discounts_applied}=NUMBER_OF_DISCOUNTS_DEFAULT_VALUE	${cart_subtotal_locator}=CART_SUBTOTAL_LOCATOR	${cart_discount_price_locator}=CHECKOUT_DISCOUNT_LOCATOR	${cart_totalprice_locator}=CHECKOUT_TOTAL_LOCATOR
	#Get Text        //*[@data-qa-label='123']
	${cart_subtotal_locator}     get argument actual value       ${cart_subtotal_locator}
	${cart_totalprice_locator}     get argument actual value       ${cart_totalprice_locator}
	${cart_discount_price_locator}     get argument actual value       ${cart_discount_price_locator}
	${number_of_discounts_applied}     get argument actual value       ${number_of_discounts_applied}
	${subtotal} =       Get Text        ${cart_subtotal_locator}
	${subtotal} =       Replace String Using Regexp     ${subtotal}      [^\\d.]         ${EMPTY}
	${subtotal} =       Strip String          ${SPACE}${subtotal}${SPACE}
	Log        ${subtotal}
	${totaldispalyed} =       Get Text        ${cart_totalprice_locator}
	${totaldispalyed} =       Replace String Using Regexp     ${totaldispalyed}      [^\\d.]         ${EMPTY}
	${totaldispalyed} =       Strip String          ${SPACE}${totaldispalyed}${SPACE}
	Log        ${totaldispalyed}


	#${discountable_order_amount}        SET VARIABLE        0
	${discountable_order_amount}        EVALUATE        ${number_of_discounts_applied}*${MEMC_Value}
	Log         ${discountable_order_amount}
	IF      ${discountable_order_amount}>${subtotal}
	    ${discountable_order_amount}        SET VARIABLE          ${subtotal}
    END
    ${discountable_order_amount}=       Evaluate        "%.2f" % ${discountable_order_amount}
    Log         ${discountable_order_amount}

    ${minus_tax} =          EVALUATE        ${discountable_order_amount}/1.12
    ${minus_tax}=       Evaluate        "%.2f" % ${minus_tax}
    Log         ${minus_tax}
    ${calculated_vat_amount} =      EVALUATE        ${discountable_order_amount}-${minus_tax}
    ${calculated_vat_amount}=       Evaluate        "%.2f" % ${calculated_vat_amount}
    Log         ${calculated_vat_amount}

    ${calculated_discount} =            EVALUATE        ${minus_tax}*0.2
    ${calculated_discount}=       Evaluate        "%.2f" % ${calculated_discount}
    ${calculated_discount}=       Evaluate        ${calculated_discount} + ${calculated_vat_amount}
    Log         ${calculated_discount}

    #wait_until_locator_does_not_contain_exact_text_value     ${cart_va_tprice_locator}      ${CART_VATPRICE_INITIAL_VALUE}

    #${displayed_vat} =       Get Text        ${cart_va_tprice_locator}
	#${displayed_vat} =       Replace String Using Regexp     ${displayed_vat}      [^\\d.]         ${EMPTY}
	#${displayed_vat} =       Strip String          ${SPACE}${displayed_vat}${SPACE}
	#${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${calculated_vat_amount}     ${displayed_vat}
   # IF      not ${match}
    #    Fail    Assertion failure: Actual Less VAT:${displayed_vat} Expected Less VAT:${calculated_vat_amount} are not equal
    #END

    ${displayed_discount} =       Get Text        ${cart_discount_price_locator}
	${displayed_discount} =       Replace String Using Regexp     ${displayed_discount}      [^\\d.]         ${EMPTY}
	${displayed_discount} =       Strip String          ${SPACE}${displayed_discount}${SPACE}
	${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${calculated_discount}     ${displayed_discount}
    IF      not ${match}
        Fail    Assertion failure: Actual Discount:${displayed_discount} Expected Discount:${calculated_discount} are not equal
    END

verify_cart_displays_correct_total
    [Documentation]         Verify that cart's total is correct
	[Arguments]	${cart_ordertotal_lineitems_locator}=CART_ORDERTOTAL_LINEITEMS_LOCATOR	${cart_ordertotal_finalprice_locator}=CART_ORDERTOTAL_FINALPRICE_LOCATOR    ${is_discount_preapplied}=true
	${cart_ordertotal_lineitems_locator}      get argument actual value     ${cart_ordertotal_lineitems_locator}
	${cart_ordertotal_finalprice_locator}      get argument actual value     ${cart_ordertotal_finalprice_locator}
	${cart_ordertotal_contrinuting_elements}        Get Elements        ${cart_ordertotal_lineitems_locator}
	${expected_total}        SET VARIABLE        0
	${skip_calculation}        SET VARIABLE        True
	FOR     ${cart_ordertotal_contributing_element}        IN      @{cart_ordertotal_contrinuting_elements}
	    ${states} =         Get Element States      ${cart_ordertotal_contributing_element}
	    IF      'visible' not in ${states}
	        Continue For Loop
        END
	    ${price_text}        Get Text        ${cart_ordertotal_contributing_element}
	    ${is_negative_price} =      Evaluate        "-" in """${price_text}"""
	    # Run Keyword If      ${is_negative_price} AND ${skip_calculation}         Continue For Loop
	    IF      ${is_negative_price}
	        IF      ${skip_calculation} and ${is_discount_preapplied}
	            Continue For Loop
            END
        END
        ${skip_calculation}         SET VARIABLE        False
	    ${price}        Replace String Using Regexp     ${price_text}      [^\\d.]         ${EMPTY}
	    ${price}        Strip String          ${SPACE}${price}${SPACE}
	    ${price_text}       Replace String Using Regexp      ${price_text}      [^\\d.-]         ${EMPTY}
	    Continue For Loop If      '${price_text}'=='${EMPTY}'
	    #${is_negative_price} =      Evaluate        "-" in """${price_text}"""
	    IF      ${is_negative_price}
	        ${expected_total} =         Evaluate        ${expected_total}-${price}
	    ELSE
	        ${expected_total} =         Evaluate        ${expected_total}+${price}
	    END
	END
	${actual_total_text}        GET Text            ${cart_ordertotal_finalprice_locator}
	${actual_total}         Replace String Using Regexp     ${actual_total_text}      [^\\d.]         ${EMPTY}
	${actual_total}         Strip String          ${SPACE}${actual_total}${SPACE}
	${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${expected_total}     ${actual_total}
	IF      not ${match}
        Fail    Assertion failure: Actual total:${actual_total} Expected total:${expected_total} are not equal
    END

verify_checkout_displays_correct_balance_due
    [Documentation]         Verify that Balance Due is correct on checkout page
	[Arguments]	${checkout_gift_cards_price_locator}=CHECKOUT_GIFT_CARDS_PRICE_LOCATOR	${checkout_ordertotal_finalprice_locator}=CHECKOUT_ORDERTOTAL_FINALPRICE_LOCATOR        ${checkout_balance_due_finalprice_locator}=CHECKOUT_BALANCE_DUE_FINALPRICE_LOCATOR
	${checkout_gift_cards_price_locator}      get argument actual value     ${checkout_gift_cards_price_locator}
	${checkout_ordertotal_finalprice_locator}      get argument actual value     ${checkout_ordertotal_finalprice_locator}
	${checkout_balance_due_finalprice_locator}      get argument actual value     ${checkout_balance_due_finalprice_locator}

	${checkout_gift_cards_price_elements}        Get Elements        ${checkout_gift_cards_price_locator}
	${total_gift_cards_price}        SET VARIABLE        0
	FOR     ${checkout_gift_cards_price_element}        IN      @{checkout_gift_cards_price_elements}
	    ${states} =         Get Element States      ${checkout_gift_cards_price_element}
	    IF      'visible' not in ${states}
	        Continue For Loop
        END
	    ${price_text}        Get Text        ${checkout_gift_cards_price_element}
	    ${price}        Replace String Using Regexp     ${price_text}      [^\\d.]         ${EMPTY}
	    ${price}        Strip String          ${SPACE}${price}${SPACE}
	    ${price_text}       Replace String Using Regexp      ${price_text}      [^\\d.-]         ${EMPTY}
	    Continue For Loop If      '${price_text}'=='${EMPTY}'
	    ${total_gift_cards_price} =         Evaluate        ${total_gift_cards_price}+${price}
	END
	${actual_total_text}        GET Text            ${checkout_ordertotal_finalprice_locator}
	${actual_total}         Replace String Using Regexp     ${actual_total_text}      [^\\d.]         ${EMPTY}
	${actual_total}         Strip String          ${SPACE}${actual_total}${SPACE}

	${actual_balance_due_text}        GET Text            ${checkout_balance_due_finalprice_locator}
	${actual_balance_due}         Replace String Using Regexp     ${actual_balance_due_text}      [^\\d.]         ${EMPTY}
	${actual_balance_due}         Strip String          ${SPACE}${actual_balance_due}${SPACE}

	${expected_balance_due} =        Evaluate        ${actual_total}-${total_gift_cards_price}

	${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${expected_balance_due}     ${actual_balance_due}
	IF      not ${match}
        Fail    Assertion failure: Actual Balance Due:${actual_balance_due} Expected Balance Due:${expected_balance_due} are not equal
    END


verify_discount_calculated_is_correct_for_number_of_discount_applied_persons
    [Documentation]         Verify the discount and vat calculated is correct
    [Arguments]     ${number_of_persons}        ${sub_total}        ${vat_locator}       ${discount_locator}
    ${number_of_persons}      get argument actual value     ${number_of_persons}
    ${sub_total}      get argument actual value     ${sub_total}
    ${vat_locator}      get argument actual value       ${vat_locator}
    ${discount_locator}      get argument actual value       ${discount_locator}
    ${sub_total_value}      Get Text        ${sub_total}
    ${sub_total_value}      Replace String Using Regexp     ${sub_total_value}      [^\\d.]         ${EMPTY}
    ${discount_base_price}      SET VARIABLE        0
    IF      ${MEMC_Value}*${number_of_persons} < ${sub_total_value}
        ${discount_base_price} =    Evaluate        ${MEMC_Value}*${number_of_persons}
    ELSE
        ${discount_base_price} =        SET VARIABLE        ${sub_total_value}
    END
    Log         ${discount_base_price}
    ${discount_base_price_minus_tax} =        Evaluate        ${discount_base_price}/1.12         # Minus Tax
    ${vat} =        Evaluate        ${discount_base_price}-${discount_base_price_minus_tax}
    ${vat} =        Convert To Number       ${vat}      2
    ${discount} =       Evaluate        ${discount_base_price_minus_tax}*0.20
    ${discount} =        Convert To Number       ${discount}      2
    Log         ${vat}
    Log         ${discount}
    # ${actual_vat} =         Get Text        //*[@data-qa-label='taxDiscountLbl']
    ${actual_vat} =         Get Text        ${vat_locator}
    ${actual_vat} =         Replace String Using Regexp     ${actual_vat}      [^\\d.]         ${EMPTY}
    ${actual_vat} =         Convert To Number       ${actual_vat}       2
    # ${actual_discount} =               Get Text        //*[@data-qa-label='DiscountAmountLbl']
    ${actual_discount} =               Get Text        ${discount_locator}
    ${actual_discount} =         Replace String Using Regexp     ${actual_discount}      [^\\d.]         ${EMPTY}
    ${actual_discount} =         Convert To Number       ${actual_discount}       2
    ${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${actual_vat}     ${vat}
	IF      not ${match}
        Fail    Assertion failure: Actual VAT:${actual_vat} Expected VAT:${vat} are not equal
    END
    ${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${actual_discount}     ${discount}
    IF      not ${match}
        Fail    Assertion failure: Actual VAT:${actual_discount} Expected VAT:${discount} are not equal
    END

####    Converts the free datatable from CucumberStudio to list     ####
convert_datatable_to_list
    [Documentation]         Converts the free datatable from CucumberStudio to list
	[Arguments]	${locators}
    @{datatable}     Create List
    ${rawtable}        Split String        ${locators}     \n
    FOR     ${everyrow}    IN       @{rawtable}
        ${rows-without-pipeline}        Split String        ${everyrow}      |
        remove values from list          ${rows-without-pipeline}     ${EMPTY}
        append to list      ${datatable}     ${rows-without-pipeline}
    END
    [return]        @{datatable}



repeat_step_with_different_values_keyword_name
    [Documentation]         Keyword to select modifier with text
	[Arguments]		    ${keyword_name}=keyword_name        ${datatable}=
	log to Console      ${keyword_name}
	@{datatable}        Run Keyword       convert_datatable_to_list      ${datatable}
    FOR        ${parameters}    IN     @{datatable}
            Run Keyword     ${keyword_name}        @{parameters}
    END


verify_url_contains_the_expected_data
    [Documentation]         keyword to verifies content in the url
	[Arguments]	      ${data}=url_data          ${match}=exact
	${data}      get argument actual value     ${data}
	${match}      get argument actual value     ${match}

	${text} =       Get Url
	IF          "${match}"=="exact" or "${match}"=="Exact"
	    ${result}    Run Keyword And Return Status   should be equal     ${text}     ${data}
	ELSE
	    ${result}    Run Keyword And Return Status   should contain     ${text}     ${data}
    END
    IF      not ${result}
        Fail    Assertion failure: Actual:${text} Expected:${data} - Either not equal for exact match or does not contain the expected data for partial match
    END


verify_number_of_options_in_list_locator
    [Documentation]         keyword to select an element from list based on index
    [Arguments]	${locator}=locator	${expected_options_count}=10             ${dropdown_type}=list
    #Wait Until Element Is Visible       ${${list_locator}}       ${TIMEOUT}
    #verify_locator_is_present       ${locator}
    ${locator}      get argument actual value     ${locator}
    ${expected_options_count}      get argument actual value     ${expected_options_count}
    ${dropdown_type}     get argument actual value     ${dropdown_type}
    IF      '${dropdown_type}'=='list' or '${dropdown_type}'=='List'
        ${list} =        Get Elements     ${locator}
        ${count} =      Get Length      ${list}
        ${match}    Run Keyword And Return Status   should be equal     ${expected_options_count}     ${count}
        IF      not ${match}
            Fail    Assertion failure: Actual:${count} Expected:${expected_options_count} are not equal
        END
    ELSE IF         '${dropdown_type}'=='option' or '${dropdown_type}'=='Option'
        #Select Options By       ${locator}       index       ${index_value}
        ${list} =       Get Select Options      ${locator}
        ${count} =      Get Length      ${list}
        ${match}    Run Keyword And Return Status   should be equal     ${expected_options_count}     ${count}
        IF      not ${match}
            Fail    Assertion failure: Actual:${count} Expected:${expected_options_count} are not equal
        END
    END

check_for_broken_links
    [Documentation]         for crawling the website
	[Arguments]
	Sleep   30s
	${elements} =    Get Elements       //*[@src] | //*[@href] | //*[@onclick]
	${number_of_elements} =      Get length    ${elements}
	IF      ${number_of_elements}==0
	    Fail        Assertion failure: Number of links on page is 0
	END
	Log     ${elements}
	@{url_list} =       Create List
	@{onclick_list} =       Create List
	@{regexp_1_list} =       Create List
	FOR     ${element}    IN      @{elements}
	    ${attributes} =         Get Attribute Names     ${element}
	    Log     ${attributes}
	    IF      'href' in ${attributes}
	        ${url} =        Get Attribute       ${element}      href
	        Append To List      ${url_list}     ${url}
	    END
	    IF      'src' in ${attributes}
	        ${url} =        Get Attribute       ${element}      src
	        Append To List      ${url_list}     ${url}
	    END
	    IF      'onclick' in ${attributes}
	        ${url} =        Get Attribute       ${element}      onclick
	        #${split_list} =         Split String        ${url}      '
	        #Log         ${split_list}
	        #${url} =        Set Variable        ${split_list}[1]
	        #${url} =        Get From List        ${split_list}      1
	        #Log         ${url}
	        Append To List      ${onclick_list}     ${url}
#	        FOR     ${regexp_1}    IN      @{url}
#	            ${regexp_1_extract} =      Get Regexp Matches       ${regexp_1}         //(.*//)
#	            Append To List      ${regexp_1_list}     ${regexp_1_extract}
#	        END
            ${regexp_1_extract} =      Get Regexp Matches       ${url}         \\(.*\\)
            ${regexp_1_extract} =       Get From List       ${regexp_1_extract}     0
            ${regexp_1_extract} =      Get Regexp Matches       ${regexp_1_extract}         \\'.*\\'
            ${number_of_elements} =      Get length    ${regexp_1_extract}
	        IF      ${number_of_elements}!=0
                ${regexp_1_extract} =       Get From List       ${regexp_1_extract}     0
                ${regexp_1_extract} =       Remove String      ${regexp_1_extract}     '
                Append To List      ${regexp_1_list}     ${regexp_1_extract}
                Append To List      ${url_list}     ${regexp_1_extract}
            END



	    END
	END
#	Append To List      ${url_list}         https://www.somedummyurl.com/
#	Append To List      ${url_list}         https://www.somedummyurl2.com/
#	Append To List      ${url_list}         https://www.somedummyurl3.com/
	Log         ${url_list}
	Log         ${onclick_list}
	Log         ${regexp_1_list}
	@{status_codes_list} =       Create List
	&{failures_list} =    Create Dictionary
	${has_failures} =      Set Variable        False
	FOR     ${url_to_check}    IN      @{url_list}
	    ${resp}         ${url_to_check} =       check_url_response      ${url_to_check}
	    IF      isinstance($resp, str)
	        Append To List      ${status_codes_list}     ${resp}
	        Set To Dictionary      ${failures_list}     ${url_to_check}=${resp}
	        ${has_failures} =        Set Variable    True
	        Log to console      Broken Link:${url_to_check}, Failure Reason:${resp}${\n}
        ELSE IF      '${resp.status_code}'!='200'
            Append To List      ${status_codes_list}     ${resp.status_code}
            Set To Dictionary      ${failures_list}     ${url_to_check}=${resp}
            Log to console
            ${has_failures} =        Set Variable    True
            Log to console      Broken Link:${url_to_check}, Failure Reason:${resp}${\n}
        ELSE
            Append To List      ${status_codes_list}     ${resp.status_code}
            Log to console      Valid Link:${url_to_check}, Response:${resp}${\n}
        END
	    Log         ${status_codes_list}
	END
	Log         ${status_codes_list}
	IF      ${has_failures}
	    FOR    ${key}    IN    @{failures_list.keys()}
	        Log     Failed URL:${key} ${\n}Failure Reason:${failures_list["${key}"]}
	    END
	    Fail        Assertion failure: Some of the URLs are broken. List of broken URLs along with reason: ${failures_list}
	END

check_url_response
    [Documentation]         checking url response
	[Arguments]         ${url_to_check}=
	IF      'https://' not in '${url_to_check}'
	    ${url_to_check} =   Catenate    SEPARATOR=   ${url}     ${url_to_check}
	END
	${resp}=        Run Keyword And Ignore Error         GET    ${url_to_check}
	[Return]    ${resp}[1]      ${url_to_check}

validate_the_date_and_time_displayed_on_the_screen
	[Documentation]         keyword to verify date and time on application for later ordering
	[Arguments]	${locator}=locator	${day}=TEMP_LATER_DAY_VALUE	${time}=TEMP_LATER_TIME_VALUE	${localization_format}=LOCALIZATION_DATETIME_DEFAULT_FORMAT	${expected_format}=APPLICATION_DATETIME_DEFAULT_FORMAT	${ignore_case_optional}=false	${partial_check}=false      ${trim_leading_zero}=false
	${locator}      get argument actual value      ${locator}
	${day}      get argument actual value      ${day}
	${time}      get argument actual value      ${time}
	${localization_format}      get argument actual value      ${localization_format}
	${expected_format}      get argument actual value      ${expected_format}
	${ignore_case_optional}=    Convert To Lower Case    ${ignore_case_optional}
	${partial_check}=    Convert To Lower Case    ${partial_check}
	Wait For Elements State       ${locator}         visible
	${actual_format_value} =       Get Text        ${locator}
	${localization_datetime}=  Set Variable  ${day} ${time}
	${date_object}=  Evaluate  datetime.datetime.strptime('''${localization_datetime}''', '''${localization_format}''')
	${current_year}=  Evaluate  datetime.datetime.now().year
    ${date_object}=  Evaluate  datetime.datetime(${current_year}, ${date_object.month}, ${date_object.day}, ${date_object.hour}, ${date_object.minute}, ${date_object.second})
    ${expected_format_value}=  Evaluate  '${date_object.strftime('''${expected_format}''')}' if '${date_object}' != 'None' else ''
    # Check trim_leading_zero flag
    IF      '${trim_leading_zero}' == 'true' or '${trim_leading_zero}' == 'True'
            ${expected_format_value}=    Evaluate    "${expected_format_value}".lstrip('0')    # Trim leading zeros
    END
    Log         ${actual_format_value}
	Log         ${expected_format_value}
	${match} =      Set Variable        False
	IF      '${ignore_case_optional}' == 'true'
	        Set Variable    ${actual_format_value}=    Convert To Lower Case    ${actual_format_value}
	        Set Variable    ${expected_format_value}=    Convert To Lower Case    ${expected_format_value}
	END
	IF      '${partial_check}' == 'false'
	        ${match}    Run Keyword And Return Status   Should Be Equal As Strings     ${actual_format_value}     ${expected_format_value}
	        IF      not ${match}
                    Fail    Assertion failure: Actual:${actual_format_value} Expected:${expected_format_value} are not equal.
            END
    ELSE
            ${match}    Run Keyword And Return Status   Should Contain    ${actual_format_value}      ${expected_format_value}
            IF      not ${match}
                    Fail    Assertion failure: Actual:${actual_format_value} value does not contains the Expected:${expected_format_value} value.
            END
    END

convert_localization_date_and_time_to_expected_date_time_format_and_save_it_in_variable
	[Documentation]         keyword to convert date and time to expected format for later ordering and saved it into a temporary variable
	[Arguments]	${day}=TEMP_LATER_DAY_VALUE	${time}=TEMP_LATER_TIME_VALUE	${localization_format}=LOCALIZATION_DATETIME_DEFAULT_FORMAT	${expected_format}=EMAIL_DATETIME_DEFAULT_FORMAT	${variable}=variable    ${trim_leading_zero}=false
	${day}      get argument actual value      ${day}
	${time}      get argument actual value      ${time}
	${localization_format}      get argument actual value      ${localization_format}
	${expected_format}      get argument actual value      ${expected_format}
	${localization_datetime}=  Set Variable  ${day} ${time}
	${date_object}=  Evaluate  datetime.datetime.strptime('''${localization_datetime}''', '''${localization_format}''')
	${current_year}=  Evaluate  datetime.datetime.now().year
    ${date_object}=  Evaluate  datetime.datetime(${current_year}, ${date_object.month}, ${date_object.day}, ${date_object.hour}, ${date_object.minute}, ${date_object.second})
    ${expected_datetime}=  Evaluate  '${date_object.strftime('''${expected_format}''')}' if '${date_object}' != 'None' else ''
    # Check trim_leading_zero flag
    IF      '${trim_leading_zero}' == 'true' or '${trim_leading_zero}' == 'True'
            ${expected_datetime}=    Evaluate    "${expected_datetime}".lstrip('0')    # Trim leading zeros
    END
    # Check newline in expected format
    IF    "'newline' in ${expected_datetime}"
    	${expected_datetime}=   Replace String    ${expected_datetime}    newline    \n
    END
	Set Test Variable    ${${variable}}     ${expected_datetime}

verify_that_added_value_is_correctly_calculated_in_locator
    [Documentation]     adds the value fetched from ${added_value_locator} (with ${added_value_xpath_text_optional} text) to ${base_value},
    ...                 verifies that the sum matches the value displayed in ${locator}, and saves it as ${save_for_later_use}
    [Arguments]     ${platform_specific_test_step}=none     ${base_value}=base_value    ${locator}=locator
    ...             ${added_value_locator}=added_value_locator      ${added_value_xpath_text_optional}=added_value_xpath_text_optional
    ...             ${save_for_later_use}=save_for_later_use    ${mobile_os_specific_test_step}=none

    # Prepare locators and texts
    ${base_value}                       get argument actual value       ${base_value}
    ${locator}                          get argument actual value       ${locator}
    ${added_value_locator}              get argument actual value       ${added_value_locator}

    # Handle dynamic locaotr replacement if needed
    ${added_value_xpath_text_optional}          get argument actual value     ${added_value_xpath_text_optional}
    IF      '''"''' in '''${added_value_xpath_text_optional}'''
        ${added_value_locator} =    Replace String      ${added_value_locator}     "      '
    ELSE IF         """'""" in """${added_value_xpath_text_optional}"""
        ${added_value_locator} =    Replace String      ${added_value_locator}     '      "
    END
    ${added_value_locator} =        Replace String      ${added_value_locator}     %s      ${added_value_xpath_text_optional}

    # Fetch values from UI
    ${locator_text}     Get Text    ${locator}
    ${added_value}      Get Text    ${added_value_locator}

    # Extract only numbers for calculation
    ${base_value}=             Convert To String    ${base_value}
    ${base_value}=             Strip String         ${base_value}     #Removes spaces
    ${base_value_only_numbers}=     Replace String Using Regexp    ${base_value}    [^0-9.,]   ${EMPTY}

    ${added_value}=             Convert To String    ${added_value}
    ${added_value}=             Strip String         ${added_value}     #Removes spaces
    ${added_value_only_numbers}=    Replace String Using Regexp    ${added_value}    [^0-9.,]   ${EMPTY}

    ${locator_text}=            Convert To String    ${locator_text}
    ${locator_text}=            Strip String         ${locator_text}     #Removes spaces
    ${locator_only_numbers}=    Replace String Using Regexp    ${locator_text}    [^0-9.,]  ${EMPTY}

    # Convert to numbers and sum
    ${base_value} =             Convert To Number       ${base_value_only_numbers}
    ${added_value} =            Convert To Number       ${added_value_only_numbers}
    ${locator_text} =           Convert To Number       ${locator_only_numbers}

    ${total_value} =            Evaluate            ${base_value}+${added_value}

    # Assert and handle error
    ${match}    Run Keyword And Return Status   Should Be Equal As Numbers     ${locator_text}    ${total_value}
    IF      not ${match}
        Fail    Assertion failure: For locator: ${locator} Actual value:${locator_text} Expected value:${total_value} are not equal
    END
    Set global variable    ${${save_for_later_use}}     ${total_value}
