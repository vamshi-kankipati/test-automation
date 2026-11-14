*** Settings ***
Documentation
Library         yaml
Library         OperatingSystem
Library         Collections
Library         FakerLibrary
Library         String
#Library         Browser     timeout=${TIMEOUT}      strict=False
Library         Dialogs
Library         ImapLibrary2
Library         RequestsLibrary

*** Variables ***


*** Keywords ***
#######################   OM Templates   #######################
change_the_order_status_in_om
    [Documentation]    Keyword that can change the status of the order in Order manager
	[Arguments]	    ${order_id}=OrderId	${order_status}=MOVE_ORDER_TO_KITCHEN	${store}=DEFAULT_STOREID_VALUE
    ${order_id}     get argument actual value      ${${order_id}}
    ${order_status}    get argument actual value      ${${order_status}}
    ${store}    get argument actual value      ${${store}}

    ${header}=      Create Dictionary       x-api-key=${OM_KEY}             Content-Type=application/json
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}         status=${order_status}          store=${store}      reason=${DEFAULT_REASON_FOR_CANCELLATION}
    ${response}=        Wait Until Keyword Succeeds     20 sec      1 sec       POST         ${OM_URL}/api/TestE2E/OrderStatus             json=${body}       headers=${header}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}    ok


cancel_an_order_in_om
    [Documentation]    Keyword that can cancel the order in Order manager
	[Arguments]	    ${order_id}=OrderId	${store}=DEFAULT_STOREID_VALUE	${reason_for_cancellation}=DEFAULT_REASON_FOR_CANCELLATION
    ${order_id}     get argument actual value      ${${order_id}}
    ${store}    get argument actual value      ${${store}}
    ${reason_for_cancellation}      get argument actual value      ${${reason_for_cancellation}}

    ${header}=      Create Dictionary       x-api-key=${OM_KEY}     Content-Type=application/json
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}         status=${MOVE_ORDER_TO_CANCEL_STATE}          store=${store}      reason=${reason_for_cancellation}
    ${response}=        Wait Until Keyword Succeeds     20 sec      1 sec   POST         ${OM_URL}/api/TestE2E/OrderStatus             json=${body}       headers=${header}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}    ok


# parameters after tenant are not being used. Once team confirms those parameters are removed from CS, then will them from this method
check_the_order_status_in_om
    [Documentation]    Keyword that checks the order status in OM
	[Arguments]     ${order_id}=OrderId	    ${order_status}=ORDER_STATUS_OPEN       ${store}=DEFAULT_STOREID_VALUE	    ${tenant}=TENANT_ID     ${email}=EMAILADDRESS_DEFAULT_VALUE     ${IS_CANCELLED_Optional}=None      ${IS_FUTURE_ORDER_Optional}=None      ${IS_CURBSIDE_PICKUP_Optional}=None     ${DISPOSITION_Optional}=None
    ${order_id}     get argument actual value      ${${order_id}}
    ${store}    get argument actual value      ${${store}}
    ${tenant}    get argument actual value      ${${tenant}}
    ${expected_order_status}    get argument actual value      ${${order_status}}
    ${DISPOSITION_Optional}      get argument actual value      ${${DISPOSITION_Optional}}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${tenant}    store=${store}     cultureUI=${null}       bIncJson=${false}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should contain    ${response.json()}[html]        ${expected_order_status}
    Run Keyword If  '${DISPOSITION_Optional}'!='None'      Should contain    ${response.json()}[html]        ${DISPOSITION_Optional}


check_the_status_for_cancelled_order_in_om
    [Documentation]    Keyword that checks the order status in OM
	[Arguments]	        ${order_id}=OrderId      ${store}=DEFAULT_STOREID_VALUE	    ${email}=EMAILADDRESS_DEFAULT_VALUE
    ${order_id}     get argument actual value      ${${order_id}}
    ${store}    get argument actual value      ${${store}}
    ${email}    get argument actual value      ${${email}}

    ${params}=      Create Dictionary       store=${store}      orderId=${order_id}     tenant=${TENANT_ID}        email=${email}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OM_PROXY_URL}/mobilem8-web-service/ordermanager/orderstatus     params=${params}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[Status]        ${ASSERT_CANCELLED_ORDER_STATE}
    Should Be Equal As Strings    ${response.json()}[IsCancelled]        ${ASSERT_IS_CANCELLED_TRUE}



check_the_payment_status_in_om
    [Documentation]    Keyword that checks the payment status in OM
    [Arguments]	   ${order_id}=OrderId     ${store_name}=DEFAULT_STORE_NAME     ${payment_type}=PAYMENT_TYPE_CASH       ${payment_status}=PAYMENT_STATUS_LATER      ${payment_provider_optional}=None
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${payment_type}    get argument actual value      ${payment_type}
    ${payment_status}    get argument actual value      ${payment_status}
    ${payment_provider_optional}    get argument actual value      ${payment_provider_optional}

    #${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}    store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[order][Payments][0][PaymentMethod]        ${payment_type}
    Should Be Equal As Strings    ${response.json()}[order][Payments][0][Status]        ${payment_status}
    Run Keyword If  '${payment_provider_optional}'!='None'      Should Be Equal As Strings    ${response.json()}[order][Payments][0][PayProviderType]        ${payment_provider_optional}



