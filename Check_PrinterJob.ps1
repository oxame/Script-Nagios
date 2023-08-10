#########################################################
#
#
# Auteur : arnault Skrabal
# Check Printer Job
#
#########################################################

Param(
    [Parameter(Mandatory=$True)]
    [int]$Warning,
    [int]$Critical
)


try {

    $out = ""
    $Nb = 0
    foreach($printer in Get-Printer)
    {        
        $Job = Get-PrintJob -ComputerName $env:COMPUTERNAME -PrinterName $printer.Name
        if($Job)
        {
            if($Job.Count -gt $Warning)
            {
                $Nb = $Job.Count
                if($out)
                {
                    $out = $out + ",$($printer.Name): $($Job.Count) Documents"
                }
                else
                {
                    $out = $out + " $($printer.Name): $($Job.Count) Documents"
                }
            }
        }
    }

    if($Nb -eq 0) 
    {
        $stat = "OK"
        $ExitCode = 0
        $out = "Print Job OK"
    }
    elseif(($Nb -ge $Warning)  -and ($Nb -lt $Critical))
    {
        $stat = "WARNING"
        $ExitCode = 1
    }
    elseif($Nb -ge $Critical)
    {
        $stat = "CRITICAL"
        $ExitCode = 2
    }
}
catch {
    $out = $_
    $ExitCode = 3
    $stat = "UNKNOW"
}



$output = "$stat"+":"+" $out"
Write-Host $output
exit $ExitCode
