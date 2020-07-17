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

Last Modified By:
-----------------

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

    Write-ToLog -ModuleName $ModuleName -InfoMessage "Configuring DNS Server on $CompName"

    foreach ($pZone in $passedData.primarylz)
    {
        foreach ($network in $pZone.networkid)
        {
            try
            {
                Add-DnsServerPrimaryZone -NetworkId $network -ReplicationScope Forest -PassThru
            }
            catch
            {
                Write-ToLog -ModuleName $ModuleName -ErrorMessage $_.exception.message
            }
        }
        if ($null -ne $StaticData)
        {
            foreach ($shost in $StaticData)
            {
                try
                {
                    Add-DnsServerResourceRecordA -ZoneName $pZone.zoneName -Name $shost.hostname -IPv4Address $shost.ip    
                }
                catch
                {
                    Write-ToLog -ModuleName $ModuleName -ErrorMessage $_.exception.message
                }
            }
        }
    }
    foreach ($sZone in $passedData.secoondarylz)
    {
        $zoneFile = "$($sZone.secondaryadDomain).dns"
        $masterServers = $sZone.secondaryadServerIP -join ","
        try
        {
            Add-DnsServerSecondaryZone -Name $domain -ZoneFile $zoneFile -MasterServers $masterServers
        }
        catch
        {
            Write-ToLog -ModuleName $ModuleName -ErrorMessage $_.exception.message
        }
    }
}