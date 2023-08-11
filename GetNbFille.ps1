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
    [string]$Exclude,
    [int]$Warning,
    [int]$Critical    
)




if(Test-Path -Path $FolderPath)
{
     $NbFile = Get-ChildItem -Path $FolderPath -Exclude $Exclude  | Measure-Object | select Count

     if(($NbFile.Count -lt $Critical) -and ($NbFile.Count -gt $Warning))
     {
            $output = "Warning : $($NbFile.Count) fichier en attente"
            $ExitCode = 1 
     }
     elseif ($NbFile.Count -gt $Critical)
     {
            $output = "Critical : $($NbFile.Count) fichier en attente"
            $ExitCode = 2
     }
     else
     {
            $output = "Ok : $($NbFile.Count) fichier en attente"
            $ExitCode = 1        
     }
}
else
{
    $output = "Critical : Dossier absent"
    $ExitCode = 2 
}

Write-Host $output
exit $ExitCode
