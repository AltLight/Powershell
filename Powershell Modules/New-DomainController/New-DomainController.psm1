<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER

.EXAMPLE
#>
<#

#>
function New-DomainController
{
    param(
        [switch]$Initialize,
        [switch]$Configure
    )
    [CmdletBinding]

    $ModuleName = 'New-DomainController'
    $TimeStamp = [scriptblock]::Create('Get-Date -Format hh:mm:ss')
    [string]$CompName = $env:COMPUTERNAME
    [string]$dcConfigDirectory = "$PSScriptRoot\_DC_Config_Files"

    $ServerData = Get-ChildItem -Path $dcConfigDirectory |`
        Where-Object Name -Match $CompName |`
        Get-Content -Raw |`
        ConvertFrom-Json
        
    if ($null -eq $ServerData)
    {
        Write-ToLog -ModuleName $ModuleName -ErrorMessage "No configuration settings found for $CompName, aborting operations."
        break
    }

    if ($Initialize)
    {
        Initialize-AD -ipData $ServerData.ipv4 -adData $ServerData.adServer
    }
    if ($Configure)
    {
        Set-adServices -dnsData $ServerData.dnsServer -dhcpData $ServerData.dhcpServer
        break
    }

    if (!($Initialize) -and !($Configure))
    {
        $message = "[INFO] [$($TimeStamp.Invoke())] No switch option was called, nothing to do. Aborting operation." 
        Write-Host $message
        Write-ToLog -ModuleName $ModuleName -InfoMessage $message
        Break
    }
}