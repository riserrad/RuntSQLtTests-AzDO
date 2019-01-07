param(
    # [string]$installDirectory = $PSScriptRoot
)

#if(!(Get-Module SqlServer)){
#    Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber
#}

# $packagesDirectory = Join-Path -Path $installDirectory -ChildPath "packages"

# Write-Output "Registering NuGet.org and installing dependencies..."

# Find-PackageProvider -Name NuGet | Install-PackageProvider -Force
# Register-PackageSource -Name nuget.org -Location https://www.nuget.org/api/v2 -ProviderName NuGet -Trusted -Force

# Write-Output "Installing SQLCover..."
# Install-Package GOEddie.SQLCover -RequiredVersion 0.4.1 -Destination $packagesDirectory

# Write-Output "Installing ReportGenerator..."
# Install-Package ReportGenerator -RequiredVersion 4.0.4 -Destination $packagesDirectory

# Write-Output "Installing OpenCoverToCoberturaConverter..."
# Install-Package OpenCoverToCoberturaConverter -RequiredVersion 0.3.4 -Destination $packagesDirectory

# Write-Output "Finished installing dependencies."


$majorPSVersion = $PSVersionTable.PSVersion.Major

if($majorPSVersion -gt 4)
{
    $confirmSqlServer = Get-Module SqlServer -ListAvailable;
    if(!$confirmSqlServer)
    {
		Ensure-SQLTools $majorPSVersion
    }
    else
    {
        #Write-Verbose "SqlServer module already loaded"
		Write-Host "SqlServer module already loaded"
    }
}
else
{
    $confirmSQLPS = Get-Module SQLPS -ListAvailable;
    if(!$confirmSQLPS)
    {
		Ensure-SQLTools $majorPSVersion
    }
    else
    {
        Write-Verbose "SQLPS module already loaded"
    }
}