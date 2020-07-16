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
        $adCreds = Get-Credential -UserName "$($passedData.domainName)\administrator"
        $Arguments = @{
            "Credential" = $adCreds
            "DomainType" = TreeDomain
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
