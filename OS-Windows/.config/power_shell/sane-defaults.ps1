# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ---------------------------------------------------------------------
# PowerShell script that adds sane defaults to any Windows environment

#######################################################################
# Show 'Seconds' in system clock
#######################################################################
$SecondsPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty -Path $SecondsPath -Name "ShowSecondsInSystemClock" -Type DWord -Value "00000001"

#######################################################################
# Add Context Menu to Windows Explorer to 
# open files & folders with VS Code
#######################################################################
$VSCodeExe = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"

if (-not (Test-Path $VSCodeExe)) {
    $VSCodeExe = "$env:ProgramFiles\Microsoft VS Code\Code.exe"
}

'*','Folder' | ForEach-Object {
    $Path = 'HKCU:\Software\Classes\{0}\shell\pintohome' -f $_
    $null = New-Item -Path "$Path\command" -Force
    Set-ItemProperty -LiteralPath $Path -Name 'MUIVerb' -Value 'Open with VS Code'
    Set-ItemProperty -LiteralPath "$Path\command" -Name '(Default)' -Value ('"{0}" "%1"' -f $VSCodeExe)
    Remove-ItemProperty -LiteralPath "$Path\command" -Name "DelegateExecute" -ErrorAction SilentlyContinue
}