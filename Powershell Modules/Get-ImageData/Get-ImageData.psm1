function Get-ImageData
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
            [ValidateScript({ (Test-Path -Path $_) })]
            [string]$SourcePath
    )
    
    [string]$defaultDir = "N:\Pictures"
    [array]$picDirs = @()
    [array]$Images = @()
    [array]$skippedItems = @()
    [int16]$dirLoopCounter = 0
    $objShell  = New-Object -ComObject Shell.Application
    $StopWatch = [Diagnostics.StopWatch]::StartNew()
    [array]$extensions = @(
        ".jpg",
        ".png",
        ".jpeg",
        ".webp",
        ".gif"
    )

    if (0 -lt $SourcePath.Length)
    {
        $defaultDir = $SourcePath
    }
    if (!(Test-Path -Path $defaultDir))
    {
        Write-Error "The given image directory cannot be reached: $defaultDir`nAborting operations."
        break
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
        $totalItems = ($objFolder.Items()).count
        $itemCounter = 1
        foreach ($File in $objFolder.items())
        {
            Write-Progress `
                -Id 2 `
                -ParentId 1 `
                -Activity "Item $itemCounter of $totalItems" `
                -Status "Getting image metadata for: $($file.name)" `
                -PercentComplete ($itemCounter / ($totalItems +1) * 100)

            Write-Verbose "Processing file '$($File.Path)'"
            if ($objFolder.getDetailsOf($File, 156) -in $extensions) 
            {
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
            } # if $extensions
            $itemCounter++
        } # foreach $File
    } # foreach $dir
    $StopWatch.Stop()
    Write-Host "[INFO] Time to process all images: $($StopWatch.Elapsed)"
    if (0 -lt $skippedItems.Count)
    {
        Write-Host "Skipped Files:`n"
        $skippedItems | Format-Table -AutoSize -Wrap
    }
    return $Images
}