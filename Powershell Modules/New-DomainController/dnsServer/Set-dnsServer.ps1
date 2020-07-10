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
        $replicationsScope = $Zone.replicationsScope
        Add-DnsServerPrimaryZone -Name $replicationsScope
        foreach ($network in $Zone.networkid)
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
        foreach ($file in $Zone.staticEntryFiles)
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
}