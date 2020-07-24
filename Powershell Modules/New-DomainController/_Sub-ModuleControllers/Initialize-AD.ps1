<#
.DESCRIPTION
   This is a sub controlling module that calls subscripts that 
   will configure a DC up until it need to be rebooted. 
   
   This is called by an overarching controlling module and is
   not called by any user directly.
   
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
function Initialize-AD
{
    param(
        [Parameter(mandatory = $true)]
        $ipData,
        [Parameter(mandatory = $true)]
        $adData
    )
    # Set Script Varibales:
    [string]$ModuleName = 'Initialize-AD'
    $CompName = $env:COMPUTERNAME

    # Configure IPv4 Adapter
    $ipArgs = @{
        "ipv4Address" = $ipData.ip;
        "prefixLength" = $ipData.prefixLength;
        "Gateway" = $ipData.gateway
        "dnsAddress" = $ipData.dnsserver -join ","
    }

    $ipSetCheck = Set-IPv4 @ipArgs

    if ($true -ne $ipSetCheck)
    {
        Write-ToLog `
            -ModuleName $ModuleName `
            -ErrorMessage "$CompName | Errored setting the network adapter, error mesasge was:`n$ipSetCheck"
        break
    }
    Write-ToLog `
        -ModuleName $ModuleName `
        -InfoMessage "$CompName IP settings set to:`n$($ipArgs | Out-String)"

    # Install & Configure Initial Services:
    Write-ToLog `
        -ModuleName $ModuleName `
        -InfoMessage "Installing Bits & Active Directory Services"

    Install-WindowsFeature -Name Bits

    Install-WindowsFeature `
        -Name AD-Domain-Services `
        -IncludeManagementTools

    Write-ToLog `
        -ModuleName $ModuleName `
        -InfoMessage "Configuring Active Directory"
    
    $adServerCheck = Set-adServer -passedData $ServerData.adServer

    if ($true -ne $adServerCheck)
    {
        Write-Host `
            "An Error has occured while configuring Active Directory, review the error logs (see Write-ToLog module)." `
            -ForegroundColor Red
        Break
    }
    Write-ToLog `
        -ModuleName $ModuleName `
        -InfoMessage "Rebooting server to apply Active Directory configuration."
    
    Restart-Computer -Force
}