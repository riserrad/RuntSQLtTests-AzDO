param(
    # Database info parameters    
    [string]$connectionString,
    
    # Test Result parameters
    [string]$testResultsFileName,
    [string]$queryTimeout
)

Invoke-SqlCmd -ConnectionString $connectionString -QueryTimeout $queryTimeout -Query "EXEC tSQLt.RunAll"
Write-Output "Tests ran successfully. Saving test results to $testResultsFileName"

Invoke-SqlCmd -ConnectionString $connectionString -QueryTimeout $queryTimeout -InputFile ".\GetTestResults.sql" | Select-Object -ExpandProperty XML* | Out-File -FilePath $testResultsFileName
Write-Output "Finished gathering test results and writing it to $testResultsFileName"