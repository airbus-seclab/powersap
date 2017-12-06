<#
    .Synopsis
      Calls SOAP OCS_GET_FILE_INFO
    .Description
      Retrieve OS file information
      Calls the function OCS_GET_FILE_INFO, through the /sap/bc/soap/rfc SOAP 
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
    [alias("d")]
    [string]$directory,

    [parameter(Mandatory = $true)]
    [alias("f")]
    [string]$file
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
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<env:Body>
    <n1:OCS_GET_FILE_INFO xmlns:n1="urn:sap-com:document:sap:rfc:functions" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        <DIR_NAME>'+$directory+'</DIR_NAME>
        <FILE_NAME>'+$file+'</FILE_NAME>
        <DIR_LIST>
            <item></item>
        </DIR_LIST>
    </n1:OCS_GET_FILE_INFO>
</env:Body>
</env:Envelope>'

$soapreq = Invoke-WebRequest $url -Method $method -ContentType "text/xml" -Body $postParams -Headers $Headers

WriteXmlToScreen $soapreq.Content
} 

#-Main

$url = $target+'/sap/bc/soap/rfc'
$method = 'post'

Execute-SOAPRequest  

#-End