check_the_order_special_instructions_in_om
    [Documentation]    Keyword that checks the special instructions for order in OM
    [Arguments]	     ${order_id}=OrderId     ${store_name}=DEFAULT_STORE_NAME     ${special_instructions}=DEFAULT_SPECIAL_INSTRUCTIONS
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${special_instructions}    get argument actual value      ${special_instructions}

    #${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}      store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[order][SpecialInstruction]        ${special_instructions}



check_plastic_utensils_opted_status_in_om
    [Documentation]    Keyword that checks the status of plastic utensils opted for order in OM
    [Arguments]	    ${order_id}=OrderId     ${store_name}=DEFAULT_STORE_NAME     ${opted_status}=opted
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${opted_status}    get argument actual value      ${opted_status}

    #${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}      store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    Run Keyword If  '${opted_status}'=='opted'      should contain    ${response.json()}[html]        ${PLASTIC_UTENSILS_TEXT_IN_OM_RECEIPT}
    Run Keyword If  '${opted_status}'!='opted'      should not contain    ${response.json()}[html]        ${PLASTIC_UTENSILS_TEXT_IN_OM_RECEIPT}


check_cart_subtotal_and_total_in_om
    [Documentation]    Keyword that checks subtotal and total in OM
    [Arguments]     ${order_id}=OrderId     ${store_name}=DEFAULT_STORE_NAME     ${subtotal}=TEMP_CART_SUBTOTAL_VALUE       ${total}=TEMP_CART_TOTAL_VALUE       ${discount}=None        ${vat}=None     ${delivery_price}=None         ${tax}=None     ${total_discount}=None
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${subtotal}     get argument actual value      ${subtotal}
    ${total}     get argument actual value      ${total}
    ${discount}     get argument actual value      ${discount}
    ${vat}     get argument actual value      ${vat}
    ${delivery_price}     get argument actual value      ${delivery_price}
    ${total_discount}     get argument actual value      ${total_discount}
    ${tax}     get argument actual value      ${tax}

    #${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    #${headers}=     Create Dictionary       x-api-key=986884EB-301F-4CB6-B6B9-AF0877E5C218
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}      store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    #${body}=    Create Dictionary    orderId=${order_id}   tenant=grn-philippines      store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}
    #${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         https://greenwich-om-ph-qa-c.tillster.com/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}

    ${subtotal} =       Replace String Using Regexp     ${subtotal}      [^\\d.]         ${EMPTY}
    ${subtotal} =       Strip String          ${SPACE}${subtotal}${SPACE}
    Should Be Equal As Numbers    ${response.json()}[order][Subtotal]        ${subtotal}

    ${total} =       Replace String Using Regexp     ${total}      [^\\d.]         ${EMPTY}
    ${total} =       Strip String          ${SPACE}${total}${SPACE}
    Should Be Equal As Numbers    ${response.json()}[order][Total]        ${total}
    #${discounts_node} =         Get From Dictionary         ${response.json()}[order]       Discounts
    #${length} =   Get Length   ${discounts_node}
    #Log     ${length}

    IF      "${discount}"!="None"
        ${discount} =       Replace String Using Regexp     ${discount}      [^\\d.]         ${EMPTY}
        ${discount} =       Strip String          ${SPACE}${discount}${SPACE}

        @{response_discounts} =         Set Variable        ${response.json()}[order][Discounts]
        ${calculated_total_discount_response} =         Set Variable        0
        FOR     ${response_discount}    IN      @{response_discounts}
            Log         ${response_discount}
            ${calculated_total_discount_response} =         EVALUATE        ${calculated_total_discount_response}+${response_discount}[Amt]
            Log         ${calculated_total_discount_response}
        END
        IF      "${vat}"!="None"
            ${vat} =       Replace String Using Regexp     ${vat}      [^\\d.]         ${EMPTY}
            ${vat} =       Strip String          ${SPACE}${vat}${SPACE}
            ${total_discount} =         EVALUATE        ${discount}+${vat}
            #Should Be Equal As Numbers    ${response.json()}[order][discount_total]        ${total_discount}
            Should Be Equal As Numbers    ${calculated_total_discount_response}        ${total_discount}
        ELSE
            Should Be Equal As Numbers    ${calculated_total_discount_response}        ${discount}
        END
    END
    Run Keyword If  '${delivery_price}'!='None'      Should Be Equal As Numbers    ${response.json()}[order][DeliveryCharge]        ${delivery_price}
    Run Keyword If  '${tax}'!='None'      Should Be Equal As Numbers    ${response.json()}[order][Tax]        ${tax}
    ${html}=          Evaluate        re.sub(r'<.*?>', '', '''${response.json()}[html]''')            re
    ${html_normalized_spaces}       Evaluate        re.sub(r'[ \t]{2,}', '', '''${html}''')        re
    IF       "${total_discount}"!="None"
        ${total_discount}       Replace String Using Regexp     ${total_discount}      [^\\d.-]         ${EMPTY}
    ${total_discount} =       Strip String          ${SPACE}${total_discount}${SPACE}
    Run Keyword If  '${total_discount}'!='None'      Should Contain    ${html_normalized_spaces}        Total Discount\n${total_discount}
    END


