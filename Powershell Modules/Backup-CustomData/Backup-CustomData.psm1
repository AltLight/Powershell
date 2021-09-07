<#
.DESCRIPTION
    IMPROPER USE OF THIS MODULE WILL CAUSE DATA LOSS!!

    This module leverages robocopy.exe to MIRROR a source to a
    destination. 

    It will loop through a json array, and for each
    json object in the array it will mirror the source value to
    the destination value.
.PARAMETER jsonPath
    A string path to a users specific json file.
.EXAMPLE
    Backup-CustomData
.EXAMPLE
    Backup-CustomData -jsonPath ~\Desktop\example_backup.json
#>

function Backup-CustomData
{
    [cmdletbinding()]
    Param(
        [ValidateScript({$_.split('.')[1] -ieq 'json'})]
        [ValidateScript({$_ | Test-Path})]
        [string]$jsonPath,
        
        [switch]$archive
    )
    # Define module wide variables.
    [string]$mtSwitch = ($env:NUMBER_OF_PROCESSORS -1)
    [string]$rSwitch = 1
    [string]$wSwitch = 3
    [string]$fileName = "backup_list.json"

    if ($archive)
    {
        if (0 -lt $jsonPath.Length)
        {
            Write-Error "User cannot call 'archive' and define a json path.`nAborting operations."
            break
        }
        $fileName = "archive_list.json"
    }
    # check if a json file is defined.
    if (($null -eq $jsonPath) -or (0 -eq $jsonPath.Length))
    {
        [string]$jsonPath = $PSScriptRoot + "\" + $fileName
    }

    # validate jsons existance.
    if (!(Test-Path $jsonPath -ErrorAction SilentlyContinue))
    {
        Write-Error "Could not find path: $jsonPath.`nAborting Operations"
        break
    }

    $jsonImport = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

    # loop and do work
    foreach ($pair in $jsonImport)
    {
        [string]$source = $pair.source
        [string]$destination = $pair.destination
        $cmd = { robocopy $source $destination /MIR /R:$rSwitch /W:$wSwitch /MT:$mtSwitch}

        Invoke-Command $cmd 
    }
}#close function