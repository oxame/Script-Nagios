#########################################################
#
#
# Auteur : arnault Skrabal
#
#
#########################################################

Param(
    [Parameter(Mandatory=$True)]
	[String]$TaskPath,
	[String[]]$Exlude,
    [int]$Warning,
    [int]$Critical
)

#\2BrightSparks\SyncBackProx64\*

$Erreur = ""
$ExitCode = 0
$stat = "OK"




$OK =0
$WARNING = 1
$CRITICAL = 2


$TaskResult = @{}
$TaskResult.add('0',"Success, no error.")
$TaskResult.add('100',"SyncBackPro did not close because of user interaction or the donotexit parameter was used")
$TaskResult.add('267009',"Running")
$TaskResult.add('4294967196',"The countdown parameter was used and the user aborted it")
$TaskResult.add('4294967195',"An attempt was made to import a profile from the command line and it failed")
$TaskResult.add('4294967194',"The export parameter was used and a profile export failed")
$TaskResult.add('4294967193',"The delete parameter was used and the profile failed to be deleted")
$TaskResult.add('4294967192',"The user aborted the profile run")
$TaskResult.add('4294967191',"The profile name given does not exist")
$TaskResult.add('4294967190',"The profile was not run because it is disabled")
$TaskResult.add('4294967189',"The profile run failed (note that the result of a group profile run is unknown)")
$TaskResult.add('4294967188',"An attempt was made to import a script from the command line and it failed")
$TaskResult.add('4294967187',"An attempt was made to synchronize with the SBM Service from the command line and it failed")
$TaskResult.add('4294967186',"The SyncBackPro serial number is invalid or the evaluation period has expired")
$TaskResult.add('4294967185',"yncBackPro is being run from an external drive and there is no write access to the folder SyncBackPro is being run from")
$TaskResult.add('4294967184',"An encryption key is being used but it cannot be loaded or is corrupt")
$TaskResult.add('4294967183',"The Ransomware Protection failed")

$ResultOK = ""
$ResultKO = ""
$Error = 0
try
{
    $ListTask = Get-ScheduledTask -TaskPath $TaskPath

    if($ListTask.Count -gt 0)
    {
        foreach($Task in $ListTask)
        {
            $ThisTask = Get-ScheduledTaskInfo -TaskName "$($Task.TaskPath)$($Task.TaskName)"
            if($Exlude -notcontains $($Task.TaskName).replace('SyncBackPro ',''))
            {
                if(($($ThisTask.LastTaskResult) -notmatch '4294967190')  -and ($($ThisTask.LastTaskResult) -notmatch '267009'))
                {           
                    
                    try
                    {
                        if($($ThisTask.LastTaskResult) -match '0')
                        {
                            $ResultOK = $ResultOK + ($($Task.TaskName).replace('SyncBackPro','')) + "`r`n"
                        }
                        else
                        {
                            #$ThisTask.LastTaskResult
                            #$TaskResult[[string]$($ThisTask.LastTaskResult)]
                            $Line = $($Task.TaskName).replace('SyncBackPro','') + " " + $($TaskResult[[string]$($ThisTask.LastTaskResult)])
                            $ResultKO = $ResultKO + ($($Task.TaskName).replace('SyncBackPro','')) + "`r`n"
                            $Error = $Error + 1
                        }
                    }
                    catch
                    {

                    }

                    #$ThisTask.LastTaskResult
                    #$TaskResult[[string]$($ThisTask.LastTaskResult)]
                }
            }
        }
    }
    else
    {

    }
}
catch
{
    
}


if($Error -ge $Critical)
{
    foreach( $line in $ResultKO)  
    {  
         $Erreur += $line + "`r`n"
    }
    $stat = "CRITICAL "
    $ExitCode = $CRITICAL
}
elseif ($Error -ge $Warning)
{
    foreach( $line in $ResultKO)  
    {  
         $Erreur += $line + "`r`n"
    }
    $stat = "WARNING "
    $ExitCode = $WARNING
}
elseif($ResultKO.Count -eq 0)
{
    foreach( $line in $ResultOK)  
    {  
         $Erreur += $line + "`r`n"
    }
    $stat = "OK "
    $ExitCode = $OK
}



$output = "$stat"+":"+" $Erreur"
Write-Host $output
exit $ExitCode

Write-Host $ResultKO