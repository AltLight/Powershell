<#
.SYNOPSIS
   This script is used with windows task scheduler to backup direcories and/or files.
.Description
   This script is used with windows task scheduler to recursivly loop through the hashtble
   and copy each key location to its coorisponding value, overwriting any data that was in
   the values location.
#> 
<#
Version:
--------
   1.0
Created By:
-----------
   Daniel P. Leitz
Date of Creation:
-----------------
   07 April 2020
Last Modified By:
-----------------
   
Date Last Modified:
-------------------
   
#>
function Get-Backups {
    # Create and populate the hashtable of backup source to destination pairs:
    [hashtable]$backups = @{
        "N:\Git" = "E:\Scripts"
    }
    # Loop through the hashtable and forcefully backup keys location to values destination:
    foreach ($item in $backups) {
        # Test if source is reachable path:
        if (Test-Path "$($item.keys)") {
            # Test if destination is reachable path:
            if (Test-Path "$($item.values)") {
                Copy-Item $item.keys $item.values -Force
            }
        }
    }
}
Get-Backups