#This method is added for BPCA
check_the_order_reciept_address_in_om
    [Arguments] 	${order_id}=OrderId     ${store_name}=DEFAULT_STORE_NAME     ${payment_type}=OM_PAYMENT_TYPE_CASH      ${order_despostion}=OM_ORDER_DESPOSTION      ${Address}=ORDERCONFIRMATION_PICKUPSTOREDETAILS_TEXT_VALUE
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${payment_type}    get argument actual value      ${payment_type}
    ${order_despostion}    get argument actual value      ${order_despostion}
    ${Address}    get argument actual value      ${Address}
    #${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}    store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[order][Payments][0][PaymentMethod]        ${payment_type}
    Should Be Equal As Strings    ${response.json()}[order][Disposition]     ${order_despostion}
    #Run Keyword If  '${order_despostion}'=='PICKUP'      Should contain    ${response.json()}[html]        ${Address}
    #Run Keyword If  '${order_despostion}'=='DELIEVRY'      Should Be Equal As Strings    ${response.json()}[order][DeliveryAddressFull]     ${Address}
    #IF '${order_despostion}'=='DELIEVRY'
    IF      "${order_despostion}" == "DELIVERY"
        Should Be Equal As Strings    ${response.json()}[order][DeliveryAddressFull]     ${Address}
    END
    IF      "${order_despostion}" == "PICKUP"
        Should contain    ${response.json()}[html]        ${Address}
    END


#This method is added for BPCA
check_the_order_all_level_special_instructions_in_om_old
    [Documentation]    Keyword that checks the special instructions for order in OM
    [Arguments]	    ${order_id}=OrderId     ${store_name}=DEFAULT_STORE_NAME     ${order_level_special_instructions}=ORDER_LEVEL_SPECIAL_INSTRUCTION_VALUE      ${subitem_level_special_instructions}=SUBITEM_LEVEL_SPECIAL_INSTRUCTION_VALUE	${item_level_special_instructions}=ITEM_LEVEL_SPECIAL_INSTRUCTION_VALUE	${alcartitem_level_special_instructions}=AlACARTEITEM_LEVEL_SPECIAL_INSTRUCTION_VALUE   ${combo_level_special_instructions}=COMBO_LEVEL_SPECIAL_INSTRUCTION_VALUE
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${item_level_special_instructions}    get argument actual value      ${item_level_special_instructions}
    ${subitem_level_special_instructions}    get argument actual value      ${subitem_level_special_instructions}
    ${alcartitem_level_special_instructions}    get argument actual value      ${alcartitem_level_special_instructions}
    ${order_level_special_instructions}    get argument actual value      ${order_level_special_instructions}
    ${combo_level_special_instructions}    get argument actual value      ${combo_level_special_instructions}

    #${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}      store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    # when there is order_level_special_instructions
    IF  '${order_level_special_instructions}'!='None'
    Should Be Equal As Strings    ${response.json()}[order][SpecialInstruction]        ${order_level_special_instructions}
    END
   # when there is combo_level_special_instructions

   ${orderresponse}=     Set Variable       ${response.json()}[order][Items]
   @{instruction_options}=    Create List    ${combo_level_special_instructions}    ${subitem_level_special_instructions}       ${item_level_special_instructions}      ${alcartitem_level_special_instructions}
   FOR  ${instruction_option}       IN      @{instruction_options}
        ${flag}=     Set Variable       false
        IF      '${instruction_option}'!='None'
            FOR    ${item}    IN    @{orderresponse}
                ${key}=     Set Variable       ${item}[instruct]
                Log         ${key}
                IF  '${instruction_option}'== "${key}"
                    ${flag}=     Set Variable       true
                    Exit For Loop
                END
            END
            IF  '${flag}'!='true'
                Fail    Assertion failure: Expected Value:${instruction_option} not found in OM Receipt
            END
        END
   END


