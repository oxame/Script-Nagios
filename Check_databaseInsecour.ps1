#########################################################
#
#
# Auteur : arnault Skrabal
#
#
#########################################################

Param(
    [Parameter(Mandatory=$True)]
	[String]$Serveur,
	[String]$Database,
	[String]$Username,
	[String]$Password,
    [int]$Warning,
    [int]$Critical
)

$Erreur = ""
$ExitCode = 0
$stat = "OK"

if(Get-Module -ListAvailable -Name SimplySQL)
{
	try 
	{
		import-module SimplySQL
		$today = [DateTime]::Now

		$WarningDate = $today.AddDays( - $Warning)
		$CriticalDate = $today.AddDays( - $Critical)
		$pass = ConvertTo-SecureString $Password -AsPlainText -Force
		$Cred = New-Object System.Management.Automation.PSCredential ($Username, $pass)

		#Open-MySQLConnection -Server $Serveur -Database insecours -UserName $Username -Password $Password -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
		Open-MySQLConnection -Server $Serveur -Database insecours -Credential $Cred -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
		$ret = $(get-date((Invoke-SqlQuery -Query "SELECT EXP_DATE FROM exp_date;").EXP_DATE))

		if($ret -gt $WarningDate)
		{
			$stat = "OK"
			$Erreur = "Date de mise a jour : $ret"
			$ExitCode = 0		
		}
		elseif(($ret -gt $WarningDate) -and ($ret -gt $CriticalDate))
		{
			$stat = "Warning"
			$Erreur = "Date de mise a jour : $ret"
			$ExitCode = 1		
		}
		elseif($ret -gt $CriticalDate)
		{
			$stat = "Critical"
			$Erreur = "Date de mise a jour : $ret"
			$ExitCode = 2	
		}
	}
	catch
	{
		$stat = "Critical"
		$Erreur = "Exception : " + $_
		$ExitCode = 2
	}
	
}
else
{
    $stat = "CRITICAL"
	$Erreur = "module SimplySQL absent"
	$ExitCode = 2
}


$output = "$stat"+":"+" $Erreur"
Write-Host $output
exit $ExitCode

