if (!(Test-Path -Path $env:ProgramFiles\PowerShell\7 -PathType Container)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/PowerShell-7.1.3-win-x64.msi" -UseBasicParsing -OutFile "PowerShell-7.1.3-win-x64.msi"
    #Start-Process -Wait -FilePath 'msiexec.exe' -ArgumentList '/i "PowerShell-7.1.3-win-x64.msi" /quiet /l* "PowerShell-7.1.3-win-x64.log"'
}
#Invoke-Expression -Command "& '$env:ProgramFiles\PowerShell\7\pwsh.exe' -File Modules.ps1"
