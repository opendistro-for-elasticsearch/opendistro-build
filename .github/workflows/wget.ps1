#!/usr/bin/env pwsh
wget -OutFile /tmp/yq_windows_386.exe  https://github.com/mikefarah/yq/releases/download/v4.3.2/yq_windows_386.exe
Get-Location
ls
Get-ChildItem
Start-Process -Wait -FilePath /tmp/yq_windows_386.exe -Argument "/silent" -PassThru
yq --version