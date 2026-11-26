# 🅲 🅷 🅰 🅽 🅳 🅴 🆁
# ------------------------------------------------------------------------------
# PowerShell profile with sane defaults, custom prompt, and utility functions
# Location: $PROFILE --> ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# ==============================================================================
# 1. ANSI COLORS & STYLING
# ==============================================================================
# Define a centralized ANSI palette compatible with both PowerShell 5.1 and 7+
$e = [char]27
$script:Ansi = @{
    Reset     = "$e[0m"
    Bold      = "$e[1m"
    Dim       = "$e[2m"
    BrYellow  = "$e[93m"
    BrPurple  = "$e[95m"
    BldPurple = "$e[1;95m"
    BrCyan    = "$e[96m"
    BldCyan   = "$e[1;96m"
}

# ==============================================================================
# 2. SHELL & PSREADLINE ENHANCEMENTS
# ==============================================================================
# PSReadLine is pre-loaded in interactive sessions; check module presence without slow disk scans
if (Get-Module -Name PSReadLine) {
    # Use Bash/Emacs-style Ctrl+A (start), Ctrl+E (end), Ctrl+R (history search)
    Set-PSReadLineOption -EditMode Emacs

    # Predictive IntelliSense requires PSReadLine 2.1+ (prevents errors on older Windows PowerShell 5.1)
    if ((Get-Module PSReadLine).Version -ge [version]'2.1.0') {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle InlineView
    }
}

# ==============================================================================
# 3. CUSTOM PROMPT
# ==============================================================================
function prompt {
    # Pre-evaluated Unicode bolt (⚡) avoids casting overhead on every prompt render
    Write-Host "`n⚡ $($ExecutionContext.SessionState.Path.CurrentLocation) ❯" -NoNewline
    return " "
}

