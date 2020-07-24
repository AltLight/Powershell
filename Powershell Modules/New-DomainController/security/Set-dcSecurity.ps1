<#
.DESCRIPTION
   Configure the following Domain Controllers security settings:
      Windows Firewall Profiles
      Windows IE Enhanced Security
   
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
   24 July 2020
Date Last Modified:
-------------------

Last Modified By:
-----------------

#>
function Set-dcSecurity
{
    param()
    [CmdletBinding]
    $ModuleName = 'Set-dcSecurity'
    function Disable-WindowsFirewalls
    {
        $firewallProfiles = @(
            "Domain",
            "Public",
            "Private"
        )

        try
        {
            Set-NetFirewallProfile `
                -Profile $firewallProfiles -Join ',' `
                -Enabled False `
                -Confirm:$false
            
            Write-ToLog `
                -ModuleName $ModuleName `
                -InfoMessage "The following firewalls have been disabled:`n$($firewallProfiles -join ',')"
        }
        catch
        {
            Write-ToLog `
                -ModuleName $ModuleName `
                -ErrorMessage $_.exception.message
        }
    }

    function Disable-InternetExplorerESC
    {
        $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
        $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
        try
        {
            Set-ItemProperty `
                -Path $AdminKey `
                -Name "IsInstalled" `
                -Value 0 `
                -Force

            Set-ItemProperty `
                -Path $UserKey `
                -Name "IsInstalled" `
                -Value 0 `
                -Force

            Stop-Process `
                -Name Explorer `
                -Force

            Write-ToLog `
                -ModuleName $ModuleName `
                -InfoMessage "IE Enhanced Security Configuration (ESC) has been disabled."
        }
        catch
        {
            Write-ToLog `
                -ModuleName $ModuleName `
                -ErrorMessage $_.exception.message
        }
    }
    
    Disable-InternetExplorerESC
    Disable-WindowsFirewalls
}