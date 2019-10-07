﻿# Show an Open File Dialog and return the file selected by the user
Function Get-Folder($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.SelectedPath = [Environment]::GetFolderPath("LocalApplicationData ")+"\Microsoft\Office"
	$foldername.Description = "Select the location of FSF files" 
	$foldername.ShowNewFolderButton = $false
	if($foldername.ShowDialog() -eq "OK")
		{$folder += $foldername.SelectedPath}
	        else  
        {Write-warning "(OUC-FSF.ps1):" ; Write-Host "User Cancelled" -f White; exit}
    return $Folder
    }

$F = Get-Folder
$Folder = $F +"\"

$File = $Folder+"*.FSF"
Try{write-host "Selected: " (Get-Item $Folder)|out-null}
Catch{Write-warning "(OUC-FSF.ps1):" ; Write-Host "User Cancelled" -f White; exit}

$files = Get-ChildItem $Folder -Filter *.fsf

$output = foreach ($file in $files) {

            [PSCustomObject]@{
            "FSF Name" = $file.Name
            "FSD Name" = ((Get-content -path "$($folder)$($file)" -Encoding Ascii).trimend(05).SubString(21)) -replace ('[\x00]', '') 
            "FSF Lastwritetime" = $file.Lastwritetime
            }
}
$output|Out-GridView -Title "FSF Information - ($($output.count)) FSF files processed" -PassThru

# Saving output to a csv
if($output.count -ge1){$snow = Get-Date -Format FileDateTimeUniversal
$dir = "$($env:TEMP)\ODC-FSF"
if(!(Test-Path -Path $dir )){New-Item -ItemType directory -Path $dir
                             Write-Host "'$($dir)' created" -f yellow}
Write-Host "Saving FSF Information to 'FSF-List-$($snow).csv' in $dir" -f White
$output|Export-Csv -Delimiter "|" -NoTypeInformation -Encoding UTF8 -Path "$($dir)\FSF-List-$($snow).txt" }

Invoke-Item $dir