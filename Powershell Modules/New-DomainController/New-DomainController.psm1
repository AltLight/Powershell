<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER

.EXAMPLE
#>
<#

#>
function New-DomainController
{
    param()
    [CmdletBinding]

    $TimeStamp = [scriptblock]::Create('Get-Date -Format hh:mm:ss')
    $LogFile = "C:/Log/New-DomainController.txt"
    $CompName = $env:COMPUTERNAME
    $ServerData = (Get-Content -Raw -Path ($PSScriptRoot + "\dcInfo.json")  |`
        ConvertFrom-Json) |`
        Where-Object hostname -Match $CompName
        
    if ($null -eq $ServerData)
    {
        write-Output "[ERROR] [$($TimeStamp.Invoke())] No configuration settings found for $CompName, aborting operations." | Out-File $LogFile -Append
        break
    }

    # Configure IPv4 Adapter
    $ipArgs = @{
        "ipv4Address" = $ServerData.ipv4.ip;
        "prefixLength" = $ServerData.ipv4.prefixLength;
        "Gateway" = $ServerData.ipv4.gateway
        "dnsAddress" = $ServerData.ipv4.dnsserver -join ","
    }
    $ipSetCheck = Set-IPv4 @ipArgs

    if ($true -ne $ipSetCheck.result)
    {
        Write-Output "[ERROR] [$($TimeStamp.Invoke())] $CompName errored setting the network adapter, see logs below:" | Out-File $LogFile -Append
        $ipSetCheck | Format-Table -AutoSize -Wrap
        break
    }

    Install-WindowsFeature -Name Bits
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    
    # Resume module after reboot:
    workflow Reboot_Server
    {
        Write-Output "[INFO] [$($TimeStamp.Invoke())] Configuring Active Directory" | Out-File $LogFile -Append
        Set-adServer -passedData $ServerData.adServer
        
        Write-Output "[INFO] [$($TimeStamp.Invoke())] Rebooting server to have the active directory configuration take effect." | Out-File $LogFile -Append

        Restart-Computer -Force -Wait

        Write-Output "[INFO] [$($TimeStamp.Invoke())] Server has rebooted" | Out-File $LogFile -Append
    
        
    }

    $PSPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $Arguments = '-NonInteractive -WindowStyle Hidden -NoLogo -NoProfile -NoExit -Command "& {Import-Module PSWorkflow ; Get-Job | Resume-Job}"'
    $Action = New-ScheduledTaskAction -Execute $PSPath -Argument $Arguments
    $Option = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
    $Trigger = New-JobTrigger -AtStartUp -RandomDelay (New-TimeSpan -Seconds 45)
    Reboot_Server -TaskName ResumeJob -Action $Action -Trigger $Trigger -Settings $Option -RunLevel Highest

    Reboot_Server -AsJob


    # Confiugre DNS & DHCP
    Write-Output "[INFO] [$($TimeStamp.Invoke())] Installing DNS and DHCP Services" | Out-File $LogFile -Append
    Install-WindowsFeature DNS -IncludeManagementTools
    Install-WindowsFeature DHCP -IncludeManagementTools

    Write-Output "[INFO] [$($TimeStamp.Invoke())] Configuring DNS and DHCP Services" | Out-File $LogFile -Append
    Set-dnsServer -passedData $ServerData.dnsServer
    Set-dhcpServer -passedData $ServerData.dhcpServer
}