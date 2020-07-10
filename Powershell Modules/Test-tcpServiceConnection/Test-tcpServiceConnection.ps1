

Function Test-tcpServiceConnection {
    [Cmdletbinding()]
    Param(
        $PassedHost
    )
    begin {
        # Set script variables:
        $HostName = $PassedHost.hostname
        $ComputerName = $PassedHost.computername
        $Port = $PassedHost.serviceports
        
        $tcpTest = New-Object System.Net.Sockets.TcpClient
        $ReturnObj = New-Object psobject
    }
    process {
        $tcpServiceResult = New-Object psobject
        Try {
            $tcpTest.Connect($ComputerName, $Port)
            $tcpServiceResult = "$Port Pass"
        }
        catch {
            $tcpServiceResult = "$Port Fail"
        }
        $tcpServiceResult | Add-Member NoteProperty "Result" ($tcpServiceResult)
    }
    end {
        $TestedAgainst = $ComputerName + " : " + $Port

        # Return Standardized Test Results:
        $ReturnObj | Add-Member NoteProperty "Host" ($HostName)
        $ReturnObj | Add-Member NoteProperty "Test" ("TCP Service Connection")
        $ReturnObj | Add-Member NoteProperty "Result" ($tcpServiceResult)
        $ReturnObj | Add-Member NoteProperty "Tested Against" ($TestedAgainst)
        Return $ReturnObj
    }
}