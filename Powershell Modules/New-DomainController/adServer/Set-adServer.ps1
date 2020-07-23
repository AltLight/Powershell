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
   23 July 2020
Last Modified By:
-----------------
   AltLight
#>
function Set-adServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]
    
    Import-Module ADDSDeployment
    [string]$ModuleName = 'Set-adServer'

    $DatabasePath = "C:\Windows\NTDS"
    $SysvolPath = "C:\Windows\SYSVOL"
    <#
    The DomainMode should be changed to the lowest version
    of  windows server version used IF you are using multiple
    version of windows on as Domain Controllers
    #>
    $DomainMode = "WinThreshold"

    if (0 -eq ($passedData.rootDomainController).length)
    {
        try
        {
            Install-ADDSForest `
                -CreateDnsDelegation:$passedData.CreateDnsDelegation `
                -DatabasePath $DatabasePath `
                -DomainMode $DomainMode `
                -DomainName $passedData.domainName `
                -DomainNetbiosName $passedData.domainNetbiosName `
                -ForestMode $DomainMode `
                -InstallDns:$passedData.InstallDNS `
                -LogPath $DatabasePath `
                -NoRebootOnCompletion:$passedData.NoRebootOnCompletion `
                -SysvolPath $SysvolPath `
                -Force:$passedData.Force
            
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
        $adCreds = Get-Credential -UserName "administrator@$($passedData.rootDomainController)" -Message "Need credentials for forest domain controller:"
        try
        {
            Install-ADDSDomain `
                -NoGlobalCatalog:$false `
                -CreateDnsDelegation:$passedData.CreateDnsDelegation `
                -Credential $adCreds `
                -DatabasePath $DatabasePath `
                -DomainMode $DomainMode `
                -DomainType $passedData.domainType `
                -InstallDns:$passedData.InstallDNS `
                -LogPath $DatabasePath `
                -NewDomainName $passedData.domainName `
                -NewDomainNetbiosName $passedData.domainNetbiosName `
                -ParentDomainName $passedData.rootDomain `
                -NoRebootOnCompletion:$passedData.NoRebootOnCompletion `
                -SiteName "Default-First-Site-Name" `
                -SysvolPath $SysvolPath `
                -Force:$passedData.Force
            
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
