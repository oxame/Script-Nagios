#################################################################################
#################################################################################
##################  Written by Efrat [mindU] August 2018  #######################
#################################################################################
###          This Nagios Plugin checks last run status and time               ###
#################################################################################
#################################################################################

# Adding required SnapIn
asnp VeeamPSSnapin

# Global variables
$name = $args[0]
$period = $args[1]
$critical = '0'
$warning = '0'

# Check job type and avoid syntax errors
if ($name -eq 'all'){
    $bck = get-vbrjob
}else{
    $bck = Get-VBRJob -Name $name
    if ($bck -eq $null){
        Write-Host "UNKNOWN! '$name': No such job"
        exit 3
    }
    if ($bck.JobType -ne 'Backup'){
        Write-Host "UNKNOWN! '$name': job type is not 'Backup', this script runs only for 'Backup' jobs."
	    exit 3
    }
}

# Veeam Backup job status check
foreach ($a in $bck){
    $name = $a.Name
    $type = $a.JobType
    $job = Get-vbrjob -Name $name

    if ($type -ne 'BackupSync'){
        $status = $job.GetLastResult()

        if ($status -eq "Failed"){
	        Write-Host "CRITICAL! Errors were encountered during the backup process of the following job: '$name'."
	        $critical = '1'
        }

        if ($status -ne "Success"){
	        Write-Host "WARNING! Job '$name' didn't fully succeed."
	        $warning = '1'
        }

        # Veeam Backup job last run check
        $now = (Get-Date).AddDays(-$period)
        $now = $now.ToString("yyyy-MM-dd")
        
        $last = $job.GetScheduleOptions() | ForEach-Object {"$_".split(',') | ForEach-Object {if (("$_".Contains('Latest run time')) -eq 'True'){("$_".Replace('Latest run time: [','')).Replace(']','')}}}
        if((Get-Date $now) -gt (Get-Date $last)){
	        Write-Host "CRITICAL! Last run of job: '$name' more than $period days ago."
            $critical = '1'
        }else{
	        $log += "Job: '$name' executed $period days ago ** "
        }
    
    }
}

# Calculating exit code
if ($critical -ne '0'){ exit 2 
}elseif ($warning -ne '0'){ exit 1
}else{ write-host $log
exit 0 }
