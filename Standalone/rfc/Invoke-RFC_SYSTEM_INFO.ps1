  <#
    .Synopsis
      Calls RFC_SYSTEM_INFO of an SAP system.
    .Description
      Calls the function module RFC_SYSTEM_INFO and writes the result 
      on the screen.
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

    #-Set Parameters
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
    
    #-Connection parameters
        $cfgParams = New-Object SAP.Middleware.Connector.RfcConfigParameters
        $cfgParams.Add("NAME", "TEST")
        $cfgParams.Add("ASHOST", $target)
        $cfgParams.Add("SYSNR", $sysnr)
        $cfgParams.Add("CLIENT", $client)
        $cfgParams.Add("USER", $username)
        $cfgParams.Add("PASSWD", $password)

      Return [SAP.Middleware.Connector.RfcDestinationManager]::GetDestination($cfgParams)
     
     }        

  #-Get-SystemInfo: 
    
    Function Get-SystemInfo () {
      Load-NCo
      $destination = Get-Destination

      #-Metadata
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("RFC_SYSTEM_INFO")
        
      #-Calls function module
        $rfcFunction.Invoke($destination)

        $Export = $rfcFunction.GetStructure("RFCSI_EXPORT")
        
      #-Shows export parameters-----------------------------------------
        Write-Host "`r`n==== RESULTS ==="
        Write-Host "`r`nHostname:" $Export.GetValue("RFCHOST")
      
    }

  #-Main

    Get-SystemInfo

  #-End
