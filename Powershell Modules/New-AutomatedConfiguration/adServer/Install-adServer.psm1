funtion Install-adServer
{
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
}