function Set-dhcpServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]

    netsh dhcp add securitygroups
    Restart-Service dhcpserver

    foreach ($scope in $passedData)
    {
        $AddScopeArgs = @{
            "name" = $scope.name
            "StartRange" = $scope.startIP
            "EndRange" = $scope.endIP
            "SubnetMask" = $scope.subnet
            "State" = "Active"
        }
        Set-DhcpServerv4Scope @AddScopeArgs
        
        $SetScopeArgs = @{
            "ScopeID" = $scope.networkIP
            "LeaseDuration" = 1.00:00:00
        }
        Set-DhcpServerv4Scope @SetScopeArgs

        $SetOptionsArgs = @{
            "ScopeID" = $scope.networkIP
            "DnsDomain" = $scope.domain
            "DnsServer" = $scope.dns -join ","
            "Router" = $scope.gateway
        }
        Set-DhcpServerv4OptionValue @SetOptionsArgs
    }
    $hostIP = (Get-NetAdapter |`
         Where-Object { $_.Status -eq "up" } |`
         Get-NetIPConfiguration).IPv4Address.IPAddress
    
    $hostDomain = (Get-WmiObject Win32_ComputerSystem).domain

    Add-DhcpServerInDC -DnsName $hostDomain -IpAddress $hostIP
}