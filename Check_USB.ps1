#########################################################
#
#
# Auteur : arnault Skrabal
# Vérifie la presence d'une clef USB
#
#########################################################

Param(
    [Parameter(Mandatory=$True)]
    [string]$FriendlyName
)

try {
    $Ret = Get-PnpDevice -PresentOnly | Where-Object { $_.FriendlyName -match "$FriendlyName" }

    if($Ret.Status -eq 'OK') 
    {
        $stat = "OK"
        $ExitCode = 0
        $out = $Ret.FriendlyName
    }
    else {
        $stat = "CRITICAL"
        $ExitCode = 2
        $out = "$FriendlyName  Non connecté"
    }

}
catch {
    $out = $_
    $ExitCode = 2
    $stat = "CRITICAL"
}


$output = "$stat"+":"+" $out"
Write-Host $output
exit $ExitCode
