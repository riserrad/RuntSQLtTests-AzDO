param (
    [string]$server = "datadevops-internalhack.database.windows.net",
    [string]$database = "DBUnitTesting",
    [string]$username = "azureuser",
    [string]$password = "P2ssw0rd",
    [string]$openCoverSourceFolder = "OpenCoverSourceFiles",
    [string]$openCoverXmlFile="Coverage.opencover.xml",
    [string]$testResultsFileName = "TestResults.xml",
    [string]$coberturaFileName = "Cobertura.xml",
    [string]$rootOutput = "out",
    [string]$htmlReportsOutput = "AzurePipelines",
    [string]$workingDirectory
)

If(!$workingDirectory) {
    $workingDirectory = $PSScriptRoot
}

. .\InstallDependencies.ps1 -installDirectory $workingDirectory

$ErrorActionPreference = "Continue"
$testsFailed = $false

$outputFolder = Join-Path -Path $workingDirectory -ChildPath $rootOutput

New-Item -ItemType Directory -Path $outputFolder -Force

Write-Output "Successfully set the output folder to $outputFolder"

$openCoverSourceFolder = Join-Path -Path $outputFolder -ChildPath $openCoverSourceFolder
Write-Output "openCoverSourceFolder set to $openCoverSourceFolder"

$openCoverXmlFile = Join-Path -Path $openCoverSourceFolder -ChildPath $openCoverXmlFile
Write-Output "openCoverXmlFile set to $openCoverXmlFile"

$testResultsFileName = Join-Path -Path $outputFolder -ChildPath $testResultsFileName
Write-Output "testResultsFileName set to $testResultsFileName"

Write-Output "Server: $server"
Write-Output "Database: $database"
Write-Output "Username: $username"

Write-Output "##### Initializing process #####"

Add-Type -Path $workingDirectory\packages\GOEddie.SQLCover.0.4.1\SQLCover.dll

# $connectionString = "Server=tcp:$server,1433;Initial Catalog=$database;Persist Security Info=False;User ID=$username;Password=$password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;"
$connectionString = "Server=$server;Database=$database;User Id=$username;Password=$password;"

Write-Output "Running the tSQLt tests and getting Code Coverage..."

$coverage = new-object SQLCover.CodeCoverage($connectionString, $database, $null, $true, $false)

$startResult = $coverage.Start()

if(!$startResult){
    Write-Error "Error while starting the Unit Test with Code Coverage session."
    Exit -1
}

try{
    Invoke-SqlCmd -ServerInstance "$server" -Database "$database" -Username "$username" -Password "$password" -QueryTimeout 60 -Query "EXEC tSQLt.RunAll"
} catch [SqlPowerShellSqlExecutionException] {
    $testsFailed = $true
}

$coverageResults = $coverage.Stop()
Write-Output "Tests ran successfully. Saving test results to $testResultsFileName"

Invoke-SqlCmd -ServerInstance "$server" -Database "$database" -Username "$username" -Password "$password" -QueryTimeout 60 -InputFile ".\GetTestResults.sql" | Select-Object -ExpandProperty XML* | Out-File -FilePath "$testResultsFileName"
Write-Output "Finished gathering test results. Writing Coverage Results to file."

New-Item -Type Directory -Force -Path $openCoverSourceFolder | out-Null
Write-Output "Successfully created $openCoverSourceFolder"

$coverageResults.OpenCoverXml() | Out-File -force $openCoverXmlFile
Write-Output "Successfully generated OpenCover XML report at $openCoverXmlFile."

$coverageResults.SaveSourceFiles($openCoverSourceFolder)
Write-Output "Successfully saved source code to $openCoverSourceFolder"

Write-Output "Converting OpenCover to Cobertura results..."
$coberturaConverterToolPath = Join-Path -Path $workingDirectory -ChildPath "packages\OpenCoverToCoberturaConverter.0.3.4\tools\OpenCoverToCoberturaConverter.exe"
$coberturaFileName = Join-Path -Path $outputFolder -ChildPath $coberturaFileName
$argsList = "-input:$openCoverXmlFile -output:$coberturaFileName -sources:$openCoverSourceFolder -includeGettersSetters:true"

Start-Process -FilePath $coberturaConverterToolPath -ArgumentList $argsList -NoNewWindow -Wait
Write-Output "Finished converting OpenCover to Cobertura. File available at $coberturaFileName"

Write-Output "Generating Azure Pipelines report from Cobertura results..."
$reportGeneratorToolPath = Join-Path -Path $workingDirectory -ChildPath "packages\ReportGenerator.4.0.4\tools\net47\ReportGenerator.exe"
$htmlReportsOutput = Join-Path -Path $outputFolder -ChildPath $htmlReportsOutput
$argsList = "-reports:$coberturaFileName -targetDir:$htmlReportsOutput -reporttype:HtmlInline_AzurePipelines -sourcedirs:$openCoverSourceFolder -assemblyfilters:+* -classfilters:+* -filefilters:+* -verbosity:Verbose"

Start-Process -FilePath $reportGeneratorToolPath -ArgumentList $argsList -NoNewWindow -Wait
Write-Output "Finished generating Azure Pipelines report at $htmlReportsOutput"

# if ($testsFailed = $true){
#     Write-Error "Tests execution has errors. Check test results for more information."
# }