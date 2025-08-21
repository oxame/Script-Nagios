##############################
#
#  SUPERVISION Tape Job
#
##############################

Param(
    [Parameter(Mandatory=$true)]
	[String]$BackupName
)

asnp VeeamPSSnapin

$ResultCritical = "CRITICAL : "
$ResultWarning = "WARNING : "
$ResultOK = "OK "
$ExitCode = 0

foreach($Backup in [Veeam.Backup.Core.CBackupSession]::GetByJob($(Get-VBRJob -Name $BackupName).Id))
{
    if($Backup.State -eq "Working")
    {
            $ResultOK = "OK : Is Workgin"
            $ExitCode = 0
            break
    }
   
        
    if(($(New-TimeSpan -Start $Backup.EndTime -End $(Get-date)).Days -lt 1))
    {
        if($Backup.Result -eq 'Failed')
        {
            $ResultCritical += " $($Backup.Name) $($Backup.EndTime)"
            $ExitCode = 2
            break
        }
        elseif ($Backup.Result -eq 'Warning')
        {
            $ResultWarning += " $($Backup.Name) $($Backup.EndTime)"
            $ExitCode = 1
            break
        }
        else
        {
            $ResultOK = "OK : $($Backup.EndTime)"
            $ExitCode = 0
            break
        }        
    }

}  





if($ExitCode -eq 2)
{
    Write-Host $ResultCritical
}
elseif($ExitCode -eq 1)
{
    Write-Host $ResultWarning
}
else
{
   Write-Host  $ResultOK
}


exit $ExitCode