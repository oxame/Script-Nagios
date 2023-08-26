# ----------------------------------------------------------------------
# Author:       Arnault Skrabal
# Date:         26/08/2023
# Version:      1.0
# ----------------------------------------------------------------------



param(
    [switch] $Failover,
    [switch] $ScopeReplicate
)




try {
    if ($Failover) {
        $FailoverOutput = Get-DhcpServerv4Failover | Select-Object Mode, State, ServerType, PartnerServer
        if ( $FailoverOutput.State -eq "Normal" ) {
           $out = "Failover state is $($FailoverOutput.State) Partener : $($FailoverOutput.PartnerServer)"
           $ExitCode = 0
           $stat = "OK"
        }
        elseif ( $Output.State -ne "Normal" ) 
        {
            if ( $FailoverOutput.State -eq $Null ) 
            {
                $out = "Failover state NOT returned!  Partener : $($FailoverOutput.PartnerServer)"
                $FailoverStateExitCode = 2
                $stat = "CRITICAL"
            }
            else 
            {
                $out = "Failover state is $($FailoverOutput.State) Partener : $($FailoverOutput.PartnerServer)"
                $ExitCode = 2
                $stat = "CRITICAL"
            }
        }
    }

    if($ScopeReplicate)
    {
        $ScopeServer = Get-DhcpServerv4Scope | Select ScopeId
        $ScopeFailOver = Get-DhcpServerv4Failover | select ScopeId

        if($ScopeServer -eq $ScopeFailOver.ScopeId.Count)
        {
            $out = "All Scope replicate"
            $ExitCode = 0
            $stat = "OK"
        }
        else
        {
            $Nb = 0
            $ScopeNeed = ""
            foreach( $ScopeS in $ScopeServer)
            {
               $Trouve = $false
               foreach($SCopeF in $ScopeFailOver.ScopeId )
               {
                    if($SCopeF.IPAddressToString -eq $ScopeS.ScopeId.IPAddressToString)
                    {
                        $Trouve = $true
                        break
                    }
               }

               if(!($Trouve))
               {
                
                $ScopeNeed = $ScopeNeed + " " + $($ScopeS.ScopeId.IPAddressToString)
                $Nb++
               }
            }

            $out = " $Nb Scope Not replicate : $ScopeNeed"
            $ExitCode = 2
            $stat = "WARNING"
        }
    }

}
catch {
    $out = $_
    $ExitCode = 3
    $stat = "UNKNOW"
}



$output = "$stat"+" - "+" $out"
Write-Host $output
exit $ExitCode
