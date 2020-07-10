

Function Test-HostConnection {
    [Cmdletbinding()]
    Param(
        $PassedHost
    )
    begin {
        # Set script variables:
        $HostName = $PassedHost.hostname
        $ComputerName = $PassedHost.computername
        $PassRequirement = $true
        $ReturnObj = New-Object psobject
        $Result = $null
    }
    process {
        # Set up test:
        $Test = Test-Connection -ComputerName $ComputerName -Count 2 -Quiet

        # Check test results:
        if ($Test -eq $PassRequirement) {
            $Result = "Pass"
        }
        else {
            $Result = "Fail"
        }
    }
    end {
        # Return Standardized Test Results:
        $ReturnObj | Add-Member NoteProperty "Host" ($HostName)
        $ReturnObj | Add-Member NoteProperty "Test" ("Host Connection")
        $ReturnObj | Add-Member NoteProperty "Result" ($Result)
        $ReturnObj | Add-Member NoteProperty "Tested Against" ($ComputerName)
        Return $ReturnObj
    }
}