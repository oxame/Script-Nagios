#########################################################
#
#
# Auteur : arnault Skrabal
#
#
#########################################################

Param(
    [Parameter(Mandatory=$True)]
    [System.IO.FileInfo]$filePath,
    [int]$Warning,
    [int]$Critical,
    [string]$Acces
)


$Erreur = ""
$ofs="`r`n"

$culture = New-Object system.globalization.cultureinfo("fr")
$today = Get-Date -format ($culture.DateTimeFormat.LongDatePattern)

$WarningDate = $today.AddHours( - $Warning)
$CriticalDate = $today.AddHours( - $Critical)


if(test-path -Path $filePath)
{
	$file = Get-Item -Path $filePath
	if($Acces -like "LastAccessTime")
	{
		if($CriticalDate -gt $file.LastAccessTime)
		{
			$stat = "CRITICAL"
			$ExitCode = 2
		}
		elseif(($CriticalDate -lt $file.LastAccessTime) -and ($WarningDate -gt $file.LastAccessTime))
		{
			$stat = "WARNING"
			$ExitCode = 1
			
		}
		elseif($WarningDate -lt $file.LastAccessTime)
		{
			$stat = "OK"
			$ExitCode = 0
		}
		$Erreur = $file.LastAccessTime
	}
	elseif ($Acces -like "LastWriteTime")
	{
		if($CriticalDate -gt $file.LastWriteTime)
		{
			$stat = "CRITICAL"
			$ExitCode = 2
			$Erreur = $file.LastWriteTime
		}
		elseif(($CriticalDate -lt $file.LastWriteTime) -and ($WarningDate -gt $file.LastWriteTime))
		{
			$stat = "WARNING"
			$ExitCode = 1
			
		}
		elseif($WarningDate -lt $file.LastWriteTime)
		{
			$stat = "OK"
			$ExitCode = 0
		}
		$Erreur = $file.LastWriteTime
	}
	else
	{
		$output = "Variable Acces non renseigner : LastWriteTime ou LastAccessTime"
	}
	
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
