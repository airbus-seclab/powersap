  <#
    .Synopsis
      Display which RFC Destination has a hardcoded credential 
    .Description
      Call remote FM RFC_READ_TABLE on RFCDES table
    .Author
      @_1ggy
  #>

  #-Function Load-NCo: Loads NCo libraries
     Function Load-NCo {

      $ScriptDir = $PsScriptRoot
      
      $Size = [System.IntPtr]::Size
        If ($Size -eq 4) {
        $Path = $ScriptDir + "\..\..\NCo_x86\"
      }
      ElseIf ($Size -eq 8) {
        $Path = $ScriptDir + "\..\..\NCo_x86_64\"
      }

      [Reflection.Assembly]::LoadFile($Path + "sapnco.dll") > $Null
      [Reflection.Assembly]::LoadFile($Path + "sapnco_utils.dll") > $Null

    }

   #-Function Get-Destination: Target and credential
    Function Get-Destination {

    # Set Parameters
    Param(
    [parameter(Mandatory = $true)]
    [alias("t")]
    [string]$target,

    [parameter(Mandatory = $true)]
    [alias("s")]
    [string]$sysnr,	
	
    [parameter(Mandatory = $true)]
    [alias("c")]
    [string]$client,
  
    [parameter(Mandatory = $true)]
    [alias("u")]
    [string]$username,
    
    [parameter(Mandatory = $true)]
    [string]$password = $( Read-Host -asSecureString "Input password" )
    )
    
    #-Connection parameters-------------------------------------------
        $cfgParams = New-Object SAP.Middleware.Connector.RfcConfigParameters
        $cfgParams.Add("NAME", "TEST")
        $cfgParams.Add("ASHOST", $target)
        $cfgParams.Add("SYSNR", $sysnr)
        $cfgParams.Add("CLIENT", $client)
        $cfgParams.Add("USER", $username)
        $cfgParams.Add("PASSWD", $password)

      Return [SAP.Middleware.Connector.RfcDestinationManager]::GetDestination($cfgParams)
     
     }        


  #-Function Get-RFCDES_PWD:
    Function Get-RFCDES_PWD () {
      #-Metadata--------------------------------------------------------
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("RFC_READ_TABLE")

      # Sets import parameter
      [SAP.Middleware.Connector.IRfcTable]$Fields =
        $rfcFunction.GetTable("FIELDS")
        $Fields.Append()
        $Fields.SetValue("FIELDNAME","RFCDEST")
        $Fields.Append()
        $Fields.SetValue("FIELDNAME","RFCTYPE")
        $Fields.Append()
        $Fields.SetValue("FIELDNAME","RFCOPTIONS")

      [SAP.Middleware.Connector.IRfcTable]$Options =
        $rfcFunction.GetTable("OPTIONS")
        $Options.Append()
        $Options.SetValue("TEXT","RFCOPTIONS like '%PWD%'")

      $rfcFunction.SetValue("DELIMITER", "|")
      $rfcFunction.SetValue("NO_DATA", "")
      $rfcFunction.SetValue("QUERY_TABLE", "RFCDES")


      #-Calls function module
        $rfcFunction.Invoke($destination)

      #-Shows export parameters
        Write-Host "`r`n==== RESULTS ===`r`n"
        $export = $rfcFunction.GetTable("DATA") -replace ("FIELD WA=","`r`n")
        Write-Host $export
    }

#-Main
#------
# load Nco
Load-NCo

# Connection
$destination = Get-Destination

Get-RFCDES_PWD

#-End
