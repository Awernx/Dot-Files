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

function Get-IpInfo {
    $e = [char]27
    $green    = "$e[0;92m"
    $brgreen  = "$e[1;92m"
    $yellow   = "$e[0;93m"
    $bryellow = "$e[1;93m"
    $reset    = "$e[0m"

    # --- 1. Internal IP Information (~5ms) ---
    $ipAddress   = "N/A"
    $adapterName = "N/A"
    $adapterType = "Unknown/Virtual"
    $macAddress  = "N/A"
    $routerIp    = "N/A"

    $activeNic = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object {
            $_.OperationalStatus -eq 'Up' -and
            $_.NetworkInterfaceType -ne 'Loopback' -and
            ($_.GetIPProperties().GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' })
        } | Select-Object -First 1

    if ($activeNic) {
        $ipProps     = $activeNic.GetIPProperties()
        $adapterName = $activeNic.Name

        $rawMac = $activeNic.GetPhysicalAddress().ToString()
        if ($rawMac.Length -eq 12) {
            $macAddress = ($rawMac -replace '(.{2})(?!$)', '$1:').ToLower()
        }

        $adapterType = switch ($activeNic.NetworkInterfaceType) {
            'Ethernet'        { 'Ethernet' }
            'GigabitEthernet' { 'Ethernet' }
            'FastEthernetT'   { 'Ethernet' }
            'Wireless80211'   { 'Wi-Fi' }
            'Wwanpp'          { 'Mobile Broadband (WWAN)' }
            'Wwanpp2'         { 'Mobile Broadband (WWAN)' }
            'Loopback'        { 'Loopback' }
            default           { 'Unknown/Virtual' }
        }

        $ipv4 = $ipProps.UnicastAddresses |
            Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' } |
            Select-Object -First 1
        if ($ipv4) { $ipAddress = $ipv4.Address.IPAddressToString }

        $gw = $ipProps.GatewayAddresses |
            Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' } |
            Select-Object -First 1
        if ($gw) { $routerIp = $gw.Address.IPAddressToString }
    }

    Write-Host "`n${green}🏠 Internal: ${reset}"
    Write-Host "         IP:${brgreen} $ipAddress            ${reset}"
    Write-Host "    Adapter:${green} $adapterName [$adapterType] ${reset}"
    Write-Host "        MAC:${green} $macAddress             ${reset}"
    Write-Host "    Gateway:${green} $routerIp               ${reset}"
    [Console]::Out.Flush()

    # --- 2. Public IP Information ---
    $pubIp   = "N/A"
    $city    = "N/A"
    $region  = "N/A"
    $country = "N/A"

    $rawJson = curl.exe -4 -fsS --ssl-no-revoke --max-time 3 https://ipinfo.io 2>$null
    if ($rawJson) {
        $data = $rawJson | ConvertFrom-Json
        if ($data.ip)      { $pubIp   = $data.ip }
        if ($data.city)    { $city    = $data.city }
        if ($data.region)  { $region  = $data.region }
        if ($data.country) { $country = $data.country }
    }

    Write-Host "`n${yellow}  🌐 Public: ${reset}"
    Write-Host "         IP:${bryellow} $pubIp                    ${reset}"
    Write-Host "   Location:${yellow} $city, $region, $country ${reset}`n"
}

Set-Alias -Name ipa -Value Get-IpInfo
