#!/usr/bin/env pwsh
Invoke-WebRequest -OutFile yq.exe https://github.com/mikefarah/yq/releases/download/v4.3.2/yq_windows_386.exe
Start-Process -Wait -FilePath yq.exe -Argument "/silent" -PassThru
pwd
ls
dir
yq.exe --version