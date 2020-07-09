
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

    # Configure IPv4 Adapter
    $ipArgs = @{
        "ipv4Address" = $ipData.ip;
        "prefixLength" = $ipData.prefixLength;
        "Gateway" = $ipData.gateway
        "dnsAddress" = $ipData.dnsserver -join ","
    }

    $ipSetCheck = Set-IPv4 @ipArgs

    if ($true -ne $ipSetCheck.result)
    {
        Write-Output "[ERROR] [$($TimeStamp.Invoke())] $CompName errored setting the network adapter, see logs below:" | Out-File $LogFile -Append
        $ipSetCheck | Format-Table -AutoSize -Wrap
        break
    }

    # Install & Configure Initial Services:
    Install-WindowsFeature -Name Bits
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

    workflow Resume-Configuration
    {
        Write-Output "[INFO] [$($TimeStamp.Invoke())] Configuring Active Directory" | Out-File $LogFile -Append
        Set-adServer -passedData $ServerData.adServer
        
        Write-Output "[INFO] [$($TimeStamp.Invoke())] Rebooting server to have the active directory configuration take effect." | Out-File $LogFile -Append
        Restart-Computer -Force -Wait

        Write-Output "[INFO] [$($TimeStamp.Invoke())] Server has rebooted" | Out-File $LogFile -Append
        New-DomainController -FirstReboot

    }

    # Create a scheduled task to recall parent conrol module to continue configuration after reboot:
    $PSPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $Arguments = '-NonInteractive -WindowStyle Hidden -NoLogo -NoProfile -NoExit -Command "& {Import-Module PSWorkflow; Get-Job -State Suspended | Resume-Job}"'
    $Action = New-ScheduledTaskAction -Execute $PSPath -Argument $Arguments
    $Option = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
    $Trigger = New-JobTrigger -AtStartUp -RandomDelay (New-TimeSpan -Seconds 45)
    Register-ScheduledTask  -TaskName 'Resume-Configuration' -Action $Action -Trigger $Trigger -Settings $Option -RunLevel Highest

    Resume-Configuration -AsJob
}