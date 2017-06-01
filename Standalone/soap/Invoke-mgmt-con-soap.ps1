  <#
    .Synopsis
      Recover information on SAP Management Console.
    .Description
        Recover information and settings through the SAP Management 
        Console SOAP Interface. 
    .Author
      @_Sn0rkY

    All credit to Chris John Riley
  #>

Param(
[parameter(Mandatory = $true)]
[alias("t")]
[string]$target,

# Second arg should be the file of SAPControl used. eg: GetEnv.xml 
[parameter(Mandatory=$true)]
[string]$SAPControl
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
$soapreq = Invoke-WebRequest $url -Method $method -ContentType "text/xml" -InFile $SAPControl 

WriteXmlToScreen $soapreq.Content

} 

#-Main

$url = 'http://'+$target+':50013/'
$method = 'post'

Execute-SOAPRequest  

#-End

