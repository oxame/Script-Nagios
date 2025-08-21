#	Title:			veeam_tape_backup.ps1
#	Description:	This is a Nagios plug-in that will check the last status and
#					last run of a Veeam Backup & Replication tape job passed as 
#					an argument.
#	Author:			Laz Ravelo
#	Date:			2018-01-10
#	Version:		1.0
#	Usage:			veeam_tape_backup.ps1 $name $period
#	Notes:			Credit goes to Tytus Kurek for originally creating the script
#					that would check the same info for non-tape jobs in Veeam.
#=================================================================================

#	Add the Veeam SnapIn

#	Global Variables
$name = $args[0]
$period = $args[1]

#	Get Tape Backup Job info

$job = Get-VBRTapeJob -Name $name -ErrorAction SilentlyContinue

#	Check if job argument is missing
if ($job -eq $null)
{
	Write-Host "No such tape job: $name"
	exit 3
}

#	Check if period argument is missing
if ($period -eq $null)
{
	Write-Host "Missing the period argument!"
	exit 3
}

#	Assign last result of job to variable
$status = $job | select -ExpandProperty "LastResult"
$Working  = $job | select -ExpandProperty "LastState"
#	Nagios output depending on status of last tape backup session
if ($Working  -eq "Working")
{
	Write-Host "OK - Tape backup job: $name is currently in progress."
	exit 0
}
elseif ($Working   -match "Tape")
{
	Write-Host "WARNING! Tape backup job $name $status"
	exit 2
}
elseif ($status -eq "Failed")
{
	Write-Host "CRITICAL! Errors were encountered during the backup process of the following tape backup job: $name."
	exit 2
}
elseif ($status -ne "Success")
{
	Write-Host "WARNING! Tape backup job $name didn't fully succeed."
	exit 1
}
elseif ($status -eq "Success")
{
	Write-Host "OK Tape backup job $name Success."
	exit 0
}
#	Date comparison
$now = (Get-Date).AddDays(-$period)
$now = $now.ToString("yyyy-MM-dd")
$last = get-vbrsession -job $job -Last -WarningAction SilentlyContinue | select -ExpandProperty "CreationTime"
$last = $last.ToString("yyyy-MM-dd")

#	Throw warning if last backup job ran more than x days ago (depends on value of $period)
if((Get-Date $now) -gt (Get-Date $last))
{
	Write-Host "CRITICAL! Last run of job $name happened more than $period days ago."
	exit 2
}
else
{
	Write-Host "OK! Tape backup job $name has completed successfully."
	exit 0
}