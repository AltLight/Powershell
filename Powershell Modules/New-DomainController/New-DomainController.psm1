<#
.SYNOPSIS
   This is a controlling module used to fully configure an
   Active Directory Server.
.DESCRIPTION
   This is the overarching controller module used to fully
   configure an Active Directory server.

   This module handles ALL of the sub-controller and sub-script
   JSON and CSV file handeling, passing the appropiate data to 
   the appropiate sub-controllers.

   This module is currently built to be ran ON the domain
   conftroller that is to be configured, and in the future
   can have remote usability built in.

.EXAMPLE
   New-DomainController -Initialize
.EXAMPLE
   New-DomainController -Configure

.Required Modules
   Write-ToLog
#>
<#
Version:
--------
   1.0
Created by:
-----------
   AltLight
Date of creation:
-----------------
   16 July 2020
Date Last Modified:
-------------------
   23 July 2020
Last Modified By:
-----------------
   AltLight
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
    [string]$ConfigFileIdentifier = "configuration"
    [string]$dcConfigDirectory = "$PSScriptRoot\_DC_Config_Files"

    $ServerData = Get-ChildItem -Path $dcConfigDirectory |`
        Where-Object Name -Match $ConfigFileIdentifier |`
        Where-Object Name -Match $CompName |`
        Get-Content -Raw |`
        ConvertFrom-Json
            
    if ($null -eq $ServerData)
    {
        Write-ToLog -ModuleName $ModuleName -ErrorMessage "No configuration settings found for $CompName, aborting operations."
        break
    }

    if (!($Initialize) -and !($Configure))
    {
        $message = "[INFO] [$($TimeStamp.Invoke())] No switch option was called, nothing to do. Aborting operation." 
        Write-Host $message
        Write-ToLog -ModuleName $ModuleName -InfoMessage $message
        Break
    }

    if ($Initialize)
    {
        Initialize-AD -ipData $ServerData.ipv4 -adData $ServerData.adServer
    }

    if ($Configure)
    {
        $HostFileIdentifier = "staticHosts"
        $StaticHostDataPath = (Get-ChildItem -Path $dcConfigDirectory -Include *.csv -Recurse |`
            Where-Object Name -Match  $HostFileIdentifier|`
            Where-Object Name -Match $CompName).fullname
        if (0 -ne $StaticHostDataPath.length)
        {
            $StaticHostData = Get-Content -Path $StaticHostDataPath -Raw | ConvertFrom-Csv
            Set-adServices -dnsServerData $ServerData.dnsServer -dnsStaticData $StaticHostData -dhcpData $ServerData.dhcpServer 
        }
        else
        {
            Set-adServices -dnsServerData $ServerData.dnsServer -dhcpData $ServerData.dhcpServer
        }
    }
}