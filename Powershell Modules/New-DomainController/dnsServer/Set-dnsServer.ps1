function Set-dnsServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]

    [string]$ModuleName = "Set-dnsServer"
    $CompName = $env:COMPUTERNAME

    Write-ToLog -ModuleName $ModuleName -InfoMessage "Configuring DNS Server on $CompName"

    foreach ($pZone in $passedData.primarylz)
    {
        $replicationScope = $pZone.replicationScope
        foreach ($network in $pZone.networkid)
        {
            try
            {
                Add-DnsServerPrimaryZone -NetworkId "$network" -ReplicationScope $replicationScope -PassThru
            }
            catch
            {
                Write-ToLog -ModuleName $ModuleName -ErrorMessage $_.exception.message
            }
        }
        foreach ($file in $pZone.staticEntryFiles)
        {
            $filePath = "$PSScriptRoot\$file"
            if ($file.split(".")[1] -ne "csv")
            {
                Write-ToLog -ModuleName $ModuleName -ErrorMessage "$filePath could not be found, or is not a csv file. This file and all data in it will be skipped."
                break
            }
            $staticHosts = Get-Content -Raw -Path $filePath | ConvertFrom-CSV
            foreach ($host in $staticHosts)
            {
                try
                {
                    Add-DnsServerResourceRecordA -ZoneName $replicationScope -Name $host.hostname -IPv4Address $host.ip    
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