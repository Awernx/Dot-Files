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
# open files & folders with Zed Editor
#######################################################################
$ZedExe = "$env:LOCALAPPDATA\Programs\Scoop\apps\zed\current\Zed.exe"

'*','Folder' | ForEach-Object {
    $Path = 'HKCU:\Software\Classes\{0}\shell\pintohome' -f $_
    $null = New-Item -Path "$Path\command" -Force
    Set-ItemProperty -LiteralPath $Path -Name 'MUIVerb' -Value 'Open with Zed'
    Set-ItemProperty -LiteralPath "$Path\command" -Name '(Default)' -Value ('"{0}" "%1"' -f $ZedExe)
    Remove-ItemProperty -LiteralPath "$Path\command" -Name "DelegateExecute" -ErrorAction SilentlyContinue
}
