param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("deploy", "remove")]
    [string]$Action,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Package
)

$ErrorActionPreference = "Stop"

$UserTarget      = $env:USER_TARGET
$RootTarget      = $env:ROOT_TARGET
$UserIgnore      = if ($env:USER_IGNORE)       { $env:USER_IGNORE -split '\s+' }       else { @() }
$UserIgnoreRegex = if ($env:USER_IGNORE_REGEX) { $env:USER_IGNORE_REGEX -split '\s+' } else { @() }
$GlobalIgnores   = @(".DS_Store", ".stow-local-ignore", "Thumbs.db", "desktop.ini")

function Sync-Tree {
    param(
        [string]$SourceDir,
        [string]$DestDir,
        [string[]]$IgnorePaths = @(),
        [string[]]$IgnoreRegexes = @()
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

        $targetPath = Join-Path $DestDir $relWin
        if ($Action -eq "deploy") {
            $parentDir = Split-Path -Path $targetPath -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $targetPath -Force
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
    Sync-Tree -SourceDir $userSrc -DestDir $UserTarget -IgnorePaths $UserIgnore -IgnoreRegexes $UserIgnoreRegex
}

$rootSrc = Join-Path $Package "ROOT"
if (Test-Path $rootSrc) {
    Write-Host "-> $($Action.ToUpper()) $Package\ROOT -> $RootTarget"
    Sync-Tree -SourceDir $rootSrc -DestDir $RootTarget
}
