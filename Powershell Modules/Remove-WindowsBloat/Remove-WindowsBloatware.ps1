
Function Remove-WindowsBloat
{
    [CmdletBinding()]
    Param(
    )

    begin
    {
        $path = "$PSScriptRoot\ms bloat applcications.json"
        if ((Test-Path $path) -eq $true)
        {
            $BloatApps = Get-Content -Path $path | ConvertFrom-Json
        }
        else
        {
            $BloatApps = Get-JSONfromFile
        }
    }
    process
    {
        Foreach ($app in $BloatApps)
        {
            Get-AppxPackage |`
                Where-Object name -match $app |`
                Remove-AppxPackage -AllUsers -Confirm:$false
        }
    }
    end
    {
    }
}