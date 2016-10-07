#This PowerShell script is a template for moving files across a network.

#Specify the source directory that contains your backup files
$source_directory = "\\serverName\folderName"

#order the directory listing such that the newest file is first and assign the filename to a newestFile
$newestFile = Get-ChildItem -Path $dir"\InternationalServices" | Sort-Object CreationTime -Descending | Select-Object -First 1

#with the latest backup, you can now copy it to another location
Copy-Item $dir"\ServerName"\$($newestFile.name) $dir\"folderName\newFileName.bak"
