<#
.DESCRIPTION
   This module configures a DNS server based on the
   parameters defined in a servers JSON configuration 
   file. These parameters are passed to this script by
   a controller module.

   Any Static Hosts should be listed in the hosts 
   "_staticHosts.csv" file located in the configuration
   file directory.

   This is called by an overarching controlling module
   and is not called by any user directly.
   
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
   24 July 2020
Last Modified By:
-----------------
   AltLight
#>
function Set-dnsServer
{
    param(
        [Parameter(mandatory = $true)]
        $ServerData,
        $StaticData
    )
    [CmdletBinding]

    [string]$ModuleName = "Set-dnsServer"
    $CompName = $env:COMPUTERNAME

    Write-ToLog `
        -ModuleName $ModuleName `
        -InfoMessage "Configuring DNS Server on $CompName"

    foreach ($pZone in $ServerData.primarylz)
    {
        foreach ($network in $pZone.networkid)
        {
            try
            {
                Add-DnsServerPrimaryZone `
                    -NetworkId $network `
                    -ReplicationScope Forest `
                    -PassThru
            }
            catch
            {
                Write-ToLog `
                    -ModuleName $ModuleName `
                    -ErrorMessage $_.exception.message
            }
        }
        if ($null -ne $StaticData)
        {
            foreach ($shost in $StaticData)
            {
                try
                {
                    Add-DnsServerResourceRecordA `
                        -ZoneName $pZone.zoneName `
                        -Name $shost.hostname `
                        -IPv4Address $shost.ip
                    Add-DnsServerResourceRecord `
                        -ZoneName "$($shost.lookupzone).in-addr.arpa" `
                        -A `
                        -Name $shost.hostname
                        -IPv4Address $shost.ip
                }
                catch
                {
                    Write-ToLog `
                        -ModuleName $ModuleName `
                        -ErrorMessage $_.exception.message
                }
            }
        }
    }
    
    foreach ($cZone in $ServerData.conditionalForwarders)
    {
        try
        {
            $ConditionalForwarder = Add-DnsServerConditionalForwarderZone `
                -Name $cZone.name `
                -ReplicationScope $cZone.replicationScope `
                -MasterServers $cZone.MasterServers -join "," `
                -Confirm:$false
                -PassThrough
            
            Write-ToLog `
                -ModuleName $ModuleName `
                -InfoMessage "$($ConditionalForwarder | Out-String)"
        }
        catch
        {
            Write-ToLog `
                -ModuleName $ModuleName `
                -ErrorMessage $_.exception.message
        }
    }
}