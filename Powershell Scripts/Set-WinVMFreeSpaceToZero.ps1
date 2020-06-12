fucntion Set-WinVMFreeSpaceToZero
{
    param()

    [string]$ModuleName = "Set-WinVMFreeSpaceToZero"
    [string]$DefaultAppPath = 'C:\Program Files\SysInternals\sdelete.exe'
    [array]$ErrorArray = @()
    [array]$DrivesUsed = @()
    $AllDrives = Get-PSDrive | Where-Object 'Root' -Match ':'

    foreach ($Drive in $AllDrives)
    {
        if (($null -eq $Drive.DisplayRoot) -and ('' -or $null -ne $Drive.Free))
        {
            if (Test-Path -Path $DefaultAppPath)
            {
                $DriveLetter = $Drive.Root
                try
                {
                    &$DefaultAppPath -z $DriveLetter /accepteula
                    $DrivesUsed += $DriveLetter
                }
                catch
                {
                    $ErrorMessage = Get-ModuleErrors -ModuleName $ModuleName -ModuleError $_.exception.message
                    $ErrorArray += $ErrorMessage
                }        
            }
        }
    }
    if (0 -ne $ErrorArray.Count)
    {
        $ErrorArray | Format-Table -AutoSize -Wrap
    }
    if (0 -ne $DrivesUsed.Count)
    {
        $DrivesUsed | Format-Table -AutoSize -Wrap
    }
}