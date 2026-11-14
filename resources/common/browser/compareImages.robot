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
	[Arguments]	${baseline}=None	${ignore_pattern_json_file}=None	${move_tolerance}=None	${comparing_different_size_images}=True
    IF      ${skip_visual_test_step}
        Return From Keyword
    END
    ${baseline}  get argument actual value      ${baseline}
    ${ignore_pattern_json_file}  get argument actual value      ${ignore_pattern_json_file}
    ${move_tolerance}  get argument actual value      ${move_tolerance}
    ${comparing_different_size_images}  get argument actual value      ${comparing_different_size_images}

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
             Compare Images         ${EXECDIR}${/}results${/}${baseline}_current.jpeg             ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg                        move_tolerance=${move_tolerance}        resize_candidate=${comparing_different_size_images}        placeholder_file=${ignore_pattern_json_file}
    END

compare_current_cropped_image_with_the_baseline_image
    [Documentation]     compare known good baseline cropped image with current app. If no baseline is present, then it's created. Here x_offset is the distance of starting coordinate from leftmost point and y_offset is the distance of starting coordinate from topmost point. width and height are thewith and height of the image to be captured
	[Arguments]	${baseline}=None	${ignore_pattern_json_file}=None	${move_tolerance}=None	${comparing_different_size_images}=True     ${x_offset}=0        ${y_offset}=0        ${width}=250       ${height}=250
    IF      ${skip_visual_test_step}
        Return From Keyword
    END
    ${baseline}  get argument actual value      ${baseline}
    ${ignore_pattern_json_file}  get argument actual value      ${ignore_pattern_json_file}
    ${move_tolerance}  get argument actual value      ${move_tolerance}
    ${comparing_different_size_images}  get argument actual value      ${comparing_different_size_images}
    ${x_offset}  get argument actual value      ${x_offset}
    ${y_offset}  get argument actual value      ${y_offset}
    ${width}  get argument actual value      ${width}
    ${height}  get argument actual value      ${height}

    ${basline_exists}       Run Keyword and Return Status       File Should Exist       ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg
    Log to Console          ${basline_exists}

    IF     not ${basline_exists}
            ${path}=       SET VARIABLE         ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg
            #${crop} =    Create Dictionary      x=${50}        y=${100}       width=${400}       height=${550}
            ${crop} =    Create Dictionary      x=${x_offset}        y=${y_offset}       width=${width}       height=${height}
            Take screenshot            filename=${path}         fullPage=True       fileType=jpeg       crop=${crop}
            Log         Baseline image not available. Created one!!!
    ELSE
             ${path}=       SET VARIABLE      ${EXECDIR}${/}results${/}${baseline}_current.jpeg

             ${crop} =    Create Dictionary      x=${x_offset}        y=${y_offset}       width=${width}       height=${height}
             Take screenshot            filename=${path}         fullPage=True      fileType=jpeg       crop=${crop}

             IF     '${ignore_pattern_json_file}'!='None'
                    ${ignore_pattern_json_file}         SET VARIABLE        ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}mask_patterns${/}${ignore_pattern_json_file}.json
             END
             Compare Images         ${EXECDIR}${/}results${/}${baseline}_current.jpeg             ${EXECDIR}${/}${global_tenant_path}${/}${tenant}${/}data${/}${environment}${/}baseline_screenshots${/}${baseline}.jpeg                        move_tolerance=${move_tolerance}        resize_candidate=${comparing_different_size_images}        placeholder_file=${ignore_pattern_json_file}
    END



