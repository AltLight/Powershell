function Copy-vmDirectory
{
    [cmdletbinding()]
    Param()

    $username = $env:USERNAME
    $pass = Read-host `
        -Prompt "`nEnter the password for: $username" | `
        ConvertTo-SecureString `
        -AsPlainText `
        -Force
    
    $creds  = New-Object `
        -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $username,$pass
    
    
}