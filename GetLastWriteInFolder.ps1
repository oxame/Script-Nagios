#########################################################
#
#
# Auteur : arnault Skrabal
#
#
#########################################################

Param(
    [Parameter(Mandatory=$True)]
    [System.IO.FileInfo]$FolderPath,
    [int]$Warning,
    [int]$Critical,
    [string]$Acces
)


$Erreur = ""
$ofs="`r`n"

#$culture = New-Object system.globalization.cultureinfo("fr")
#$today = Get-Date -format ($culture.DateTimeFormat.LongDatePattern)

$today = [DateTime]::Now
$WarningDate = $today.AddHours( - $Warning)
$CriticalDate = $today.AddHours( - $Critical)
$tmpAcces = $today.AddHours( - $Critical)

if(test-path -Path $FolderPath)
{
	foreach($fileFolder in $FolderPath)
	{
		$file = Get-Item -Path $fileFolder 
		if($tmpAcces -lt  $file.LastWriteTime)
		{
			$tmpAcces = $file.LastWriteTime
		}
	}

	if($tmpAcces -eq $CriticalDate)
	{
		$stat = "CRITICAL"
		$ExitCode = 2
	}
	elseif(($tmpAcces -gt $CriticalDate) -and ($tmpAcces -lt $WarningDate))
	{
		$stat = "WARNING"
		$ExitCode = 1
			
	}
	elseif($tmpAcces -gt $WarningDate)
	{
		$stat = "OK"
		$ExitCode = 0
	}
	$Erreur = $file.LastAccessTime
	$Erreur = $file.LastWriteTime

	
}
else
{
	$stat = "CRITICAL"
	$ExitCode = 2
	$Erreur = "Fichier Introuvable"
}




$output = "$stat"+":"+" $Erreur"
Write-Host $output
exit $ExitCode
