  <#
    .Synopsis
      Display content of a os file
    .Description
      Calls DX_FILE_READ Remote FM of an SAP system
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


  #-Function Get-ReadFile: 
    Function Get-ReadFile () {
    Param(
    [parameter(Mandatory = $true)]
    [alias("f")]
    [string]$file_path
    )
      Load-NCo
      $destination = Get-Destination

      #-Metadata--------------------------------------------------------
      [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
        $destination.Repository.CreateFunction("DX_FILE_READ")

      # Sets import parameter
        $rfcFunction.SetValue("FILENAME", $file_path)
        $rfcFunction.SetValue("SERVER", "")
        $rfcFunction.SetValue("PC", "s")

      #-Calls function module
        $rfcFunction.Invoke($destination)

      #-Shows export parameters
        Write-Host "`r`n==== RESULTS ===`r`n"
        $export = $rfcFunction.GetValue("DATA_TAB") -replace "FIELD DATA=","`r`n"
        Write-Host $export
    }

#-Main

Get-ReadFile

#-End
