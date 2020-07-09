function Set-dhcpServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]

    $passedData
    pause

    netsh dhcp add securitygroups
    Restart-Service dhcpserver
    Add-DhcpServerInDC
}