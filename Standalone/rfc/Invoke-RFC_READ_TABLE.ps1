  <#
    .Synopsis
      Display SAP Table content
    .Description
      Call remote FM RFC_READ_TABLE on provided table and columns (separate by ,)
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


  #-Function Get-RFC_READ_TABLE:
    Function Get-RFC_READ_TABLE () {
    Param(
    [parameter(Mandatory = $true)]
    [alias("T")]
    [string]$table,

    [parameter(Mandatory = $true, HelpMessage="separate by , ")]
    [alias("f")]
    [string]$fields
    )
      #-Metadata--------------------------------------------------------
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("RFC_READ_TABLE")

      # Sets import parameter
      [SAP.Middleware.Connector.IRfcTable]$Fields_Table =
      $rfcFunction.GetTable("FIELDS")
      foreach($column in $fields.split(",")) {
        $Fields_Table.Append()
        $Fields_Table.SetValue("FIELDNAME", $column)
      }
      $rfcFunction.SetValue("DELIMITER", "|")
      $rfcFunction.SetValue("NO_DATA", "")
      $rfcFunction.SetValue("QUERY_TABLE", $table)

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

Get-RFC_READ_TABLE

#-End