check_the_order_all_level_special_instructions_in_om
    [Documentation]    Keyword that checks the special instructions for order in OM
    [Arguments]	    ${order_id}=OrderId     ${store_name}=DEFAULT_STORE_NAME     ${order_level_special_instructions}=ORDER_LEVEL_SPECIAL_INSTRUCTION_VALUE      ${subitem_level_special_instructions}=SUBITEM_LEVEL_SPECIAL_INSTRUCTION_VALUE	${item_level_special_instructions}=ITEM_LEVEL_SPECIAL_INSTRUCTION_VALUE	${alcartitem_level_special_instructions}=AlACARTEITEM_LEVEL_SPECIAL_INSTRUCTION_VALUE   ${combo_level_special_instructions}=COMBO_LEVEL_SPECIAL_INSTRUCTION_VALUE
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${item_level_special_instructions}    get argument actual value      ${item_level_special_instructions}
    ${subitem_level_special_instructions}    get argument actual value      ${subitem_level_special_instructions}
    ${alcartitem_level_special_instructions}    get argument actual value      ${alcartitem_level_special_instructions}
    ${order_level_special_instructions}    get argument actual value      ${order_level_special_instructions}
    ${combo_level_special_instructions}    get argument actual value      ${combo_level_special_instructions}

    #${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}      store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    # when there is order_level_special_instructions
    IF  '${order_level_special_instructions}'!='None'
    Should Be Equal As Strings    ${response.json()}[order][SpecialInstruction]        ${order_level_special_instructions}
    END
   # when there is combo_level_special_instructions

   ${orderresponse}=     Set Variable       ${response.json()}[order][Items]
   @{instruction_options}=    Create List    ${combo_level_special_instructions}    ${subitem_level_special_instructions}       ${item_level_special_instructions}      ${alcartitem_level_special_instructions}
   FOR  ${instruction_option}       IN      @{instruction_options}
        ${flag}=     Set Variable       false
        ${type} =       Evaluate    type($instruction_option)

        IF      """DotDict""" in """${type}"""
            Log         It is of type dictionary
            check_the_order_special_instruction_for_multiple_existence      ${orderresponse}        ${instruction_option}
        ELSE IF         """class 'str'""" in """${type}"""
            Log         It is of type string
            check_the_order_special_instruction_for_single_existence      ${orderresponse}        ${instruction_option}
        END
   END


#below method is not meant for calling directly
check_the_order_special_instruction_for_multiple_existence
    [Documentation]    This keyword checks the occurrence of a special instruction multiple times
    [Arguments]	       ${orderresponse}=         ${instruction_option}=
    Log     ${orderresponse}
    Log     ${instruction_option}
    FOR     ${instruction}      IN      @{instruction_option}
        Log         ${instruction}
        ${value}=    Get From Dictionary    ${instruction_option}    ${instruction}
        Log         ${value}
        ${counter} =        Set Variable        0
        FOR    ${item}    IN    @{orderresponse}
            ${key}=     Set Variable       ${item}[instruct]
            Log     ${key}
            IF  '${instruction}'== "${key}"
                ${counter} =        Evaluate    ${counter} + 1
            END
        END
        IF  ${counter}!=${value}
            Fail    Assertion failure: Expected Instruction:"${instruction}" found ${counter} times in OM Receipt but was expected to be found ${value} times
        END
    END

#below method is not meant for calling directly
check_the_order_special_instruction_for_single_existence
    [Documentation]    This keyword checks the occurrence of a special instruction multiple times
    [Arguments]	       ${orderresponse}=         ${instruction_option}=
    Log     ${orderresponse}
    Log     ${instruction_option}
    ${flag}=     Set Variable       false
    IF      '${instruction_option}'!='None'
        FOR    ${item}    IN    @{orderresponse}
            ${key}=     Set Variable       ${item}[instruct]
            Log         ${key}
            IF  '${instruction_option}'== "${key}"
                ${flag}=     Set Variable       true
                Exit For Loop
            END
        END
        IF  '${flag}'!='true'
            Fail    Assertion failure: Expected Value:${instruction_option} not found in OM Receipt
        END
    END


verify_key_contains_expected_value_in_om_order_receipt_response
    [Documentation]    Keyword that verify if OM response contains the expected value for a key
    [Arguments]	       ${order_id}=order_id         ${store_name}=DEFAULT_STORE_NAME     ${key}=None      ${expected_value}=None    ${ignore_specific_text_optional}=none
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${key}     get argument actual value      ${key}
    ${expected_value}     get argument actual value      ${expected_value}

#    IF      ${is_price_without_currency}
#        ${expected_value} =       Replace String Using Regexp     ${expected_value}      [^\\d.]         ${EMPTY}
#    END

    IF      "${ignore_specific_text_optional}"!="none"
        ${ignore_specific_text_optional}      get argument actual value      ${ignore_specific_text_optional}
        ${expected_value} =           Remove String      ${expected_value}          ${ignore_specific_text_optional}
        ${expected_value} =       Strip String          ${SPACE}${expected_value}${SPACE}
    END
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}      store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    ${actual_value}         Get Value From Json           ${response.json()}       $..${key}
    Log         ${actual_value}
    Log         ${actual_value}[0]
    ${match}    Set Variable        False
