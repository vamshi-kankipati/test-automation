*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
convert_the_string_to_a_specified_case_and_save_it_in_a_variable
    [Documentation]         Converts the string to upper or lower case
	[Arguments]	${string}=string            ${case}=upper       ${variable_to_store}=variable
    ${string}  get argument actual value      ${string}
    ${case}  get argument actual value      ${case}

    ${updated_case}      Convert To Lower Case          ${case}
    IF         "${updated_case}"=="upper"
        ${temp} =	    Convert To Upper Case	${string}
    ELSE IF             "${updated_case}"=="lower"
        ${temp} =	    Convert To Lower Case	    ${string}
    END
    Set global variable    ${${variable_to_store}}     ${temp}

