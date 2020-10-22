function Get-ImageData
{
    [cmdletbinding()]
    param(
        [string]$SourcePath
    )
    begin
    {
        [string]$defaultDir = "N:\Pictures"
        [array]$picDirs = @()
        [array]$Images = @()
        [array]$fileMetadata = @()
        [int16]$dirLoopCounter = 0
        $StopWatch = [Diagnostics.StopWatch]::StartNew()
        [array]$extensions = @(
            "jpg",
            "png",
            "jpeg",
            "webp",
            "gif"
        )
    
        if (0 -ne $SourcePath.Length)
        {
            if (!(Test-Path -Path $SourcePath))
            {
                Write-Error "User defined path not valid: $SourcePath"
                break
            }
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
            $objShell  = New-Object -ComObject Shell.Application
            $objFolder = $objShell.namespace($dir)
            $totalItems = ($objFolder.Items()).count
            $itemCounter = 1
            Write-Progress `
                -Id 1 `
                -Activity "Getting all image metadata" `
                -Status "Processing pictures in $dir" `
                -PercentComplete (($dirLoopCounter / ($dirCount + 1)) * 100)
            
            $fileMetadata += Get-FileMetaData -folder $dir
        }#foreach $dir
    }#being
    process
    {
        foreach ($File in $fileMetaData)
        {
            Write-Progress `
                -Id 2 `
                -ParentId 1 `
                -Activity "Item $itemCounter of $totalItems" `
                -Status "Parsing Metadata for image attributes: $($file.name)" `
                -PercentComplete ($itemCounter / ($totalItems +1) * 100)
            
                if ($extensions -inotcontains ($File.Name).split('.')[1])
                {
                    break
                }
                Write-Verbose "Processing file '$($File.Path)'"
                $Props = [ordered]@{
                    Name          = $File.Name
                    FullName      = $File.Path
                    Size          = $File.Size
                    Type          = $File.Type
                    Extension     = $File.'File extension'
                    DateCreated   = $File.'Date created'
                    DateModified  = $File.'Date modified'
                    DateAccessed  = $File.'Date accessed'
                    BitDepth      = $File.'Bit depth'
                    HorizontalRes = $File.'Horizontal resolution'
                    VerticalRes   = $File.'Vertical resolution'
                    Width         = $File.Width
                    Height        = $File.Height
                }
                $Images += New-Object -TypeName psobject -Property $Props
            $itemCounter++
        } # foreach $File
    } #process
    end
    {
        $StopWatch.Stop()
        Write-Host "[INFO] Time to process all images: $($StopWatch.Elapsed)"
        return $Images
    }
}