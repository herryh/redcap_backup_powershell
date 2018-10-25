#
# Redcap project backup Script
# Author: Herry Hamidjaja
# Date: 10/05/2018
# Version 0.0.1
#
# Description: Backup up redcap project including data.
#
param([string]$url="https://redcap.healthinformatics.unimelb.edu.au/api/", [string]$token, [string]$dir)

function PrintUsage() {
    Write-Host ""
    Write-Host "Usage: redcap-backup.ps1 -url [url] -token [token] -output [directory]"
    Write-Host "  -url      url of redcap api"
    Write-Host "  -token    token from import and export from redcap"
    Write-Host "  -output   the output directory"
}


function RedcapBackup() {
    $start_time = Get-Date
    $formFields = @{token=$token;content='project_xml';exportSurveyFields='false';exportDataAccessGroups='false';returnFormat='xml';exportFiles='true'}
    $file_date = Get-Date -UFormat %Y_%m_%d_%H%M
    $tmp = New-TemporaryFile
    $dr = Invoke-WebRequest -Uri "$url" -Method Post -Body $formFields -ContentType "application/x-www-form-urlencoded" -OutFile $tmp
    $xml = [xml](Get-Content $tmp)
    $strs = $xml.ODM.Study.OID.Split(".")
    $title = $strs[1]
    $output = "$dir\$title.$file_date.REDCap.xml"
    Write-Output "Saving $output"
    Move-Item -Path $tmp -Destination $output
    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}


if ($PSBoundParameters.Keys.Count -eq 0 -Or [string]::IsNullOrEmpty($token) -Or [string]::IsNullOrEmpty($dir)) {
    PrintUsage
}else {
    RedcapBackup
}
