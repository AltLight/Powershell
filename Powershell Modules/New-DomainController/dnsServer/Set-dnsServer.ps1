function Set-dnsServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]

    $TimeStamp = [scriptblock]::Create('Get-Date -Format hh:mm:ss')
    $LogFile = "C:/Log/New-DomainController.txt"
    $CompName = $env:COMPUTERNAME

    write-Output "[INFO] [$($TimeStamp.Invoke())] Configuring DNS Server on $CompName" | Out-File $LogFile
    foreach ($Zone in $passedData.primarylz)
    {
        $replicationsScope = $pZone.replicationsScope
        Add-DnsServerPrimaryZone -Name $replicationsScope
        foreach ($network in $pZone.networkid)
        {
            try
            {
                Add-DnsServerPrimaryZone -NetworkId "$($network)" -ReplicationScope "$($replicationsScope)" -PassThru
            }
            catch
            {
                write-Output "[ERROR] [$($TimeStamp.Invoke())] $($_.exception.message)" | Out-File $LogFile
            }
        }
        foreach ($file in $pZone.staticEntryFiles)
        {
            $filePath = "$PSScriptRoot\$file"
            if ($file.split(".")[1] -ne "csv")
            {
                write-Output "[ERROR] [$($TimeStamp.Invoke())] $filePath could not be found, or is not a csv file. This file and all data in it will be skipped." | Out-File $LogFile
                break
            }
            $staticHosts = Get-Content -Raw -Path $filePath | ConvertFrom-CSV
            foreach ($host in $staticHosts)
            {
                try
                {
                    Add-DnsServerResourceRecordA -ZoneName $replicationsScope -Name $host.hostname  -IPv4Address $host.ip    
                }
                catch
                {
                    write-Output "[ERROR] [$($TimeStamp.Invoke())] $($_.exception.message)" | Out-File $LogFile    
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
            write-Output "[ERROR] [$($TimeStamp.Invoke())] $($_.exception.message)" | Out-File $LogFile    
        }
    }
}