<#
.DESCRIPTION
   This is a sub controlling module that calls subscripts that 
   will install and configure a DC after Active Directory has 
   been installed, configured, & rebooted. 
   
   This is called by
   an overarching controlling module and is not called by any
   user directly.

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

Last Modified By:
-----------------

#>
function Set-adServices
{
    param(
        [Parameter(mandatory = $true)]
        $dnsServerData,
        $dnsStaticData,
        [Parameter(mandatory = $true)]
        $dhcpData
    )

    [string]$ModuleName = 'Set-adServices'

    Write-ToLog -ModuleName $ModuleName -InfoMessage "Installing DNS and DHCP Services"
    Install-WindowsFeature DNS -IncludeManagementTools
    Install-WindowsFeature DHCP -IncludeManagementTools

    Write-ToLog -ModuleName $ModuleName -InfoMessage "Configuring DNS Services"
    if (($null -ne $dnsStaticData) -or (0 -ne $dnsStaticData.length))
    {
        Set-dnsServer -ServerData $dnsServerData -StaticData $dnsStaticData
    }
    else
    {
        Set-dnsServer -ServerData $dnsServerData
    }
    Write-ToLog -ModuleName $ModuleName -InfoMessage "Configuring DHCP Services"
    Set-dhcpServer -passedData $dhcpData

    Write-ToLog -ModuleName $ModuleName -InfoMessage "$CompName has finished being configured."
}