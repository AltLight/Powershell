
function Initialize-AD
{
    param(
        [Parameter(mandatory = $true)]
        $ipData,
        [Parameter(mandatory = $true)]
        $adData
    )
    # Set Script Varibales:
    $TimeStamp = [scriptblock]::Create('Get-Date -Format hh:mm:ss')
    $LogFile = "C:/Log/New-DomainController.txt"
    $CompName = $env:COMPUTERNAME
    $cred = Get-Credential -UserName $env:USERNAME -Message "Enter God credentials:"

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
        Write-Output "[ERROR] [$($TimeStamp.Invoke())] $CompName errored setting the network adapter, see logs below:" | Out-File $LogFile -Append
        break
    }

    # Install & Configure Initial Services:
    Write-Output "[INFO] [$($TimeStamp.Invoke())] Installing Bits & Active Directory Services" | Out-File $LogFile -Append
    Install-WindowsFeature -Name Bits
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

    Write-Output "[INFO] [$($TimeStamp.Invoke())] Configuring Active Directory" | Out-File $LogFile -Append
    Set-adServer -passedData $ServerData.adServer -Creds $cred

    # Create a scheduled task to recall parent conrol module to continue configuration after reboot:
    Write-Output "[INFO] [$($TimeStamp.Invoke())] Creating Scheduled task to resume configuration after reboot" | Out-File $LogFile -Append
    $PSPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $Arguments = '-NonInteractive -WindowStyle Hidden -NoLogo -NoProfile -NoExit -Command "& {New-DomainController -FirstReboot}"'
    $Action = New-ScheduledTaskAction -Execute $PSPath -Argument $Arguments
    $Option = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
    $Trigger = New-JobTrigger -AtStartUp -RandomDelay (New-TimeSpan -Seconds 45)
    
    $TaskArgs = @{
        "Credential" = $creds
        "TaskName" = "Resume-Configuration"
        "Action" = $Action
        "Trigger" = $Trigger
        "Settings" = $Option
        "RunLevel" = Highest
    }
    Register-ScheduledTask  @TaskArgs

    Write-Output "[INFO] [$($TimeStamp.Invoke())] Rebooting server to apply Active Directory configuration." | Out-File $LogFile -Append
    Restart-Computer -Force
}