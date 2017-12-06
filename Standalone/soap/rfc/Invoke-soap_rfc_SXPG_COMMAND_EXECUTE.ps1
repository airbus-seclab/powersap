<#
    .Synopsis
      Calls SOAP SXPG_COMMAND_EXECUTE
    .Description
      Execute defined command in SM49/SM69
      Calls the function SXPG_COMMAND_EXECUTE, through the /sap/bc/soap/rfc SOAP 
      $target like : http(s)://ip:port
    .Author
      @_1ggy
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
    [string]$password = $( Read-Host -asSecureString "Input password" ),
    
    [parameter(Mandatory = $true)]
    [alias("r")]
    [string]$command,

    [parameter(Mandatory = $false)]
    [alias("a")]
    [string]$additional_option,

    [parameter(Mandatory = $True)]
    [alias("o")]
    [string]$os
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

$postParams = '<?xml version="1.0" encoding="utf-8" ?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
     <SOAP-ENV:Body>
       <m:SXPG_COMMAND_EXECUTE xmlns:m="urn:sap-com:document:sap:rfc:functions">
        <COMMANDNAME>'+$command+'</COMMANDNAME>
        <ADDITIONAL_PARAMETERS>'+$additional_option+'</ADDITIONAL_PARAMETERS>
        <OPERATINGSYSTEM>'+$os+'</OPERATINGSYSTEM>
        <EXEC_PROTOCOL><ITEM></ITEM></EXEC_PROTOCOL>
       </m:SXPG_COMMAND_EXECUTE>
     </SOAP-ENV:Body>
     </SOAP-ENV:Envelope>'

$soapreq = Invoke-WebRequest $url -Method $method -ContentType "text/xml" -Body $postParams -Headers $Headers

WriteXmlToScreen $soapreq.Content
} 

#-Main

$url = $target+'/sap/bc/soap/rfc'
$method = 'post'

Execute-SOAPRequest  

#-End

