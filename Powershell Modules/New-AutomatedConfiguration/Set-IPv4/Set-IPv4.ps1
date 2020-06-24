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
    $interfaceIndex = (Get-NetAdapter).interfaceindex

    $ipArgs = @{
        "InterfaceIndex" = $interfaceIndex;
        "IPAddress" = $ipv4Address;
        "PrefixLength" = $prefixLength;
        "DefaultGateway" = $Gateway
    }
    $dnsArgs = @{
        "InterfaceIndex" = $interfaceIndex;
        "ServerAddress" = $dnsAddress -join ','
    }
    try
    {
        New-NetIPAddress @ipArgs
        Set-DNSClientServerAddress @dnsArgs
    }
    catch
    {
        $ErrorMessage = Get-ModuleErrors -ModuleName $ModuleName -ErrorMessage $_.exception.message
        $ErrorArray += $ErrorMessage
    }
    if (0 -eq $ErrorArray.Count)
    {
        Return $null
    }
    else
    {
        Return $ErrorArray
    }
}