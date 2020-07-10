[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

Function Get-JSONfromFolder {
    [Cmdletbinding()]
    Param(
    )
    
    $Dialog = New-Object System.Windows.Forms.OpenFileDialog
    $Dialog.InitialDirectory = $env:HOMEPATH
    $Dialog.Title = "Select JSON File(s)"
    $Dialog.Filter = "JSON (*.json) | *.json"
    $Dialog.Multiselect=$false
    $Result = $Dialog.ShowDialog()

    $file = $Dialog.FileName
    $ReturnObj = Get-Content -Raw -Path $file | ConvertFrom-Json

    if($Result -eq 'OK') {
        Try {
            $Path = $Dialog.FileNames
            Return $ReturnObj
        }
        Catch {
            $Path = $null
            Write-Host -ForegroundColor Yellow "Notice: No file(s) selected."
            Break
        }
    }
    else {
        #Shows upon cancellation of Save Menu
        Write-Host -ForegroundColor Yellow "Notice: No file(s) selected."
        Break
    }
}