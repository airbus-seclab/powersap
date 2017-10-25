  <#
    .Synopsis
      Display version and patch level of all components
    .Description
      Calls DELIVERY_GET_COMPONENT_STATE Remote FM of an SAP system
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
        $cfgParams.Add("SYSNR",  $sysnr)
        $cfgParams.Add("CLIENT", $client)
        $cfgParams.Add("USER", $username)
        $cfgParams.Add("PASSWD", $password)

      Return [SAP.Middleware.Connector.RfcDestinationManager]::GetDestination($cfgParams)
     
     }        


  #-Function Get-SAPRelease: 
    Function Get-SAPRelease() {
      Load-NCo
      $destination = Get-Destination

      #-Metadata--------------------------------------------------------
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("DELIVERY_GET_COMPONENT_STATE")

      # Sets import parameter
      # component name like SAP_BASIS, SAP_ABA, SAP_UI, etc
        $component = "SAP_BASIS"
        $rfcFunction.SetValue("IV_COMPNAME", $component)
        $rfcFunction.SetValue("IV_BUFFERED", "X")

      #-Calls function module
        $rfcFunction.Invoke($destination)

      #-Shows export parameters
        Write-Host "`r`n==== RESULTS ===`r`n"
        Write-Host $component $rfcFunction.GetValue("EV_COMPVERS") "SP" $rfcFunction.GetValue("EV_COMPPALV")
    }

#-Main

Get-SAPRelease

#-End
