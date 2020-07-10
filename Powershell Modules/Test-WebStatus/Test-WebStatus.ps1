
Function Test-WebStatus {
    [Cmdletbinding()]
    Param(
        $PassedHost
    )
    begin {
        # Set script variables:
        $HostName = $PassedHost.hostname
        $url = $PassedHost.url
        $PassRequirement = 200
        $ReturnObj = New-Object psobject
        $Result = $null
    }
    process {
        # Set up Variables:
        $Result = New-Object psobject
        # Try test and return Pass/Fail:
        try {
            if ((Invoke-Webrequest -Uri $url -UseBasicParsing).statuscode -eq $PassRequirement) {
                $Result = "Pass"
    
            }
            else {
                add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12
    
                if ((Invoke-Webrequest -Uri $url).statuscode -eq $PassRequirement) {
                    $Result = "Pass"
                }
            }
        }
        catch {
            $Result = "Fail"
        }
    }
    end {
        # Return Standardized Test Results:
        $ReturnObj | Add-Member NoteProperty "Host" ($HostName)
        $ReturnObj | Add-Member NoteProperty "Test" ("Web Status")
        $ReturnObj | Add-Member NoteProperty "Result" ($Result)
        $ReturnObj | Add-Member NoteProperty "Tested Against" ($url)
        Return $ReturnObj
    }
}