#	IF      ${is_price_without_currency}
#	    ${match}    Run Keyword And Return Status   should be equal as numbers     ${actual_value}[0]     ${expected_value}
#	ELSE
#	    ${match}    Run Keyword And Return Status   should be equal     ${actual_value}[0]     ${expected_value}
#	END
    ${match}    Run Keyword And Return Status   should be equal     ${actual_value}[0]     ${expected_value}
    IF      not ${match}
        ${match}    Run Keyword And Return Status   should be equal as numbers     ${actual_value}[0]     ${expected_value}
    END

    IF      not ${match}
        Fail    Assertion failure: Actual Value:${actual_value}[0] Expected Value:${expected_value} are not equal
    END


## created for HBUS
verify_expected_html_text_in_om
    [Documentation]    Keyword that checks the presence of any html text in OM order reciept
    [Arguments]	    ${order_id}=OrderId     ${store_name}=DEFAULT_STORE_NAME     ${expected_text}=OM_RECIEPT_EXPECTED_HTML_TEXT  ${is_present_status}=true      ${ignore_specific_text_optional}=none
    ${order_id}     get argument actual value      ${order_id}
    ${store_name}     get argument actual value      ${store_name}
    ${is_present_status}    get argument actual value      ${is_present_status}
    ${expected_text}    get argument actual value      ${expected_text}

    #${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    orderId=${order_id}   tenant=${TENANT_ID}      store=${store_name}     cultureUI=${null}       bIncJson=${true}       bIncHtml=${true}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/OrderReceipt     headers=${headers}       json=${body}

    IF      "${ignore_specific_text_optional}"!="none"
        ${ignore_specific_text_optional}      get argument actual value      ${ignore_specific_text_optional}
        ${expected_text} =           Remove String      ${expected_text}          ${ignore_specific_text_optional}
        ${expected_text} =       Strip String          ${SPACE}${expected_text}${SPACE}
    END

    Should Be Equal As Numbers        200      ${response.status_code}
    Run Keyword If  ${is_present_status}      should contain    ${response.json()}[html]        ${expected_text}
    Run Keyword If  not ${is_present_status}      should not contain    ${response.json()}[html]        ${expected_text}


change_product_availability_status_in_om
    [Documentation]    Keyword that changes the avaliability of a product or combo or modifier in OM
    [Arguments]     ${store_name}=DEFAULT_STORE_NAME     ${sku}=DEFAULT_PRODUCT_SKU     ${type}=Product      ${status_to_change}=AVAILABLE      ${disposition}=DELIVERY
    ${store_name}     get argument actual value      ${store_name}
    ${sku}     get argument actual value      ${sku}
    ${type}     get argument actual value      ${type}
    ${status_to_change}     get argument actual value      ${status_to_change}
    ${disposition}     get argument actual value      ${disposition}

    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${body}=    Create Dictionary    tenant=${TENANT_ID}      store=${store_name}     sku=${sku}       status=${status_to_change}      classification=${type}        disposition=${disposition}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OM_URL}/api/TestE2E/ProductAvailabilityUpdate     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}


# Driver app APIs
create_driver_om
    [Documentation]    Creates new driver in OM
    [Arguments]	    ${tenant_name}=TENANT_PCSV          ${driver_om_url}=OM_URL_PCSV        ${store_name}=DEFAULT_STORE_NAME     ${driver_name}=DEFAULT_DRIVER_NAME          ${driver_email}=DEFAULT_DRIVER_EMAIL        ${driver_password}=DEFAULT_DRIVER_PASSWORD         ${IsEmailDeliverable}=EMAIL_DELIVERABLE_DEFAULT_VALUE
    ${tenant_name}     get argument actual value      ${tenant_name}
    ${driver_om_url}     get argument actual value      ${driver_om_url}
    ${store_name}     get argument actual value      ${store_name}
    ${driver_name}     get argument actual value      ${driver_name}
    ${driver_email}    get argument actual value      ${driver_email}
    ${driver_password}    get argument actual value      ${driver_password}
    ${IsEmailDeliverable}    get argument actual value      ${IsEmailDeliverable}

    ${headers}=     Create Dictionary       x-api-key=${OM_KEY}
    ${model}=       Create Dictionary       name=${driver_name}         Email=${driver_email}       IsActive=${true}            IsCourier=${true}           IsEmailDeliverable=${IsEmailDeliverable}         IsPermanentPassword=${true}             Password=${driver_password}         VehicleType=own             OwnVehicleType=car           PhotoUrl=${null}
    ${body}=    Create Dictionary    tenant=${tenant_name}      store=${store_name}       model=${model}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${driver_om_url}/api/TestE2E/CreateDriver     headers=${headers}       json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings          ${response.json()}[success]        True



#######################   OCC Templates   #######################

