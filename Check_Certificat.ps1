#########################################################
#
#
# Auteur : arnault Skrabal
# Check NPS Certificat
#
#########################################################
Param(
    [Parameter(Mandatory=$True)]
    [int]$Warning,
    [int]$Critical
)

try {

    # Récupérer les certificats du magasin "LocalMachine"
    $certs = Get-ChildItem -Path Cert:\LocalMachine\My
    $CertInfo = ""
    $CertError = 0
    # Parcourir les certificats
    foreach ($cert in $certs) {
        $expirationDate = $cert.NotAfter

        # Vérifier si la date d'expiration est proche (par exemple, dans les 30 jours)
        $daysRemaining = ($expirationDate - (Get-Date)).Days
        if (($daysRemaining -le $Warning) -and ($daysRemaining -gt $Critical)) {

            if($CertError -ne 2) { $CertError = 1 }
            if(!$CertInfo)
            {
                $CertInfo = "Certificat : $($cert.Subject) Date d'expiration : $expirationDate Jours restants : $daysRemaining"
            }
            else
            {
                $CertInfo = "$CertInfo; Certificat : $($cert.Subject) Date d'expiration : $expirationDate Jours restants : $daysRemaining"
            {
        }
        elseif($daysRemaining -le $Critical)
        {
            $CertError = 2

            if(!$CertInfo)
            {
                $CertInfo = "Certificat : $($cert.Subject) Date d'expiration : $expirationDate Jours restants : $daysRemaining"
            }
            else
            {
                $CertInfo = "$CertInfo`nCertificat : $($cert.Subject) Date d'expiration : $expirationDate Jours restants : $daysRemaining"
            }
        }
    }

    if(!$CertError) 
    {
        $stat = "OK"
        $ExitCode = 0
        $out = "Certificat Date OK"
    }
    elseif($CertError -eq 1)
    {
        $stat = "WARNING"
        $ExitCode = 1
		$out = "$CertInfo"
    }
    elseif($CertError -eq 2)
    {
        $stat = "CRITICAL"
        $ExitCode = 2
		$out = "$CertInfo"
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
