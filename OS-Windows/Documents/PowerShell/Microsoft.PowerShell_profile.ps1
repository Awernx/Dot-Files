# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------------------------------------------------
# PowerShell script that adds sane defaults to any Windows environment
#
# Location: $PROFILE --> ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Link this file using the command below
# New-Item -ItemType SymbolicLink -Path $PROFILE -Target "...\Dot-Files\OS-Windows\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force

if ($PSStyle) {
    # Make directories bold bright white with no background block
    $PSStyle.FileInfo.Directory = "`e[1;97m"
}

# Shell & PSReadLine Enhancements ---
if (Get-Module -ListAvailable -Name PSReadLine) {
    # Predict commands from history as you type (press Right-Arrow to accept)
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView

    # Use Bash/Emacs-style Ctrl+A (start), Ctrl+E (end), Ctrl+R (history search)
    Set-PSReadLineOption -EditMode Emacs
}

function l { Get-ChildItem -Force @args }

# Find the full path of an executable (like Unix 'which')
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Custom Prompt ---
function prompt {
    $bolt = [char]0x26A1
    $currentPath = (Get-Location)
    Write-Host "`n$bolt $currentPath ❯" -NoNewline
    return " "
}

function bootstrap {
    # Show 'Seconds' in system clock
    $SecondsPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $SecondsPath -Name "ShowSecondsInSystemClock" -Type DWord -Value 1

    # Add Context Menu to Windows Explorer to
    # open files & folders with Zed Editor
    $ZedExe = "$env:LOCALAPPDATA\Programs\Scoop\apps\zed\current\Zed.exe"

    '*','Folder' | ForEach-Object {
        $Path = 'HKCU:\Software\Classes\{0}\shell\OpenWithZed' -f $_
        $null = New-Item -Path "$Path\command" -Force
        Set-ItemProperty -LiteralPath $Path -Name 'MUIVerb' -Value 'Open with Zed'
        Set-ItemProperty -LiteralPath $Path -Name 'Icon' -Value $ZedExe
        Set-ItemProperty -LiteralPath "$Path\command" -Name '(Default)' -Value ('"{0}" "%1"' -f $ZedExe)
        Remove-ItemProperty -LiteralPath "$Path\command" -Name "DelegateExecute" -ErrorAction SilentlyContinue
    }

    Write-Host "Bootstrap settings applied!"
}

function upgrade {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop update
        scoop update *
        Write-Host "🧹 Cleaning up Scoop..."
        scoop cleanup *
        scoop cache rm *
    }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "`n↻ Updating Winget..." -ForegroundColor Cyan
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
    }

    Write-Host "`n✅ All updates and cleanup complete!" -ForegroundColor Green
}
