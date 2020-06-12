<#
.SYNOPSIS
   This module is used to write passed information to a default or
   user defined log file in a standardized way.
.DESCRIPTION
   This module is used to write passed information to a default or
   user defined log file in a standardized way.
.PARAMETER ModuleName
   This is used to identify where the error was derived from. THIS
   SHOULD ALWAYS BE THE MODULE THAT IS CALLING THIS MODULE, AND NOT
   A SUBSECTION OF A MODULE.
.PARAMETER CustomFileLocation
   This allows for the logs to be written in a differend location
   than the defualt log location.
.PARAMETER InfoMessage
   This is used to pass informational messages than need to be
   written to a log file.
.PARAMETER WarningMessage
   This is used to pass warning messages than need to be
   written to a log file.
.PARAMETER ErrorMessage
   This is used to pass error messages than need to be
   written to a log file.
.EXAMPLE
   $ModuleName = Super-AwesomeThing
   Try {
       foo-bar
   }
   catch {
       Write-ToLog -ModuleName $ModuleName -ErrorMessage $.exception.message
    }
.EXAMPLE
   Write-ToLog -ModuleName "Test" -CustomLogLocation "\\remote-server\folder\file.txt" -InfoMessage "This is an example log"
#>
function Write-ToLog {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [string]$CustomLogFileLocation,
        [string]$InfoMessage,
        [string]$WarningMessage,
        [string]$ErrorMessage
    )

    # Sert Module Variables:
    $TimeStamp = { Get-Date -Format hh:mm:ss }
    $Date = { Get-Date -Format MM-dd-yyyy }

    # Set the log file and directory variables:
    if (0 -eq $CustomLogFileLocation.Length) {
        $LogDir = "C:\PowerShellLogs\$Date\$ModuleName\"
        $LogFileName = "$date-$ModuleName.log"
        $FullLogFilePath = $LogDir + $LogFileName
    }
    else {
        $LogDir = (Split-Path $CustomLogFileLocation) + '\'
        $LogFileName = Split-Path $CustomLogFileLocation -Leaf
        $FullLogFilePath = $LogDir + $LogFileName
    }

    # Create Log Directory and/or log file it it/they do not exist:
    if ($false -eq (Test-Path $FullLogFilePath)) {
        if ($false -eq (Test-Path $LogDir)) {
            New-Item $LogDir -ItemType Directory | Out-Null
        }
        if ($false -eq (Test-Path $FullLogFilePath)) {
            New-Item -Name $LogFileName -Path $LogDir | Out-Null
        }
    }

    # Write any/all messages to the log file:
    if ($InfoMessage) {
        "[INFO] [$($TimeStamp)] $ModuleName | $InfoMessage"
    }
    if ($WarningMessage) {
        "[WARNING] [$($TimeStamp)] $ModuleName | $WarningMessage"
    }
    if ($ErrorMessage) {
        "[ERROR] [$($TimeStamp)] $ModuleName | $ErrorMessage"
    }
}