check_the_order_status_in_occ
    [Documentation]    Keyword that checks the order status in OCC
	[Arguments]	    ${order_id}=OrderId     ${order_status}=ORDER_STATUS_OPEN       ${order_status_details}=None       ${IS_FUTURE_ORDER_Optional}=None     ${DISPOSITION_Optional}=None
    ${order_id}     get argument actual value      ${order_id}
    ${order_status}    get argument actual value      ${order_status}
    ${order_status_details}    get argument actual value      ${order_status_details}
    ${DISPOSITION_Optional}    get argument actual value      ${DISPOSITION_Optional}
    ${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OCC_BASE_URL}/api/automation/order     params=${params}      headers=${headers}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[0][status]        ${order_status}
    Run Keyword If  '${IS_FUTURE_ORDER_Optional}'!='None'      Should Be Equal As Strings    ${response.json()}[0][is_future_order]        ${IS_FUTURE_ORDER_Optional}
    Run Keyword If  '${DISPOSITION_Optional}'!='None'      Should Be Equal As Strings    ${response.json()}[0][disposition]        ${DISPOSITION_Optional}
    IF      "${order_status_details}"!="None"
        ${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
        ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
        ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OCC_BASE_URL}/api/automation/orderproperty     params=${params}      headers=${headers}
        Should Be Equal As Numbers        200      ${response.status_code}
        #Set Variable  ${continue_loop}  ${True}
        #WHILE       ${continue_loop}        limit=20
        FOR    ${index}    IN RANGE    25
            ${exit_loop} =      Set Variable    False
            ${name} =       Set Variable    ${response.json()}[${index}][name]
            Log         ${name}
            IF      "${name}"=="dmOrderStatus"
                Should Be Equal As Strings    ${response.json()}[${index}][value]        ${order_status_details}
                ${exit_loop} =      Set Variable      True
                Log     ${exit_loop}
            END
            Log     ${exit_loop}
            Exit For Loop IF    "${exit_loop}"=="True"
        END
    END


check_the_user_details_for_order_in_occ
    [Documentation]    Keyword that checks the user details for order in OCC
	[Arguments]	     ${order_id}=OrderId     ${customer_name}=CUSTOMER_NAME       ${customer_email}=CUSTOMER_EMAIL       ${customer_phone_number}=CUSTOMER_PHONE_NUMBER
    ${order_id}     get argument actual value      ${order_id}
    ${customer_name}    get argument actual value      ${customer_name}
    ${customer_email}    get argument actual value      ${customer_email}
    ${customer_phone_number}    get argument actual value      ${customer_phone_number}
    ${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OCC_BASE_URL}/api/automation/order     params=${params}      headers=${headers}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[0][customer_name]        ${customer_name}
    Should Be Equal As Strings    ${response.json()}[0][customer_email]        ${customer_email}
    Should Be Equal As Strings    ${response.json()}[0][customer_phone]        ${customer_phone_number}


check_pos_details_for_order_in_occ
    [Documentation]    Keyword that checks the order status in OCC
	[Arguments]	    ${order_id}=OrderId     ${pos_order_id}=POS_ORDER_ID
    ${order_id}     get argument actual value      ${order_id}
    ${pos_order_id}    get argument actual value      ${pos_order_id}
    ${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OCC_BASE_URL}/api/automation/order     params=${params}      headers=${headers}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[0][pos_order_id]        ${pos_order_id}


check_the_payment_status_in_occ
    [Documentation]    Keyword that checks the payment status in OCC
    [Arguments]     ${order_id}=OrderId     ${payment_type}=PAYMENT_TYPE_CASH       ${payment_status}=PAYMENT_STATUS_LATER      ${payment_provider_optional}=None
    ${order_id}     get argument actual value      ${order_id}
    ${payment_type}    get argument actual value      ${payment_type}
    ${payment_status}    get argument actual value      ${payment_status}
    ${payment_provider_optional}    get argument actual value      ${payment_provider_optional}

    ${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OCC_BASE_URL}/api/automation/orderpayment     params=${params}      headers=${headers}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[0][type]        ${payment_type}
    Should Be Equal As Strings    ${response.json()}[0][status]        ${payment_status}
    Run Keyword If  '${payment_provider_optional}'!='None'      Should Be Equal As Strings    ${response.json()}[0][pay_provider_type]        ${payment_provider_optional}


check_menu_version_id_and_label_for_store_name_in_occ
	[Documentation]    Keyword that checks the menu version id and label for a store in OCC
	[Arguments]	     ${store_name}=DEFAULT_STORE_NAME	${menu_version_id}=DEFAULT_MENU_VERSION_ID	${menu_version_label}=DEFAULT_MENU_VERSION_LABEL
    ${store_name}     get argument actual value      ${store_name}
    ${menu_version_id}     get argument actual value      ${menu_version_id}
    ${menu_version_label}     get argument actual value      ${menu_version_label}


    ${params}=      Create Dictionary       name=${store_name}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OCC_BASE_URL}/api/automation/storemenu     params=${params}      headers=${headers}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[0][version_id]        ${menu_version_id}
    Should Be Equal As Strings    ${response.json()}[0][version_label]        ${menu_version_label}



