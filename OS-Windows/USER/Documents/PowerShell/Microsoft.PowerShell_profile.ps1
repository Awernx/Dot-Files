# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------------------------------------------------
# PowerShell script that adds sane defaults to any Windows environment
# Location: $PROFILE --> ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# Quick directory navigation
function ..   { Set-Location .. }
function ...  { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function / { Set-Location C:\ }

# Character printing
$e     = [char]27
$reset = "$e[0m"
$dim   = "$e[2m"

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

function this {
    $cv  = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $bld = [int]$cv.CurrentBuild
    $prod = if ($bld -ge 22000) { $cv.ProductName -replace 'Windows 10', 'Windows 11' } else { $cv.ProductName }
    $winOs = "$prod $($cv.DisplayVersion) (Build $bld)"

    $arch     = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
    $kernel   = [System.Environment]::OSVersion.Version.ToString()
    $psVer    = $PSVersionTable.PSVersion.ToString()
    $terminal = if ($env:WT_SESSION) { 'Windows Terminal' } elseif ($env:TERM_PROGRAM) { $env:TERM_PROGRAM } else { 'Console Host' }

    Write-Host "${dim}        Host: ${reset}$env:COMPUTERNAME"
    Write-Host "${dim}          OS: ${reset}⊞ $winOs"
    Write-Host "${dim} Environment: ${reset}PowerShell ($($PSVersionTable.PSEdition))"
    Write-Host "${dim}Architecture: ${reset}$arch"
    Write-Host "${dim}      Kernel: ${reset}$kernel"
    Write-Host "${dim}       Shell: ${reset}⚡ PowerShell $psVer"
    Write-Host "${dim}    Terminal: ${reset}$terminal"
}

function Get-IpInfo {
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

    Write-Host "`n🏠 Internal: "
    Write-Host "  ${dim}       IP:${reset} $ipAddress"
    Write-Host "  ${dim}  Adapter:${reset} $adapterName [$adapterType]"
    Write-Host "  ${dim}      MAC:${reset} $macAddress                 "
    Write-Host "  ${dim}  Gateway:${reset} $routerIp                   "
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

    Write-Host "`n  🌐 Public: "
    Write-Host " ${dim}        IP:${reset} $pubIp "
    Write-Host " ${dim}  Location:${reset} $city, $region, $country`n"
}

Set-Alias -Name ipa -Value Get-IpInfo

# A better compressed view of dir
function l {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )

    $e         = "`e"
    $dim       = "$e[2m"
    $bold      = "$e[1m"
    $brCyan    = "$e[96m"
    $bldCyan   = "$e[1;96m"
    $brYellow  = "$e[93m"
    $brPurple  = "$e[95m"
    $bldPurple = "$e[1;95m"
    $reset     = "$e[0m"

    Get-ChildItem -Force @Args | ForEach-Object {
        $fullPath   = $_.FullName
        $isHidden   = ($_.Attributes -band [System.IO.FileAttributes]::Hidden) -or ($_.Name.StartsWith('.'))
        $linkType   = $_.LinkType
        $isHardLink = $linkType -eq 'HardLink'
        $isSoftLink = $linkType -in @('SymbolicLink', 'Junction')

        $size = if ($isHardLink) {
            "${brYellow}<HARDLINK>${reset}"
        } elseif ($isSoftLink) {
            if ($linkType -eq 'Junction') { "${brYellow}<JUNCTION>${reset}" } else { "${brYellow}<SYMLINK>${reset}" }
        } elseif ($_.PSIsContainer) {
            "<DIR>"
        } elseif ($_.Length -ge 1GB) {
            '{0:N1} GB' -f ($_.Length / 1GB)
        } elseif ($_.Length -ge 1MB) {
            '{0:N1} MB' -f ($_.Length / 1MB)
        } elseif ($_.Length -ge 1KB) {
            '{0:N0} KB' -f ($_.Length / 1KB)
        } else {
            "$($_.Length) B"
        }

        # Resolve hard link targets via $_.Target, falling back to fsutil if needed
        $targets = if ($isHardLink) {
            $rawTargets = if ($_.Target) {
                $_.Target
            } else {
                $drive = [System.IO.Path]::GetPathRoot($fullPath).TrimEnd('\')
                (fsutil hardlink list $fullPath 2>$null) | ForEach-Object { "$drive$_" }
            }
            $rawTargets | Where-Object { $_ -and ($_ -ne $fullPath) }
        } else {
            $_.Target
        }

        $targetSuffix = if (($isHardLink -or $isSoftLink) -and $targets) {
            " ${dim}-> $($targets -join ', ')${reset}"
        } else {
            ''
        }

        $name = if ($isHardLink) {
            $color = if ($isHidden) { $bldPurple } else { $brPurple }
            "${color}$($_.Name)${reset}${targetSuffix}"
        } elseif ($isSoftLink) {
            $color = if ($isHidden -or ($linkType -eq 'Junction')) { $bldPurple } elseif ($_.PSIsContainer) { $bldCyan } else { $brCyan }
            "${color}$($_.Name)${reset}${targetSuffix}"
        } elseif ($isHidden) {
            $color = if ($_.PSIsContainer) { $bldPurple } else { $brPurple }
            "${color}$($_.Name)${reset}"
        } elseif ($_.PSIsContainer) {
            "${bold}$($_.Name)${reset}"
        } else {
            $_.Name
        }

        [PSCustomObject]@{
            Mode   = "${dim}$($_.Mode)${reset}"
            Date   = "${dim}$($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))${reset}"
            Size   = $size
            Name   = $name
        }
    } | Format-Table -AutoSize -HideTableHeaders
}
