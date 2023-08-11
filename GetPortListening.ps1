#########################################################
#
#
# Auteur : arnault Skrabal
#
#
#########################################################

Param(
    [Parameter(Mandatory=$True)]
    [string]$Port,
    [string]$Status
)


if($Port -eq "" -or $Status -eq "")
{
	$stat = "CRITICAL"
	$ExitCode = 2
	$Erreur = "Error Port ou Status non renseigner"
}
else
{
    if (netstat -an | select-string -pattern $Port | select-string -pattern $Status)
    {
        $stat = "OK"
        $ExitCode = 0 
    }
    else
    {
	    $stat = "CRITICAL"
	    $ExitCode = 2
	    $Erreur = "Error Port $Port"
    }
}

Write-Host $stat + " -"  + $Erreur
exit $ExitCode
