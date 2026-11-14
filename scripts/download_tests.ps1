Write-Host "From PowerShell script"
$TestRunId=$args[0]
$Tenant=$args[1]
$Environment=$args[2]
$OS=$args[3]
$ProjectToken=$args[4]
$Action=$args[5]

Write-Host "Test run id from parameter is $TestRunId"
Write-Host "Tenant from parameter is $Tenant"
Write-Host "ENVIRONMENT from parameter is $Environment"
Write-Host "OS from parameter is $OS"
Write-Host "Project Token from parameter is $ProjectToken"
Write-Host "Last parameter is $Action"

$TestRunId_Local = $TestRunId
Write-Host "TestRunId_Local is $TestRunId_Local"

if ($TestRunId -eq 'Default') {
    Write-Host 'TestRunId is Default'
    if ($Tenant -eq 'jb-ph-mobile') {
        Write-Host 'Tenant is jb-ph-mobile'
        if ($Environment -eq 'qa-b') {
            Write-Host 'Environment is qa-b'
            if ($OS -eq 'iOS') {
                Write-Host 'OS is iOS'
                $TestRunId_Local = 632303
            } elseif ($OS -eq 'Android') {
                Write-Host 'OS is Android'
                $TestRunId_Local = 632303
            }
        }
    } elseif ($Tenant -eq 'grn-ph-mobile') {
        Write-Host 'Tenant is grn-ph-mobile'
    }
} else {
    Write-Host 'Proper TestRunId is provided'
}

Write-Host "Final test run id is $TestRunId_Local"

Set-Location ..

if ($Action -eq 'download') {
    Write-Host "Downloading tests"
    hiptest-publisher -c hiptest-publisher.conf --token=$ProjectToken --filename-pattern=%s.robot --test-run-id $TestRunId_Local --without=actionwords -v
}

if ($Action -eq 'push') {
    Write-Host "Pushing results"
    Get-Location
    hiptest-publisher --config-file hiptest-publisher.conf --token=$ProjectToken --push results/output.xml --test-run-id $TestRunId_Local --push-format robot
}
