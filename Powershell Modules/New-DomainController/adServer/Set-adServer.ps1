function Set-adServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData,
        [Parameter(mandatory = $true)]
        [securestring]$Creds
    )
    [CmdletBinding]

    [string]$ModuleName = 'Set-adServer'
    
    if (0 -eq ($passedData.rootDomainController).length)
    {
        $Arguments = @{
            "CreateDnsDelegation" = $passedData.CreateDnsDelegation
            "SafeModeAdministratorPassword" = $Creds.password
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
        }
        catch
        {
            Write-ToLog -ModuleName $ModuleName -ErrorMessage $_.exception.message
        }
        
    }
    else
    {
        $adCreds = Get-Credential $passedData.domainName\administrator
        $Arguments = @{
            "Credential" = $adCreds
            "NewDomainName" = $passedData.domainName
            "ParentDomainName" = $passedData.rootDomainController
            "InstallDNS" = $passedData.InstallDNS         
            "CreateDnsDelegation" = $passedData.CreateDnsDelegation
            "DomainMode" = $passedData.DomainMode
            "DatabasePath" = $passedData.DatabasePath
            "SysvolPath" = $passedData.SysvolPath
            "LogPath" = $passedData.LogPath
            "NoRebootOnCompletion" = $passedData.NoRebootOnCompletion
        }
        try
        {
            Install-ADDSDomain @Arguments
        }
        catch
        {
            Write-ToLog -ModuleName $ModuleName -ErrorMessage $_.exception.message
        }
    }
}
