Write-Host "From PowerShell script"

param(
    [Parameter(Mandatory=$true)] $TestRunId,
    [Parameter(Mandatory=$true)] $Tenant,
    [Parameter(Mandatory=$true)] $Environment,
    [Parameter(Mandatory=$true)] $OS,
    [Parameter(Mandatory=$true)] $ProjectToken,
    [Parameter(Mandatory=$true)] $Action
)

Write-Host "Test run id from parameter is $TestRunId"
Write-Host "Tenant from parameter is $Tenant"
Write-Host "ENVIRONMENT from parameter is $Environment"
Write-Host "OS from parameter is $OS"
Write-Host "Project Token from parameter is $ProjectToken"
Write-Host "Last parameter is $Action"

$TestRunId_Local = $TestRunId

if ($TestRunId -eq 'Default') {
    Set-Location ..
    Set-Location config_files
    Write-Host "Inside the condition"
    $TestRunId_Local = (Get-Content -Raw -Path environment-map.yaml | ConvertFrom-Yaml)[$Tenant][$Environment][$OS].testRunId
    Write-Host "NEWWWWWWWWWWW"
    $env:TestRunId_Local = (Get-Content -Raw -Path environment-map.yaml | ConvertFrom-Yaml)[$Tenant][$Environment][$OS].testRunId
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