check_cart_subtotal_and_total_in_occ
    [Documentation]    Keyword that checks subtotal and total in OCC
    [Arguments]     ${order_id}=OrderId     ${subtotal}=TEMP_CART_SUBTOTAL_VALUE       ${total}=TEMP_CART_TOTAL_VALUE       ${discount}=None        ${vat}=None     ${delivery_price}=None      ${tax}=None
    ${order_id}     get argument actual value      ${order_id}
    ${subtotal}     get argument actual value      ${subtotal}
    ${total}     get argument actual value      ${total}
    ${discount}     get argument actual value      ${discount}
    ${vat}     get argument actual value      ${vat}
    ${tax}     get argument actual value      ${tax}
    ${delivery_price}     get argument actual value      ${delivery_price}

    ${params}=      Create Dictionary       id=${order_id}     tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OCC_BASE_URL}/api/automation/order     params=${params}      headers=${headers}

    ${subtotal} =       Replace String Using Regexp     ${subtotal}      [^\\d.]         ${EMPTY}
    ${subtotal} =       Strip String          ${SPACE}${subtotal}${SPACE}
    ${total} =       Replace String Using Regexp     ${total}      [^\\d.]         ${EMPTY}
    ${total} =       Strip String          ${SPACE}${total}${SPACE}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Numbers    ${response.json()}[0][subtotal]        ${subtotal}
    Should Be Equal As Numbers    ${response.json()}[0][total]        ${total}
    IF      "${discount}"!="None"
        IF      "${vat}"!="None"
            ${total_discount} =         EVALUATE        ${discount}+${vat}
            Should Be Equal As Numbers    ${response.json()}[0][discount_total]        ${total_discount}
        ELSE
            Should Be Equal As Numbers    ${response.json()}[0][discount_total]        ${discount}
        END
    END
    Run Keyword If  '${delivery_price}'!='None'      Should Be Equal As Numbers    ${response.json()}[0][delivery_charge]        ${delivery_price}
    Run Keyword If  '${tax}'!='None'      Should Be Equal As Numbers    ${response.json()}[0][order_tax]        ${tax}



change_the_store_status_in_occ
    [Documentation]    Keyword that changes store status in OCC
    [Arguments]     ${store_name}=DEFAULT_STORE_NAME     ${status}=TEMP-INACTIVE
    ${store_name}     get argument actual value      ${store_name}
    ${status}     get argument actual value      ${status}

    ${params}=      Create Dictionary       tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${body}=    Create Dictionary    name=${store_name}   status=${status}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OCC_BASE_URL}/api/automation/storestatus     params=${params}      headers=${headers}        json=${body}
    Should Be Equal As Numbers        200      ${response.status_code}


change_the_refund_config_in_occ
    [Documentation]    Keyword that changes refund in OCC
    [Arguments]     ${value}=true
    ${value}     get argument actual value      ${value}

    ${params}=      Create Dictionary       tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${body}=    Create Dictionary    name=isPaymentCancellationEnabledForOrderCancellation   value=${value}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OCC_BASE_URL}/api/automation/tenantpropertyupdate     params=${params}      headers=${headers}        json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}

check_recommender_property_in_occ
    [Documentation]    Keyword that checks external property value in OCC
    [Arguments]	       ${property}=None
    ${property}     get argument actual value      ${${property}}
	${response}=     Wait Until Keyword Succeeds     10 sec      2 sec   GET         ${OCC_URL}${OCC_EXTERNAL_PROPERTIES}
	${response}=     Set Variable       ${response.json()}[ArrayList]
    FOR    ${item}    IN    @{response}
        ${key}=     Set Variable       ${item}[key]
        IF  "${key}" == "${property}"
            ${property_value}=   Set Variable    ${item}[value]
        END
    END
    [Return]  ${property_value}

update_store_hours_and_max_future_order_time_in_occ
    [Documentation]    Keyword to update the store hours for a day and the maximum future order for a store and a disposition
    [Arguments]     ${store_name}=DEFAULT_STOREID_VALUE           ${disposition}=DEFAULT_DISPOSITION_VALUE        ${max_future_order_time}=DEFAULT_MAX_FURTURE_ORDER_TIME         ${day}=DEFAULT_STORE_HOURS_CONFIG_DAY      ${open_time}=DEFAULT_STORE_HOURS_OPEN_TIME           ${close_time}=DEFAULT_STORE_HOURS_CLOSE_TIME
    ${store_name}     get argument actual value      ${store_name}
    ${disposition}     get argument actual value      ${disposition}
    ${max_future_order_time}     get argument actual value      ${max_future_order_time}
    ${day}     get argument actual value      ${day}
    ${open_time}     get argument actual value      ${open_time}
    ${close_time}     get argument actual value      ${close_time}

    ${params}=      Create Dictionary       tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${body}=    Create Dictionary    name=${store_name}   disposition=${disposition}    max_future_order_time=${max_future_order_time}      day=${day}      open=${open_time}        close=${close_time}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OCC_BASE_URL}/api/automation/storehour     params=${params}      headers=${headers}        json=${body}

    Should Be Equal As Numbers        200      ${response.status_code}

