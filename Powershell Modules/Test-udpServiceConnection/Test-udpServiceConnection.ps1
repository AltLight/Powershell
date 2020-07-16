

Function Test-udpServiceConnection
{
    [Cmdletbinding()]
    Param(
        $PassedHost
    )
    begin
    {
        # Set script variables:
        $HostName = $PassedHost.hostname
        $ComputerName = $PassedHost.computername
        $Port = $PassedHost.serviceports
        
        $udpTest = New-Object System.Net.Sockets.udpClient
        $ReturnObj = New-Object psobject
    }
    process
    {
        $udpServiceResult = New-Object psobject
        try
        {
            $udpTest.Connect($ComputerName, $Port)
            $udpServiceResult = "$Port Pass"
        }
        catch
        {
            $udpServiceResult = "$Port Fail"
        }
        $udpServiceResult | Add-Member NoteProperty "Result" ($udpServiceResult)
    }
    end
    {
        $TestedAgainst = $ComputerName + " : " + $Port

        # Return Standardized Test Results:
        $ReturnObj | Add-Member NoteProperty "Host" ($HostName)
        $ReturnObj | Add-Member NoteProperty "Test" ("UDP Service Connection")
        $ReturnObj | Add-Member NoteProperty "Result" ($udpServiceResult)
        $ReturnObj | Add-Member NoteProperty "Tested Against" ($TestedAgainst)
        Return $ReturnObj
    }
}