#########################################################
#
#
# Auteur : arnault Skrabal
# Check Printer
#
#########################################################

try {

    $ListPrinter = ""
    $PError = ""
    foreach($printer in Get-Printer)
    {              
        
        if($printer.PrinterStatus -ne 'Normal')
        {
            if($printer.PrinterStatus -eq 'Error')
            {
                 $PError = 2
            }
            else
            {
                if($PError -ne 2) { $PError = 1 }
            }

            if(!$ListPrinter)
            {
                $ListPrinter = "$($printer.Name) $($printer.PrinterStatus)"
            }
            else
            {
                $ListPrinter = "$($ListPrinter), $($printer.Name) $($printer.PrinterStatus)"
            }
        }
    }

    if(!$PError) 
    {
        $stat = "OK"
        $ExitCode = 0
        $out = "Printer OK"
    }
    elseif($PError -eq 1)
    {
        $stat = "WARNING"
        $ExitCode = 1
		$out = "$ListPrinter"
    }
    elseif($PError -eq 2)
    {
        $stat = "CRITICAL"
        $ExitCode = 2
		$out = "$ListPrinter"
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
