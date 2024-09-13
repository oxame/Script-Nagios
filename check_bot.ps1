######################
#
#   Script Nagios NRPE pour retour valeur
#   Bot Python
#
#######################


Param(
    $FileName
)


try {

    if(test-path -path $FileName){
        $Data = get-content -path $FileName

        if($Data -eq "")
        {
            $stat = "CRITICAL"
            $ExitCode = 2
            $out = "Fichier vide"
        }
        else
        {
            if($Data -match 'OK')
            {
                $stat = ""
                $ExitCode = 0
                $out = $Data
            }
            elseif($Data -match 'WARNING')
            {
                $stat = ""
                $ExitCode = 1
                $out = $Data                 
            }
            elseif($Data -match 'CRITICAL')
            {
                $stat = ""
                $ExitCode = 2
                $out = $Data  
            }
            else
            {
                $stat = "UNKNOW"
                $ExitCode = 3
                $out = "Données du fichier $FileName non conforme"                 
            }
        }
    }
    else
    {
        $stat = "CRITICAL"
        $ExitCode = 2
        $out = "Fichier $FileName not Found !"
    }
}
catch {
    $stat = "CRITICAL"
    $ExitCode = 2
    $out = ""
}

if($stat -eq "")
{
    $output = $out
}
else
{
    $output = "$stat"+":"+" $out"
}

Write-Host $output
exit $ExitCode










