param (
    # Database info parameters
    [Parameter(Mandatory=$true)]
    [string]$connectionString,
    [Parameter(Mandatory=$true)]
    [string]$queryTimeout = "60",
    
    # Test Result parameters
    [string]$rootOutput = "out",
    [string]$testResultsFileName = "TestResults.xml",
    
    # Code Coverage parameters
    [string]$enableCodeCoverage = "false",
	[string]$enableAzure = "false",
    [string]$openCoverSourceFolder = "OpenCoverSourceFiles",
    [string]$coberturaFileName = "Cobertura.xml",
    [string]$htmlReportsOutput = "AzurePipelines",
    
    [string]$workingDirectory
)

if(!$workingDirectory) {
    $workingDirectory = $PSScriptRoot
}

# Not in use yet due to issue on SQLCover (https://github.com/GoEddie/SQLCover/issues/32) and intermitent issue to download ReportGenerator
# Dependencies are then embeded to the extension VSIX
# . .\InstallDependencies.ps1 -installDirectory $workingDirectory

. .\Install-Dependencies.ps1

$ErrorActionPreference = "Continue"

If([System.IO.Path]::IsPathRooted($rootOutput)){
    If(!(Test-Path $rootOutput)){
        New-Item -ItemType Directory -Path $rootOutput -Force
    }
}
Else {
    $rootOutput = Join-Path -Path $workingDirectory -ChildPath $rootOutput
    If(!(Test-Path $rootOutput)){
        New-Item -ItemType Directory -Path $rootOutput -Force
    }
}

Write-Output "rootOutput set to $rootOutput"

If([System.IO.Path]::IsPathRooted($testResultsFileName)){
   Write-Output "No need to transform $testResultsFileName" 
} else {
    $testResultsFileName = Join-Path -Path $rootOutput -ChildPath $testResultsFileName
    Write-Output "testResultsFileName set to $testResultsFileName"
}

$openCoverSourceFolder = Join-Path -Path $rootOutput -ChildPath $openCoverSourceFolder
Write-Output "openCoverSourceFolder set to $openCoverSourceFolder"

Write-Output "`n##### Initializing process #####`n"

if ($enableCodeCoverage -eq "false") {
    . .\Invoke-tSQLtTests.ps1 -connectionString $connectionString -rootOutput $rootOutput -testResultsFileName $testResultsFileName -queryTimeout $queryTimeout
}
else {
    $openCoverXmlFile = Join-Path -Path $openCoverSourceFolder -ChildPath "Coverage.opencover.xml"
    Write-Output "openCoverXmlFile set to $openCoverXmlFile"
    
    $coberturaFileName = Join-Path -Path $rootOutput -ChildPath $coberturaFileName
    Write-Output "coberturaFilename set to $coberturaFileName"

    $htmlReportsOutput = Join-Path -Path $rootOutput -ChildPath $htmlReportsOutput
    Write-Output "htmlReportsOutput set to $htmlReportsOutput"
    
    . .\Invoke-tSQLtTests-WithCodeCoverage.ps1 -connectionString $connectionString -rootOutput $rootOutput -testResultsFileName $testResultsFileName -openCoverSourceFolder $openCoverSourceFolder -openCoverXmlFile $openCoverXmlFile -coberturaFileName $coberturaFileName -htmlReportsOutput $htmlReportsOutput -queryTimeout $queryTimeout -enableAzure $enableAzure
}