change_the_product_availability_in_occ
    [Documentation]    Keyword that changes product availability in OCC
    [Arguments]     ${store_name}=DEFAULT_STORE_NAME     ${disposition}=PICKUP     ${sku}=DEFAULT_PRODUCT_SKU    ${status_to_change}=AVAILABLE
    ${store_name}     get argument actual value      ${store_name}
    ${disposition}     get argument actual value      ${disposition}
    ${sku}     get argument actual value      ${sku}
    ${status_to_change}     get argument actual value      ${status_to_change}

    ${params}=      Create Dictionary       tenant=${OCC_TENANT}        env=${OCC_ENV}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${body}=    Create Dictionary    store=${store_name}   disposition=${disposition}   id=${sku}   availability=${status_to_change}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OCC_BASE_URL}/api/automation/storeprodavailability     params=${params}      headers=${headers}        json=${body}
    Should Be Equal As Numbers        200      ${response.status_code}


refund_and_cancel_the_order_in_occ
    [Documentation]    Keyword that refund and cancel the order in OCC
    [Arguments]     ${order_id}=TEMP_ORDER_ID
    ${order_id}     get argument actual value      ${order_id}

    ${params}=      Create Dictionary       tenant=${OCC_TENANT}        env=${OCC_ENV}        id=${order_id}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OCC_BASE_URL}/api/automation/orderrefund     params=${params}      headers=${headers}
    Should Be Equal As Numbers        200      ${response.status_code}


fire_the_order_using_occ
    [Documentation]    Keyword that fire the order in OCC
    [Arguments]     ${order_id}=TEMP_ORDER_ID
    ${order_id}     get argument actual value      ${order_id}

    ${params}=      Create Dictionary       tenant=${OCC_TENANT}        env=${OCC_ENV}        id=${order_id}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OCC_BASE_URL}/api/automation/orderfire    params=${params}      headers=${headers}
    Should Be Equal As Numbers        200      ${response.status_code}

generate_new_token_for_store_using_occ
    [Documentation]    Keyword that generate new token in occ
    [Arguments]	        ${store_name}=NONDEFAULT_SHOPTOKEN_CONFIG_STORENAME_VALUE
    ${store_name}     get argument actual value      ${store_name}

    ${params}=      Create Dictionary       env=${OCC_ENV}   tenant=${OCC_TENANT}      storeName=${store_name}     newToken=true
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OCC_BASE_URL}/api/automation/CakeBookTokenGenerate    params=${params}      headers=${headers}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[storeName]       ${store_name}
    Should Not Be Empty    ${response.json()}[token]


get_token_for_store_using_occ
    [Documentation]    Keyword that generate new token in occ
    [Arguments]	    ${store_name}=NONDEFAULT_SHOPTOKEN_CONFIG_STORENAME_VALUE       ${store_token_temp_variable_name}=TEMP_SHOP_TOKEN_VALUE
    ${store_name}     get argument actual value      ${store_name}
    Log     ${store_name}
    ${params}=      Create Dictionary       env=${OCC_ENV}   tenant=${OCC_TENANT}      storeName=${store_name}
    ${headers}=     Create Dictionary       x-api-key=${OCC_API_KEY}
    ${response}=        Wait Until Keyword Succeeds     10 sec      2 sec   POST         ${OCC_BASE_URL}/api/automation/CakeBookTokenGenerate    params=${params}      headers=${headers}

    Should Be Equal As Numbers        200      ${response.status_code}
    Should Be Equal As Strings    ${response.json()}[storeName]       ${store_name}
    Should Not Be Empty    ${response.json()}[token]
    Set global variable    ${store_token_temp_variable_name}         ${response.json()}[token]


    Should Be Equal As Numbers        200      ${response.status_code}


###### Generic methods ######
verify_baseline_and_current_jsons_are_identical
    [Documentation]         keyword to select an element from list based on index
    [Arguments]	    ${file_to_compare}=Default_i18       ${current_json_path}=DEFAULT_LANG_i18N
    ${current_json_path}      get argument actual value     ${current_json_path}

    ${tenant_path}              SET VARIABLE            tenants

    IF      "${file_to_compare}"=="brand_config"
        ${folder_name} =    Set Variable        config
        ${file_to_compare} =    Set Variable        config
    ELSE
        ${folder_name} =    Set Variable        fe_repo
    END

    ${is_i18_file}       Evaluate        "_i18" in """${file_to_compare}"""
    IF      ${is_i18_file}
        ${file_to_compare}      Remove String        ${file_to_compare}       _i18
    END

    ${compared_data}     ${compared_differences}=        fetch_i18_files       True            ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}${/}${folder_name}         ${FE_REPO}          ${current_json_path}        ${file_to_compare}     ${EXECDIR}${/}${tenant_path}${/}${tenant}${/}data${/}${environment}

    ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${compared_differences}

    IF      not ${isEmpty}
            Fail    Assertion failure: Baseline and current JSONs are not equal. Differences: ${compared_differences}
    END