<#
.DESCRIPTION
   This module configures a DHCP server based on the
   parameters defined in a servers JSON configuration 
   file. These parameters are passed to this script by
   a controller module.

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
   24 July 2020
Last Modified By:
-----------------
   AltLight
#>
function Set-dhcpServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]

    [string]$ModuleName

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
            Add-DhcpServerv4Scope @AddScopeArgs
        }
        catch
        {
            Write-ToLog `
                -ModuleName $ModuleName `
                -ErrorMessage $_.exception.message
        }
        
        $SetScopeArgs = @{
            "ScopeID" = $scope.networkIP
            "LeaseDuration" = "1.00:00:00"
        }
        try
        {
            Set-DhcpServerv4Scope @SetScopeArgs
        }
        catch
        {
            Write-ToLog `
                -ModuleName $ModuleName `
                -ErrorMessage $_.exception.message
        }

        $SetOptionsArgs = @{
            "ScopeID" = $scope.networkIP
            "DnsServer" = $scope.dns -join ","
            "Router" = $scope.gateway
        }
        try
        {
            Set-DhcpServerv4OptionValue @SetOptionsArgs
        }
        catch
        {
            Write-ToLog `
                -ModuleName $ModuleName `
                -ErrorMessage $_.exception.message
        }
    }
    
    $hostIP = (Get-NetAdapter |`
         Where-Object { $_.Status -eq "up" } |`
         Get-NetIPConfiguration).IPv4Address.IPAddress
    
    $hostDomain = (Get-WmiObject Win32_ComputerSystem).domain

    try
    {
        Add-DhcpServerInDC `
            -DnsName $hostDomain `
            -IpAddress $hostIP
    }
    catch
    {
        Write-ToLog `
            -ModuleName $ModuleName `
            -ErrorMessage $_.exception.message
    }
}