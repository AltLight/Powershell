[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

Function Get-CSVfromFolder {
    [Cmdletbinding()]
    Param(
    )
    
    $Dialog = New-Object System.Windows.Forms.OpenFileDialog
    $Dialog.InitialDirectory = $env:HOMEPATH
    $Dialog.Title = "Select CSV File(s)"
    $Dialog.Filter = "CSV (*.csv) | *.csv"
    $Dialog.Multiselect=$false
    $Result = $Dialog.ShowDialog()

    if($Result -ne 'OK') {
        #Shows upon cancellation of Save Menu
        Write-Host -ForegroundColor Yellow "Notice: No file(s) selected."
        Break
    }
    Try {
        $Path = $Dialog.FileNames
        $ReturnObj = Get-Content -Raw -Path $Path | ConvertFrom-Csv
        Return $ReturnObj
    }
    Catch {
        $Path = $null
        Write-Host -ForegroundColor Yellow "Notice: No file(s) selected."
        Break
    }
}