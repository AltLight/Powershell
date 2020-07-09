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
    param()
    [CmdletBinding]

    $CompName = $env:COMPUTERNAME
    $ServerData = (Get-Content -Raw -Path ($PSScriptRoot + "\dcInfo.json")  |`
        ConvertFrom-Json) |`
        Where-Object hostname -Match $CompName
        

    $ipArgs = @{
        "ipv4Address" = $ServerData.ipv4.ip;
        "prefixLength" = $ServerData.ipv4.prefixLength;
        "Gateway" = $ServerData.ipv4.gateway
        "dnsAddress" = $ServerData.ipv4.dnsserver -join ","
    }

    $ipSetCheck = Set-IPv4 @ipArgs

    $ipSetCheck
    Pause

    if ($true -ne $ipSetCheck.result)
    {
        Write-host "$CompName errored setting the network adapter, see logs below:" -ForegroundColor Red
        $ipSetCheck | Format-Table -AutoSize -Wrap
        break
    }

    [hashtable]$AllServices = @{
        "AD-Domain-Services" = "adServer";
        "DNS" = "dnsServer";
        "DHCP" = "dhcpServer"
    }
    Install-WindowsFeature -Name Bits
    foreach ($service in $ServerData.services)
    {
        if ($AllServices.Keys -icontains $service)
        {
            $ServiceName = ($AllServices.GetEnumerator() | Where-Object Name -Match $service).Value
            $setCommand = "Set-$ServiceName"
            $PassData = $ServerData.$ServiceName

            Install-WindowsFeature $service -IncludeManagementTools
            &$setCommand -passedData $PassData
        }  
    }
}