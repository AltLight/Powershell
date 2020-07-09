function Set-adServices
{
    param(
        [Parameter(mandatory = $true)]
        $dnsData,
        [Parameter(mandatory = $true)]
        $dhcpData
    )

    # Confiugre DNS & DHCP
    Write-Output "[INFO] [$($TimeStamp.Invoke())] Installing DNS and DHCP Services" | Out-File $LogFile -Append
    Install-WindowsFeature DNS -IncludeManagementTools
    Install-WindowsFeature DHCP -IncludeManagementTools

    Write-Output "[INFO] [$($TimeStamp.Invoke())] Configuring DNS and DHCP Services" | Out-File $LogFile -Append
    Set-dnsServer -passedData $dnsData
    Set-dhcpServer -passedData $dhcpData

    write-Output "[INFO] [$($TimeStamp.Invoke())] $CompName has finished being configured." | Out-File $LogFile -Append
}
        