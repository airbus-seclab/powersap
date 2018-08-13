  <#
    .Synopsis
      Ping test on SAP system.
    .Description
      Calls the function module RFC_PING and the build-in function Ping 
      of the .NET connector.
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
    
  #-Get-Ping:
    Function Get-Ping () {
      Load-NCo
      $destination = Get-Destination

      #-Metadata--------------------------------------------------------
        [SAP.Middleware.Connector.IRfcFunction]$rfcFunction =
          $destination.Repository.CreateFunction("RFC_PING")

          Write-Host "`r`n==== RESULTS ===`r`n"

      #-Variant 1: Call function module---------------------------------
        Try {
          $rfcFunction.Invoke($destination)
          Write-Host "RFC_PING successful"
        }
        Catch {
          Write-Host "Exception" $_.Exception.Message "occured"
        }

      #-Variant 2: Call build-in function-------------------------------
        Try {
          $destination.Ping()
          Write-Host "Ping successful"
        }
        Catch {
          Write-Host "Exception" $_.Exception.Message "occured"
        }

    }

 #-Main

 Get-Ping

 #-End
