function Set-adServer
{
    param(
        [Parameter(mandatory = $true)]
        $passedData
    )
    [CmdletBinding]

    $passedData
    pause

    
    if ($null -eq $passedData.rootDomainController)
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
        Install-ADDSForest @Arguments
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
            
            "domainNetbiosName" = $passedData.domainNetbiosName
            "Force" = $passedData.Force
        }
        $installCMD = 'Install-ADDSDomain'
    }

    workflow Configure_ActiveDirectory
    {
        Write-Output "Before reboot" | Out-File  C:/Log/t.txt -Append

        InlineScript {"$installCMD @Arguments -Wait"}

        Write-Output "$Now2 After reboot" | Out-File  C:/Log/t.txt -Append
    }

    $PSPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $Arguments = '-NonInteractive -WindowStyle Hidden -NoLogo -NoProfile -NoExit -Command "& {Import-Module PSWorkflow ; Get-Job | Resume-Job}"'
    $Action = New-ScheduledTaskAction -Execute $PSPath -Argument $Arguments
    $Option = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
    $Trigger = New-JobTrigger -AtStartUp -RandomDelay (New-TimeSpan -Minutes 5)
    Register-ScheduledTask -TaskName ResumeJob -Action $Action -Trigger $Trigger -Settings $Option -RunLevel Highest

    Configure_ActiveDirectory -AsJob
}
