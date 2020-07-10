function Set-dhcpServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]

    $TimeStamp = [scriptblock]::Create('Get-Date -Format hh:mm:ss')
    $LogFile = "C:/Log/New-DomainController.txt"

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
        try
        {
            Set-DhcpServerv4Scope @AddScopeArgs
        }
        catch
        {
            write-Output "[ERROR] [$($TimeStamp.Invoke())] $($_.exception.message)" | Out-File $LogFile
        }
        
        
        $SetScopeArgs = @{
            "ScopeID" = $scope.networkIP
            "LeaseDuration" = 1.00:00:00
        }
        try
        {
            Set-DhcpServerv4Scope @SetScopeArgs
        }
        catch
        {
            write-Output "[ERROR] [$($TimeStamp.Invoke())] $($_.exception.message)" | Out-File $LogFile
        }
        

        $SetOptionsArgs = @{
            "ScopeID" = $scope.networkIP
            "DnsDomain" = $scope.domain
            "DnsServer" = $scope.dns -join ","
            "Router" = $scope.gateway
        }
        try
        {
            Set-DhcpServerv4OptionValue @SetOptionsArgs
        }
        catch
        {
            write-Output "[ERROR] [$($TimeStamp.Invoke())] $($_.exception.message)" | Out-File $LogFile
        }
        
    }
    
    $hostIP = (Get-NetAdapter |`
         Where-Object { $_.Status -eq "up" } |`
         Get-NetIPConfiguration).IPv4Address.IPAddress
    
    $hostDomain = (Get-WmiObject Win32_ComputerSystem).domain

    try
    {
        Add-DhcpServerInDC -DnsName $hostDomain -IpAddress $hostIP
    }
    catch
    {
        write-Output "[ERROR] [$($TimeStamp.Invoke())] $($_.exception.message)" | Out-File $LogFile
    }
    
}