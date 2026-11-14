*** Settings ***
Documentation

# ----To enable auto suggestion and go to declaration(command+enter key), please uncomment initializeSuite resource file and commonKeyordsMobile or Browser resource file depending on the platform----
# ----Please ensure those lines are commented out, when you check in the files----
#Resource	../resources/common/commonKeywordsMobile.robot
#Resource	../resources/common/initializeSuite.robot
#Resource	../resources/common/commonKeywordsBrowser.robot

*** Keywords ***
compare_current_page_with_baseline_image
    [Documentation]     compare knonw good baseline image with current app. If no basline is present, then it's created
    ...                 ${move_tolerance}: Default 1; use up to 5 for expected minor UI shifts.
    ...                 ${threshold}: Default 0.0005; use up to 0.02 (2%) for acceptable visual differences.
	[Arguments]	    ${platform_specific_test_step}=none      ${baseline}=None	${ignore_pattern_json_file}=None
	...             ${move_tolerance}=1 	${comparing_different_size_images}=True    ${mobile_os_specific_test_step}=none
	...             ${threshold}=0.0005
    IF      ${skip_visual_test_step}
        Return From Keyword
    END
    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${baseline}  get argument actual value      ${baseline}
        ${ignore_pattern_json_file}  get argument actual value      ${ignore_pattern_json_file}
        ${move_tolerance}  get argument actual value      ${move_tolerance}
        ${comparing_different_size_images}  get argument actual value      ${comparing_different_size_images}
        ${threshold}  get argument actual value      ${threshold}

        ${basline_exists}       Run Keyword and Return Status       File Should Exist       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg
        Log to Console          ${basline_exists}

        IF     not ${basline_exists}
                ${path}=       SET VARIABLE         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg
                Take screenshot            filename=${path}         fullPage=True       fileType=jpeg
                Log         Baseline image not available. Created one!!!
        ELSE
                 ${path}=       SET VARIABLE      ${EXECDIR}${/}results${/}${baseline}_current.jpeg
                 Take screenshot            filename=${path}         fullPage=True      fileType=jpeg

                 IF     '${ignore_pattern_json_file}'!='None'
                        ${ignore_pattern_json_file}         SET VARIABLE        ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}mask_patterns${/}${ignore_pattern_json_file}.json
                 END
                 Compare Images         ${EXECDIR}${/}results${/}${baseline}_current.jpeg             ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg
                 ...                    move_tolerance=${move_tolerance}    threshold=${threshold}    resize_candidate=${comparing_different_size_images}        placeholder_file=${ignore_pattern_json_file}
        END
    END

compare_current_cropped_image_with_the_baseline_image
    [Documentation]     compare known good baseline cropped image with current app. If no baseline is present, then it's created. Here web_x_offset is the distance of starting coordinate from leftmost point and web_y_offset is the distance of starting coordinate from topmost point. web_width and web_height are thewith and height of the image to be captured
	[Arguments]     ${platform_specific_test_step}=none 	${baseline}=None	${ignore_pattern_json_file}=None	${move_tolerance}=None	${comparing_different_size_images}=True     ${web_x_offset}=0        ${web_y_offset}=0        ${web_width}=250       ${web_height}=250      ${mobile_left}=        ${mobile_upper}=       ${mobile_right}=       ${mobile_lower}=      ${mobile_os_specific_test_step}=none
    IF      ${skip_visual_test_step}
        Return From Keyword
    END

    IF              "${platform_specific_test_step}"=="none" or "${platform_specific_test_step}"=="${platform}"
        ${baseline}  get argument actual value      ${baseline}
        ${ignore_pattern_json_file}  get argument actual value      ${ignore_pattern_json_file}
        ${move_tolerance}  get argument actual value      ${move_tolerance}
        ${comparing_different_size_images}  get argument actual value      ${comparing_different_size_images}
        ${web_x_offset}  get argument actual value      ${web_x_offset}
        ${web_y_offset}  get argument actual value      ${web_y_offset}
        ${web_width}  get argument actual value      ${web_width}
        ${web_height}  get argument actual value      ${web_height}

        ${basline_exists}       Run Keyword and Return Status       File Should Exist       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg
        Log to Console          ${basline_exists}

        IF     not ${basline_exists}
            ${path}=       SET VARIABLE         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg
            #${crop} =    Create Dictionary      x=${50}        y=${100}       width=${400}       height=${550}
            ${crop} =    Create Dictionary      x=${web_x_offset}        y=${web_y_offset}       width=${web_width}       height=${web_height}
            Take screenshot            filename=${path}         fullPage=True       fileType=jpeg       crop=${crop}
            Log         Baseline image not available. Created one!!!
        ELSE
             ${path}=       SET VARIABLE      ${EXECDIR}${/}results${/}${baseline}_current.jpeg

             ${crop} =    Create Dictionary      x=${web_x_offset}        y=${web_y_offset}       width=${web_width}       height=${web_height}
             Take screenshot            filename=${path}         fullPage=True      fileType=jpeg       crop=${crop}

             IF     '${ignore_pattern_json_file}'!='None'
                    ${ignore_pattern_json_file}         SET VARIABLE        ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}mask_patterns${/}${ignore_pattern_json_file}.json
             END
             Compare Images         ${EXECDIR}${/}results${/}${baseline}_current.jpeg             ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg                        move_tolerance=${move_tolerance}        resize_candidate=${comparing_different_size_images}        placeholder_file=${ignore_pattern_json_file}
        END
    END



