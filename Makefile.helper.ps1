param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("deploy", "remove")]
    [string]$Action,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Package,

    [string]$CopyList = "",
    [string]$UserLnk = "",
    [string]$RootLnk = "",
    [string]$UserIgnore = "",
    [string]$UserIgnoreRegex = "",
    [string]$SudoInclude = "",
    [string]$SkipSudo = ""
)

$ErrorActionPreference = "Stop"

$UserTarget      = if ($env:USER_TARGET) { $env:USER_TARGET } else { $env:USERPROFILE }
$RootTarget      = if ($env:ROOT_TARGET) { $env:ROOT_TARGET } else { "C:\" }
$UserIgnoreList  = if ($UserIgnore)      { $UserIgnore -split '\s+' }      else { @() }
$UserRegexList   = if ($UserIgnoreRegex) { $UserIgnoreRegex -split '\s+' } else { @() }
$UserLnkList     = if ($UserLnk)         { $UserLnk -split '(?<!\\)\s+' | ForEach-Object { $_ -replace '\\ ', ' ' } } else { @() }
$RootLnkList     = if ($RootLnk)         { $RootLnk -split '(?<!\\)\s+' | ForEach-Object { $_ -replace '\\ ', ' ' } } else { @() }
$GlobalIgnores   = @(".DS_Store", ".stow-local-ignore", "Thumbs.db", "desktop.ini")

function Sync-Tree {
    param(
        [string]$SourceDir,
        [string]$DestDir,
        [string[]]$IgnorePaths = @(),
        [string[]]$IgnoreRegexes = @(),
        [string[]]$LnkPaths = @()
    )
    if (-not (Test-Path $SourceDir)) { return }

    $srcRoot = (Resolve-Path $SourceDir).Path

    Get-ChildItem -Path $srcRoot -Recurse -File -Force | ForEach-Object {
        if ($GlobalIgnores -contains $_.Name) { return }

        $relWin  = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/')
        $relUnix = $relWin -replace '\\', '/'

        foreach ($ign in $IgnorePaths) {
            if ([string]::IsNullOrWhiteSpace($ign)) { continue }
            $ignNorm = ($ign -replace '\\', '/').Trim('/')
            if ($relUnix -eq $ignNorm -or $relUnix.StartsWith("$ignNorm/")) { return }
        }

        foreach ($rx in $IgnoreRegexes) {
            if ([string]::IsNullOrWhiteSpace($rx)) { continue }
            if ($relUnix -match $rx -or $_.Name -match $rx) { return }
        }

        # Check if this file should be deployed as a hard link
        $isHardLink = $false
        $customDestRel = $null
        foreach ($entry in $LnkPaths) {
            if ([string]::IsNullOrWhiteSpace($entry)) { continue }
            $parts = $entry -split ':', 2
            $lnkSrcNorm = ($parts[0] -replace '\\', '/').Trim('/')
            if ($relUnix -eq $lnkSrcNorm -or $relUnix.StartsWith("$lnkSrcNorm/")) {
                $isHardLink = $true
                if ($parts.Count -eq 2 -and -not [string]::IsNullOrWhiteSpace($parts[1])) {
                    $customDestRel = $parts[1] -replace '/', '\'
                }
                break
            }
        }

        $destRel    = if ($customDestRel) { $customDestRel } else { $relWin }
        $targetPath = Join-Path $DestDir $destRel

        if ($Action -eq "deploy") {
            $parentDir = Split-Path -Path $targetPath -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            if ($isHardLink) {
                if (Test-Path $targetPath) {
                    Remove-Item -Path $targetPath -Force
                }
                New-Item -ItemType HardLink -Path $targetPath -Target $_.FullName | Out-Null
            } else {
                Copy-Item -Path $_.FullName -Destination $targetPath -Force
            }
        } else {
            if (Test-Path $targetPath) {
                Remove-Item -Path $targetPath -Force
            }
        }
    }

    if ($Action -eq "remove" -and (Test-Path $DestDir)) {
        Get-ChildItem -Path $srcRoot -Recurse -Directory -Force |
            Sort-Object { $_.FullName.Length } -Descending |
            ForEach-Object {
                $relDir    = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/')
                $targetDir = Join-Path $DestDir $relDir
                if ((Test-Path $targetDir) -and -not (Get-ChildItem -Path $targetDir -Force)) {
                    Remove-Item -Path $targetDir -Force
                }
            }
    }
}

Write-Host "$($Action.ToUpper()) package: $Package"

$userSrc = Join-Path $Package "USER"
if (Test-Path $userSrc) {
    Write-Host "-> $($Action.ToUpper()) $Package\USER -> $UserTarget"
    Sync-Tree -SourceDir $userSrc -DestDir $UserTarget -IgnorePaths $UserIgnoreList -IgnoreRegexes $UserRegexList -LnkPaths $UserLnkList
}

$rootSrc = Join-Path $Package "ROOT"
if (Test-Path $rootSrc) {
    Write-Host "-> $($Action.ToUpper()) $Package\ROOT -> $RootTarget"
    Sync-Tree -SourceDir $rootSrc -DestDir $RootTarget -LnkPaths $RootLnkList
}
