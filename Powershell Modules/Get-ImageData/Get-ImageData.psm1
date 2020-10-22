function Get-ImageData
{
    [cmdletbinding()]
    param(
        [string]$SourcePath
    )
    
    [string]$defaultDir = "N:\Pictures"
    [array]$picDirs = @()
    [array]$Images = @()
    [int16]$dirLoopCounter = 0
    $objShell  = New-Object -ComObject Shell.Application
    if (0 -lt $SourcePath.Length)
    {
        Write-Verbose "Testing user defined source path: $SourcePath"
        if (!(Test-Path -Path $SourcePath))
        {
            Write-Error "The user specified source path was not a valid path. Aborting operations,"
            break
        }
        Write-Verbose "User defined source path is valid."
        $defaultDir = $SourcePath
    }
    if (!(Test-Path -Path $SourcePath))
    {
        Write-Error "The given image directory cannot be reached: $defaultDir`nAborting operations."
    }

    $duration =  measure-command {
        $picDirs += Get-ChildItem `
            -Path $defaultDir `
            -Recurse `
            -Directory | `
            Select-Object -ExpandProperty FullName
    }
    [int16]$dirCount = $picDirs.Count
    Write-Verbose "Found $dirCount folder(s) in $($Duration.Minutes):$($Duration.Seconds) mm:ss"
    foreach ($dir in $picDirs)
    {
        $dirLoopCounter++
        Write-Progress `
            -Id 1 `
            -Activity "Getting all image metadata" `
            -Status "Processing pictures in $dir" `
            -PercentComplete (($dirLoopCounter / ($dirCount + 1)) * 100)
        $objFolder = $objShell.namespace($dir)
        foreach ($File in $objFolder.items())
        {
            Write-Progress `
                -Id 2 `
                -ParentId 1 `
                -Activity "Getting image metadata for:" `
                -Status "$($file.name)"
            if ($objFolder.getDetailsOf($File, 156) -in $Extension)
            {
                Write-Verbose "Processing file '$($File.Path)'"
                $Props = [ordered]@{
                    Name          = $File.Name
                    FullName      = $File.Path
                    Size          = $File.Size
                    Type          = $File.Type
                    Extension     = $objFolder.getDetailsOf($File,156)
                    DateCreated   = $objFolder.getDetailsOf($File,3)
                    DateModified  = $objFolder.getDetailsOf($File,4)
                    DateAccessed  = $objFolder.getDetailsOf($File,5)
                    DateTaken     = $objFolder.getDetailsOf($File,12)
                    CameraModel   = $objFolder.getDetailsOf($File,30)
                    CameraMaker   = $objFolder.getDetailsOf($File,32)
                    BitDepth      = [int]$objFolder.getDetailsOf($File,165)
                    HorizontalRes = $objFolder.getDetailsOf($File,166)
                    VerticalRes   = $objFolder.getDetailsOf($File,168)
                    Width         = $objFolder.getDetailsOf($File,167)
                    Height        = $objFolder.getDetailsOf($File,169)
                }
                $Images += New-Object `
                    -TypeName psobject `
                    -Property $Props
            } # if $Extension
        } # foreach $File
    }
    return $Images
}