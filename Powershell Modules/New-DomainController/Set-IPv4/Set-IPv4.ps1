function Set-IPv4
{
    param(
        [Parameter(mandatory = $true)]
        [string]$ipv4Address,
        [Parameter(mandatory = $true)]
        [string]$prefixLength,
        [Parameter(mandatory = $true)]
        [string]$Gateway,
        [Parameter(mandatory = $true)]
        [string]$dnsAddress
    )
    [CmdletBinding]

    [string]$ModuleName = 'Set-IPv4'
    [array]$ErrorArray
    [hashtable]$ReturnData = @{}

    $ipArgs = @{
        "IPAddress" = $ipv4Address;
        "PrefixLength" = $prefixLength;
        "DefaultGateway" = $Gateway
    }
    $dnsArgs = @{
        "ServerAddress" = $dnsAddress -join ','
    }
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "up" }
    $IPType = "IPv4"
    try
    {
        # Remove any existing IP, gateway from our ipv4 adapter
        If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress)
        {
            $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
        }
        If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway)
        {
            $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
        }

        $adapter | New-NetIPAddress @ipArgs | Out-Null
        $adapter | Set-DNSClientServerAddress @dnsArgs | Out-Null
    }
    catch
    {
        $ErrorMessage = Get-ModuleErrors -ModuleName $ModuleName -ErrorMessage $_.exception.message
        $ReturnData.Add("Error",$ErrorMessage)
    }

    if ($ipv4Address -eq ($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress)
    {
        $ReturnData.Add("result",$true)
    }
    Return $ReturnData
}