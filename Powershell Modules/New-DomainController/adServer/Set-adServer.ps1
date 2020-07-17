<#
.DESCRIPTION
   This module configures Active Directory based on the
   parameters defined in a servers JSON configuration
   file. Theses parameters are passed to this script
   by a controller module.

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

Last Modified By:
-----------------

#>
function Set-adServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]
    
    [string]$ModuleName = 'Set-adServer'

    if (0 -eq ($passedData.rootDomainController).length)
    {
        $Arguments = @{
            "CreateDnsDelegation" = $passedData.CreateDnsDelegation
            "DatabasePath" = $passedData.DatabasePath
            "DomainMode" = $passedData.DomainMode
            "ForestMode" = $passedData.ForestMode
            "domainName" = $passedData.domainName
            "domainNetbiosName" = $passedData.domainNetbiosName
            "InstallDNS" = $passedData.InstallDNS
            "LogPath" = $passedData.LogPath
            "NoRebootOnCompletion" = $passedData.NoRebootOnCompletion
            "SysvolPath" = $passedData.SysvolPath
            "Force" = $passedData.Force
        }
        try
        {
            Install-ADDSForest @Arguments
            $ReturnData = $true
        }
        catch
        {
            $ReturnData = $null
            Write-ToLog -ModuleName $ModuleName -ErrorMessage $_.exception.message
        }
        
    }
    else
    {
        $adCreds = Get-Credential -UserName "$($passedData.domainName)\administrator" -Message "Need local domain creds"
        $Arguments = @{
            "Credential" = $adCreds
            "DomainType" = $passedData.domainType
            "NewDomainName" = $passedData.domainName
            "ParentDomainName" = $passedData.rootDomainController
            "InstallDNS" = $passedData.InstallDNS         
            "CreateDnsDelegation" = $passedData.CreateDnsDelegation
            "DomainMode" = $passedData.DomainMode
            "DatabasePath" = $passedData.DatabasePath
            "SysvolPath" = $passedData.SysvolPath
            "LogPath" = $passedData.LogPath
            "NoRebootOnCompletion" = $passedData.NoRebootOnCompletion
            "Force" = $true
        }
        try
        {
            Install-ADDSDomain @Arguments
            $ReturnData = $true
        }
        catch
        {
            $ReturnData = $null
            Write-ToLog -ModuleName $ModuleName -ErrorMessage $_.exception.message
        }
    }
    Return $ReturnData
}
