##############################
#
#  SUPERVISION Tape Job
#
##############################

Param(
    [Parameter(Mandatory=$true)]
	[String]$TapeName
)

asnp VeeamPSSnapin

$ResultCritical = "CRITICAL : "
$ResultWarning = "WARNING : "
$ResultOK = "OK "
$ExitCode = 0

foreach($Backup in [Veeam.Backup.Core.CBackupSession]::GetByJob($(Get-VBRTapeJob -Name $TapeName).Id))
{
    if($Backup.State -eq "Working")
    {
            Write-Host "OK : Is Workgin"
            exit 0
			break
    }
    
    if($Backup.State -eq "WaitingTape")
    {
            Write-Host "CRITICAL : Waiting Tape"
            exit 2
			break
    }
   
    if(($(New-TimeSpan -Start $Backup.EndTime -End $(Get-date)).Days -lt 1))
    {
        if($Backup.Result -eq 'Failed')
        {
            Write-Host "CRITICAL :  $($Backup.Name) $($Backup.EndTime)"
            exit 2
			break
        }
        elseif ($Backup.Result -eq 'Warning')
        {
            Write-Host "WARNING :  $($Backup.Name) $($Backup.EndTime)"
            exit 1
			break
        }
        else
        {
            Write-Host "OK : $($Backup.EndTime)"
            exit 0
			break
        }        
    }

}  
