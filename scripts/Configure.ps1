if (not(Test-Path -Path $env:ProgramFiles\PowerShell\7 -PathType Container)) {
    Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi" -UseBasicParsing -OutFile "PowerShell-7.2.1-win-x64.msi"
    msiexec.exe /i "PowerShell-7.2.1-win-x64.msi" /L* "PowerShell-7.2.1-win-x64.log"
}
Invoke-Expression -Command "$env:ProgramFiles\PowerShell\7\pwsh.exe -File Modules.ps1"
