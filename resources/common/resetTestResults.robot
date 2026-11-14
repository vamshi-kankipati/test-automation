*** Settings ***
Documentation

Library         RequestsLibrary

Resource	${EXECDIR}${/}resources${/}common${/}initializeSuite.robot

*** Test Cases ***
reset the test results before the test run
    reset_test_run_results









