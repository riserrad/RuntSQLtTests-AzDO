param(
    # Database info parameters    
    [string]$connectionString,
    [string]$testOrClassName = "",
    
    # Test Result parameters
    [string]$testResultsFileName,
    [string]$queryTimeout
)

if ($testOrClassName -eq "") {
    Invoke-SqlCmd -ConnectionString $connectionString `
    -QueryTimeout $queryTimeout `
    -Query "EXEC tSQLt.RunAll"

    Write-Output "Tests ran successfully. Saving test results to $testResultsFileName"    
}
else {
    Invoke-SqlCmd -ConnectionString $connectionString `
    -QueryTimeout $queryTimeout `
    -Query "EXEC tSQLt.Run '$testOrClassName'"
    
    Write-Output "Tests ran successfully. Saving test results to $testResultsFileName"
}

Invoke-SqlCmd -ConnectionString $connectionString -QueryTimeout $queryTimeout -InputFile ".\GetTestResults.sql" | Select-Object -ExpandProperty XML* | Out-File -FilePath $testResultsFileName -NoNewLine
Write-Output "Finished gathering test results and writing it to $testResultsFileName"