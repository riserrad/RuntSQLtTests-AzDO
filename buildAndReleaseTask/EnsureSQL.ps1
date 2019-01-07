function Ensure-SQLTools{
    param(
            [int]$majorPSVersion
        )

if($majorPSVersion -gt 4)
{
	$confirmSqlServer = Get-Module SqlServer -ListAvailable
	if(!$confirmSqlServer)
	{
		Try
		{
			Install-Module -Name SqlServer -AllowClobber
			Write-Host "Loaded SqlServer module"
		}
        Catch
		{
			Write-Host "SqlServer not available via PowerShell Gallery, check connection settings"
		}
    }
	else
	{
		Write-Host "SqlServer module is loaded"
	}
}
else
{
	$confirmSQLPS = Get-Module SQLPS -ListAvailable
	if(!$confirmSQLPS)
	{
		Try
		{
			Import-Module "SQLPS" -DisableNameChecking
			Write-Host "Loaded SQLPS module"
		}
		 Catch
		{
			Write-Host "SQLPS not available to import; installation needed"
		}
	}
	else
	{
		Write-Host "SQLPS module is loaded"
	}
}