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
        [switch]$FirstReboot
    )
    [CmdletBinding]

    $TimeStamp = [scriptblock]::Create('Get-Date -Format hh:mm:ss')
    $LogFile = "C:/Log/New-DomainController.txt"
    $CompName = $env:COMPUTERNAME
    $ServerData = (Get-Content -Raw -Path ($PSScriptRoot + "\dcInfo.json")  |`
        ConvertFrom-Json) |`
        Where-Object hostname -Match $CompName
        
    if ($null -eq $ServerData)
    {
        write-Output "[ERROR] [$($TimeStamp.Invoke())] No configuration settings found for $CompName, aborting operations." | Out-File $LogFile -Append
        break
    }

    if ($FirstReboot)
    {
        Set-adServices -dnsData -dhcpData
        break
    }  
    Initialize-AD -ipData $ServerData.ipv4 -adData $ServerData.adServer
}