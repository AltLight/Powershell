function Set-adServices
{
    param(
        [Parameter(mandatory = $true)]
        $dnsData,
        [Parameter(mandatory = $true)]
        $dhcpData
    )

    [string]$ModuleName = 'Set-adServices'
    # Confiugre DNS & DHCP
    Write-ToLog -ModuleName $ModuleName -InfoMessage "Installing DNS and DHCP Services"
    Install-WindowsFeature DNS -IncludeManagementTools
    Install-WindowsFeature DHCP -IncludeManagementTools

    Write-ToLog -ModuleName $ModuleName -InfoMessage "Configuring DNS and DHCP Services"
    Set-dnsServer -passedData $dnsData
    Set-dhcpServer -passedData $dhcpData

    Write-ToLog -ModuleName $ModuleName -InfoMessage "$CompName has finished being configured."
}
        