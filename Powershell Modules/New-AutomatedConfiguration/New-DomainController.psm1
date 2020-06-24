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

    $AllServerData = Get-Content -Raw -Path ($PSScriptRoot + "\dcInfo.json") | ConvertFrom-Json
    $CompName = $env:COMPUTERNAME
    if ($ServerData.hostname -inotcontains $CompName)
    {
        break
    }

    $ServerData = $ServerData | Where-Object "hostname" -Match $CompName

    $ipArgs = @{
        "ipv4Address" = $ServerData.ipv4.ip;
        "prefixLength" = $ServerData.ipv4.prefixLength;
        "Gateway" = $ServerData.ipv4.gateway
        "dnsAddress" = $ServerData.ipv4.dnsserver -join ","
    }
    $ipSetCheck = Set-IPv4 @ipArgs

    if ($null -ne $ipSetCheck)
    {
        Write-host "$CompName errored setting the network adapter, see logs below:" -ForegroundColor Red
        $ipSetCheck | Format-Table -AutoSize -Wrap
        break
    }

    [hashtable]$AllServices = @{
        "Ad-Domain-Services" = "adServer";
        "DNS Server" = "dnsServer";
        "DHCP" = "dhcpServer"
    }
    foreach ($service in $ServerData.services)
    {
        if ($AllServices.Keys -icontains $service)
        {
            $ServiceName = ($AllServices.GetEnumerator() | Where-Object Name -Match $service).Value
            $InstallCMD = "Install-" + $ServiceName
            $SetCMD = "Set-" + $ServiceName
            
            Install-WindowsFeature -Name Bits
            if ($ServiceName -eq $AllServices[0].value)
            {
                $PassData = $service.adinfo
            }

            &$InstallCMD 
            &$SetCMD
        }  
    }
}