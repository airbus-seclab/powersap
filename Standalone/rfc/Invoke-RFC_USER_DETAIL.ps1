  <# 
    .Synopsis
      Retreive all information of provided SAP user, including hashed password
    .Description
      Calls FM BAPI_USER_GET_DETAIL
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

  #-Function Get-UserDetail
    Function Get-UserDetail () {
    Param(
    [parameter(Mandatory = $true)]
    [alias("U")]
    [string]$sap_user
    )
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("BAPI_USER_GET_DETAIL")
        $rfcFunction.SetValue("USERNAME", $sap_user)
        $rfcFunction.Invoke($destination)
        $user_detail = $rfcFunction -replace "FIELD","`r`n"
        Write-Host "`r`n==== RESULTS ===`r`n"
        Write-Host $user_detail
    }

#-Main
#------
# load Nco
Load-NCo

# Connection
$destination = Get-Destination

Get-UserDetail

#-End