# ==============================================================================
# 4. NAVIGATION & QUICK SHORTCUTS
# ==============================================================================
function ..   { Set-Location .. }
function ...  { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function /    { Set-Location C:\ }
function pull { git pull @args }
function reload { . $PROFILE }

# ==============================================================================
# 5. ENHANCED DIRECTORY LISTING (`l` & `lt`)
# ==============================================================================
# Shared helper to format file/folder metadata, sizes, links, and ANSI colors
function Format-FileEntry {
    param(
        [Parameter(Mandatory)][System.IO.FileSystemInfo]$Item,
        [string]$Prefix = ''
    )

    $c          = $script:Ansi
    $fullPath   = $Item.FullName
    $isHidden   = ($Item.Attributes -band [System.IO.FileAttributes]::Hidden) -or $Item.Name.StartsWith('.')
    $linkType   = $Item.LinkType
    $isHardLink = $linkType -eq 'HardLink'
    $isSoftLink = $linkType -in 'SymbolicLink', 'Junction'

    # Format Size / Link Type
    $size = if ($isHardLink) {
        "$($c.BrYellow)<HARDLINK>$($c.Reset)"
    } elseif ($linkType -eq 'Junction') {
        "$($c.BrYellow)<JUNCTION>$($c.Reset)"
    } elseif ($linkType -eq 'SymbolicLink') {
        "$($c.BrYellow)<SYMLINK>$($c.Reset)"
    } elseif ($Item.PSIsContainer) {
        '<DIR>'
    } elseif ($Item.Length -ge 1GB) {
        '{0:N1} GB' -f ($Item.Length / 1GB)
    } elseif ($Item.Length -ge 1MB) {
        '{0:N1} MB' -f ($Item.Length / 1MB)
    } elseif ($Item.Length -ge 1KB) {
        '{0:N0} KB' -f ($Item.Length / 1KB)
    } else {
        "$($Item.Length) B"
    }

    # Resolve link targets (uses native .Target first, falling back to fsutil for hard links)
    $targets = if ($isHardLink) {
        $rawTargets = if ($Item.Target) {
            $Item.Target
        } else {
            $drive = [System.IO.Path]::GetPathRoot($fullPath).TrimEnd('\')
            (fsutil hardlink list $fullPath 2>$null) | ForEach-Object { "$drive$_" }
        }
        $rawTargets | Where-Object { $_ -and ($_ -ne $fullPath) }
    } else {
        $Item.Target
    }

    $targetSuffix = if (($isHardLink -or $isSoftLink) -and $targets) {
        " $($c.Dim)-> $($targets -join ', ')$($c.Reset)"
    } else {
        ''
    }

    # Colorize Name based on link status, visibility, and type
    $nameColor = if ($isHardLink) {
        if ($isHidden) { $c.BldPurple } else { $c.BrPurple }
    } elseif ($isSoftLink) {
        if ($isHidden -or ($linkType -eq 'Junction')) { $c.BldPurple }
        elseif ($Item.PSIsContainer) { $c.BldCyan }
        else { $c.BrCyan }
    } elseif ($isHidden) {
        if ($Item.PSIsContainer) { $c.BldPurple } else { $c.BrPurple }
    } elseif ($Item.PSIsContainer) {
        $c.Bold
    } else {
        ''
    }

    $coloredName = if ($nameColor) {
        "${nameColor}$($Item.Name)$($c.Reset)${targetSuffix}"
    } else {
        "$($Item.Name)${targetSuffix}"
    }

    [PSCustomObject]@{
        Mode = "$($c.Dim)$($Item.Mode)$($c.Reset)"
        Date = "$($c.Dim)$($Item.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))$($c.Reset)"
        Size = $size
        Name = "${Prefix}${coloredName}"
    }
}

# Flat directory listing (supports optional path, filter, and extra Get-ChildItem args)
function l {
    param(
        [Parameter(Position = 0)]
        [string]$Path = '.',

        [Parameter(Position = 1)]
        [string]$Filter,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$ExtraArgs
    )

    if (-not (Test-Path -Path $Path)) {
        Write-Error "Path not found: '$Path'"
        return
    }

    $gciParams = @{
        Path  = $Path
        Force = $true
    }
    if ($Filter) { $gciParams.Filter = $Filter }

    # Only pass @ExtraArgs when non-empty to prevent splatting $null
    $items = if ($ExtraArgs) {
        Get-ChildItem @gciParams @ExtraArgs
    } else {
        Get-ChildItem @gciParams
    }

    $items | ForEach-Object {
        Format-FileEntry -Item $_
    } | Format-Table -AutoSize -HideTableHeaders
}

# Recursive tree directory listing (supports optional target path and max depth)
function lt {
    param(
        [Parameter(Position = 0)]
        [string]$Path = '.',

        [Parameter(Position = 1)]
        [int]$Depth = [int]::MaxValue
    )

    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "Directory not found: '$Path'"
        return
    }

    $c = $script:Ansi

    function Get-TreeNodes {
        param(
            [string]$CurrentPath,
            [string]$Indent,
            [int]$CurrentDepth
        )

        if ($CurrentDepth -gt $Depth) { return }

        # Sort directories first, then files alphabetically
        $items = @(Get-ChildItem -LiteralPath $CurrentPath -Force -ErrorAction SilentlyContinue |
            Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name)

        for ($i = 0; $i -lt $items.Count; $i++) {
            $item      = $items[$i]
            $isLast    = ($i -eq ($items.Count - 1))
            $connector = if ($isLast) { '└── ' } else { '├── ' }
            $prefix    = "$($c.Dim)${Indent}${connector}$($c.Reset)"

            Format-FileEntry -Item $item -Prefix $prefix

            # Recurse into real directories only (prevents symlink/junction loops)
            if ($item.PSIsContainer -and -not $item.LinkType) {
                $nextIndent = $Indent + $(if ($isLast) { '    ' } else { '│   ' })
                Get-TreeNodes -CurrentPath $item.FullName -Indent $nextIndent -CurrentDepth ($CurrentDepth + 1)
            }
        }
    }

    Get-TreeNodes -CurrentPath $Path -Indent '' -CurrentDepth 1 |
        Format-Table -AutoSize -HideTableHeaders
}

# ==============================================================================
# 6. SYSTEM & NETWORK UTILITIES
# ==============================================================================
# Display quick system hardware/OS summary
function this {
    $c   = $script:Ansi
    $cv  = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $bld = [int]$cv.CurrentBuild
    $prod = if ($bld -ge 22000) { $cv.ProductName -replace 'Windows 10', 'Windows 11' } else { $cv.ProductName }
    $winOs = "$prod $($cv.DisplayVersion) (Build $bld)"
    $arch     = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
    $kernel = "Windows NT $([System.Environment]::OSVersion.Version.Major).$([System.Environment]::OSVersion.Version.Minor).$bld.$($cv.UBR)"
    $psVer    = $PSVersionTable.PSVersion.ToString()
    $terminal = if ($env:WT_SESSION) {
        $wtVer = (Get-Process -Name WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1).ProductVersion
        if ($wtVer -match '^\d+\.\d+\.\d+') { "Windows Terminal $($Matches[0])" } else { 'Windows Terminal' }
    } elseif ($env:TERM_PROGRAM) {
        ("$env:TERM_PROGRAM $env:TERM_PROGRAM_VERSION").Trim()
    } else {
        'Console Host'
    }

    $lines = @(
        "$($c.Dim)        Host: $($c.Reset)$env:COMPUTERNAME"
        "$($c.Dim)          OS: $($c.Reset)⊞ $winOs"
        "$($c.Dim)      Kernel: $($c.Reset)$kernel"
        "$($c.Dim)Architecture: $($c.Reset)$arch"
        "$($c.Dim)       Shell: $($c.Reset)⚡ PowerShell $psVer"
        "$($c.Dim)    Terminal: $($c.Reset)$terminal"
    )
    Write-Host ($lines -join "`n")
}

# Display local and public IP details
function Get-IpInfo {
    $c           = $script:Ansi
    $ipAddress   = 'N/A'
    $adapterName = 'N/A'
    $adapterType = 'Unknown/Virtual'
    $macAddress  = 'N/A'
    $routerIp    = 'N/A'

    # Find the primary active IPv4 network interface with a default gateway
    $activeNic = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object {
            $_.OperationalStatus -eq 'Up' -and
            $_.NetworkInterfaceType -ne 'Loopback' -and
            ($_.GetIPProperties().GatewayAddresses.Address.AddressFamily -contains 'InterNetwork')
        } | Select-Object -First 1

    if ($activeNic) {
        $ipProps     = $activeNic.GetIPProperties()
        $adapterName = $activeNic.Name

        $rawMac = $activeNic.GetPhysicalAddress().ToString()
        if ($rawMac.Length -eq 12) {
            $macAddress = ($rawMac -replace '(.{2})(?!$)', '$1:').ToLower()
        }

        $adapterType = switch -Wildcard ($activeNic.NetworkInterfaceType.ToString()) {
            '*Ethernet*'    { 'Ethernet' }
            'Wireless80211' { 'Wi-Fi' }
            'Wwanpp*'       { 'Mobile Broadband (WWAN)' }
            'Loopback'      { 'Loopback' }
            default         { 'Unknown/Virtual' }
        }

        $ipv4 = $ipProps.UnicastAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
        if ($ipv4) { $ipAddress = $ipv4.Address.IPAddressToString }

        $gw = $ipProps.GatewayAddresses | Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
        if ($gw) { $routerIp = $gw.Address.IPAddressToString }
    }

    # Print internal network info immediately before waiting on external HTTP request
    Write-Host (@(
        "`n🏠 Internal:"
        "  $($c.Dim)       IP:$($c.Reset) $ipAddress"
        "  $($c.Dim)  Adapter:$($c.Reset) $adapterName [$adapterType]"
        "  $($c.Dim)      MAC:$($c.Reset) $macAddress"
        "  $($c.Dim)  Gateway:$($c.Reset) $routerIp"
    ) -join "`n")
    [Console]::Out.Flush()

    # Fetch public IP info via curl.exe
    $pubIp = $city = $region = $country = 'N/A'
    $rawJson = curl.exe -4 -fsS --ssl-no-revoke --max-time 3 https://ipinfo.io 2>$null
    if ($rawJson) {
        $data = $rawJson | ConvertFrom-Json
        if ($data.ip)      { $pubIp   = $data.ip }
        if ($data.city)    { $city    = $data.city }
        if ($data.region)  { $region  = $data.region }
        if ($data.country) { $country = $data.country }
    }

    Write-Host (@(
        "`n  🌐 Public:"
        " $($c.Dim)        IP:$($c.Reset) $pubIp"
        " $($c.Dim)  Location:$($c.Reset) $city, $region, $country`n"
    ) -join "`n")
}
Set-Alias -Name ipa -Value Get-IpInfo

# ==============================================================================
# 7. SYSTEM MAINTENANCE & BOOTSTRAP
# ==============================================================================
function upgrade {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop update
        scoop update *
        Write-Host '🧹 Cleaning up Scoop...'
        scoop cleanup *
        scoop cache rm *
    }

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "`n↻ Updating Winget..." -ForegroundColor Cyan
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
    }

    Write-Host "`n✅ All updates and cleanup complete!" -ForegroundColor Green
}

function bootstrap {
    $secondsPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $secondsPath -Name 'ShowSecondsInSystemClock' -Type DWord -Value 1

    $zedExe = "$env:LOCALAPPDATA\Programs\Scoop\apps\zed\current\Zed.exe"
    if (-not (Test-Path $zedExe)) {
        Write-Warning "Zed executable not found at $zedExe. Context menu will still be created."
    }

    foreach ($target in '*', 'Folder') {
        $regPath = "HKCU:\Software\Classes\$target\shell\OpenWithZed"
        $null = New-Item -Path "$regPath\command" -Force
        Set-ItemProperty -LiteralPath $regPath -Name 'MUIVerb' -Value 'Open with Zed'
        Set-ItemProperty -LiteralPath $regPath -Name 'Icon' -Value $zedExe
        Set-ItemProperty -LiteralPath "$regPath\command" -Name '(Default)' -Value "`"$zedExe`" `"%1`""
        Remove-ItemProperty -LiteralPath "$regPath\command" -Name 'DelegateExecute' -ErrorAction SilentlyContinue
    }

    Write-Host 'Bootstrap settings applied!' -ForegroundColor Green
}
