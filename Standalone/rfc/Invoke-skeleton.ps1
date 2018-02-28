  <#
    .Synopsis
      Skeleton to Calls XXX Remote FM of an SAP system.
    .Description
      Feel free to push your code to the repo :p
    .Author
      @_Sn0rkY
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


  #-Function Get-RFC_FM: 
    Function Get-RFC-FM () {
      Load-NCo
      $destination = Get-Destination

      #-Metadata--------------------------------------------------------
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("XXXXX")

      # Sets import parameter
        $rfcFunction.SetValue("XXXX", "xxx")

      #-Sets import parameter
      # [SAP.Middleware.Connector.IRfcTable]$Input = 
      # $rfcFunction.GetTable("INPUT")
      #  $Input.Append()
      #  $Input.SetValue("FB_NAME", "/SDF/RBE_NATSQL_SELECT")
      #-Here GetValue instead GetTable
       #[SAP.Middleware.Connector.IRfcTable]$Params = $Input.GetValue("PARAMETERS")
       # $Params.Append()
       # $Params.SetValue("PARAM", "XXX")
       # $Params.SetValue("VALUE", "XXX")
       # $Params.Append()
       # $Params.SetValue("PARAM", "XXXX")
       # $Params.SetValue("VALUE", "XXXX")


      #-Calls function module
        $rfcFunction.Invoke($destination)

      #-Shows export parameters
      #TODO: parsing the results
        Write-Host "`r`n==== RESULTS ===`r`n"
        Write-Host $rfcFunction.GetValue("XXXX")     
    }

#-Main

Get-RFC-FM

#-End
