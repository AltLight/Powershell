function Set-ActiveDirectoryServer
{
    param(
        [Parameter(mandatory = $true)]
        $adDomain,
        [Parameter(mandatory = $true)]
        $ParentDomain
    )
    [CmdletBinding]

    $Arguments = @{
        "InstallDns" = $true;
        "Credential" = (Get-Credential $adDomain\administrator);
        "DomainName" = $adDomain;
        "SafeModeAdministratorPassword" = (ConvertTo-SecureString -AsPlainText 'Passwort' -Force);
        "confirm" = $false
    }
    Install-ADDSDomainController @Arguments
}