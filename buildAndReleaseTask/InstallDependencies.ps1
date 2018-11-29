param(
    [string]$installDirectory = $PSScriptRoot
)

$packagesDirectory = Join-Path -Path $installDirectory -ChildPath "packages"

Write-Output "Registering NuGet.org and installing dependencies..."

Find-PackageProvider -Name NuGet | Install-PackageProvider -Force
Register-PackageSource -Name nuget.org -Location https://www.nuget.org/api/v2 -ProviderName NuGet -Trusted -Force

Write-Output "Installing SQLCover..."
Install-Package GOEddie.SQLCover -RequiredVersion 0.4.1 -Destination $packagesDirectory

Write-Output "Installing ReportGenerator..."
Install-Package ReportGenerator -RequiredVersion 4.0.4 -Destination $packagesDirectory

Write-Output "Installing OpenCoverToCoberturaConverter..."
Install-Package OpenCoverToCoberturaConverter -RequiredVersion 0.3.4 -Destination $packagesDirectory

Write-Output "Finished installing dependencies."