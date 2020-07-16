
function Initialize-AD
{
    param(
        [Parameter(mandatory = $true)]
        $ipData,
        [Parameter(mandatory = $true)]
        $adData
    )
    # Set Script Varibales:
    [string]$ModuleName = 'Initialize-AD'
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
        Write-ToLog -ModuleName $ModuleName -ErrorMessage "$CompName | Errored setting the network adapter, error mesasge was:`n$ipSetCheck"
        break
    }
    Write-ToLog -ModuleName $ModuleName -InfoMessage "$CompName IP settings set to:`n$ipArgs"

    # Install & Configure Initial Services:
    Write-ToLog -ModuleName $ModuleName -InfoMessage "Installing Bits & Active Directory Services"
    Install-WindowsFeature -Name Bits
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

    Write-ToLog -ModuleName $ModuleName -InfoMessage "Configuring Active Directory"
    Set-adServer -passedData $ServerData.adServer -Creds $cred

    # Create a scheduled task to recall parent conrol module to continue configuration after reboot:
    Write-ToLog -ModuleName $ModuleName -InfoMessage "Creating Scheduled task to resume configuration after reboot"
    [string]$PSPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
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

    Write-ToLog -ModuleName $ModuleName -InfoMessage "Rebooting server to apply Active Directory configuration."
    Restart-Computer -Force
}