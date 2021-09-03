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
    # Define module wide variables.
    [string]$mtSwitch = ($env:NUMBER_OF_PROCESSORS -1)
    [string]$rSwitch = 1
    [string]$wSwitch = 3

    # check if user defined a json file.
    if (($null -eq $jsonPath) -or (0 -eq $jsonPath.Length))
    {
        $fileName = "backup_list.json"
        [string]$jsonPath = $PSScriptRoot + "\" + $fileName
    }

    # validate jsons existance.
    if (($null -eq $jsonPath) -or ("" -eq $jsonPath))
    {
        Write-Error "The 'jsonPath' variable was null or an empty string.`nAborting operations."
        break
    }
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
}