function Set-dnsServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]

    $passedData
    pause
    foreach ($primaryZone in $passedData.primarylz)
    {
        Add-DnsServerPrimaryZone -NetworkId "$($primaryZone.key)" -ReplicationScope "$($primaryZone.value)" -PassThru
    }
 
    #Add-DnsServerResourceRecordA -Name reddeerprint01 -ZoneName corp.ad -IPv4Address 192.168.2.56
}