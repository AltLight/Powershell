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
        [string]$jsonPath
    )

    [string]$mtSwitch = $env:NUMBER_OF_PROCESSORS -1
    [string]$rSwitch = 1
    [string]$wSwitch = 3
    
    if (0 -gt $jsonPath.Length)
    {
        $fileName = "backup_list.json"
        [string]$jsonPath = $PSScriptRoot + "\" + $fileName
    }

    $jsonImport = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

    foreach ($pair in $jsonImport)
    {
        [string]$source = $pair.source
        [string]$destination = $pair.destination
        $cmd = { robocopy $source $destination /MIR /R:$rSwitch /W:$wSwitch /MT:$mtSwitch}

        Invoke-Command $cmd 
    }
}