function Set-Hostname
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$hostname
    )
    [CmdletBinding]

    Rename-Computer -NewName $hostname -Confirm:$false | Out-Null
}