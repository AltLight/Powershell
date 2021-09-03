function Copy-vmDirectory
{
    [cmdletbinding()]
    Param(
        [string]$remoteFolder,
        [validatescript({$_ | Test-Path})]
        [string]$copyToLocation
    )

    [string]$savedJobData = 
    [string]$username = $env:USERNAME
    $pass = Read-host `
        -Prompt "`nEnter the password for: $username" | `
        ConvertTo-SecureString `
        -AsPlainText `
        -Force
    
    $creds  = New-Object `
        -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $username,$pass
    
    if ((0 -eq $remoteFolder.Length) -and (0 -eq $copyToLocation.Length))
    {

    }
}