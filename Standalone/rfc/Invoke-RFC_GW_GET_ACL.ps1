  <# TO TEST
    .Synopsis
      Retreive the content of reginfo/secinfo file
    .Description
      Get parameter values with FM SBUF_PARAMETER_GET, check if provided file exist 
      with FM PFL_CHECK_OS_FILE_EXISTENCE then display content with FM DX_FILE_READ 
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

  #-Function Get-FileExistence:
    Function Get-FileExistence ($file) {
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("PFL_CHECK_OS_FILE_EXISTENCE")
        $rfcFunction.SetValue("LONG_FILENAME", $file)
        $rfcFunction.SetValue("FULLY_QUALIFIED_FILENAME", "")
        $rfcFunction.Invoke($destination)
        if ($rfcFunction.GetValue("FILE_EXISTS") -eq "X") { 
          $export = "Yep"
        } else {
          $export = "Nop"
	}
        return $export
    }

  #-Function Get-ParameterValue:
    Function Get-ParameterValue ($parameter) {
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("SBUF_PARAMETER_GET")
        $rfcFunction.SetValue("PARAMETER_NAME", $parameter)
        $rfcFunction.Invoke($destination)
        return $rfcFunction.GetValue("PARAMETER_VALUE")
    }

  #-Function Get-FileRead:
    Function Get-FileRead ($file) {
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("DX_FILE_READ")
        $rfcFunction.SetValue("FILENAME", $file)
        $rfcFunction.SetValue("SERVER", "")
        $rfcFunction.SetValue("PC", "s")
        $rfcFunction.Invoke($destination)
        $export = $rfcFunction.GetValue("DATA_TAB") -replace "FIELD DATA=","`r`n"
        return $export
    }


#-Main
#------
# load Nco
Load-NCo

# Connection
$destination = Get-Destination

# gw acl parameters
$gw_sec_info = "gw/sec_info"
$gw_reg_info = "gw/reg_info"

# get path of acl files
$sec_info_path = Get-ParameterValue($gw_sec_info)
$reg_info_path = Get-ParameterValue($gw_reg_info)

# if file exist, display content
Write-Host "`r`n==== RESULTS ===`r`n"
ForEach($acl_file in $sec_info_path, $reg_info_path) {
  if (Get-FileExistence($acf_file) -eq "Yep") {
    Write-Host "GW ACL file : " $acl_file
    $content = Get-FileRead($acl_file)
    Write-Host $content
  } else {
    Write-Host $acl_file "doesn't exist"
  }
}

#-End
