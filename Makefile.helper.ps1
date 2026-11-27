<#
.SYNOPSIS
    Makefile.helper.ps1 - Cross-Platform Dotfiles Deployment Helper for Windows

.DESCRIPTION
    Implements the 3-stage deployment pipeline on Windows:
      Stage 1 (Filter):   Evaluates include/exclude rules (prefixes, globs, re:regex).
                          - user & root: default-allow unless include is specified.
                          - sudo_user:   ignored on Windows.
                          - exclude always takes precedence over include.
      Stage 2 (Remap):    Applies `src:dst` path translations (from -*Map or inline
                          `src:dst` inside -*Hardlink, -*Junction, or -*Copy).
      Stage 3 (Strategy): Resolves deployment strategy using longest-path specificity:
                          - `junction`: Links a directory directly via NTFS Junction
                            and stops recursing into its children.
                          - `hardlink`: Creates real directories and links individual
                            files via NTFS HardLink (recursing into subdirectories so
                            deeper `copy` or `exclude` rules can override specific files).
                          - `copy`:     Standard file copy (also the fallback default).
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("deploy", "remove")]
    [string]$Action,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Package,

    [string]$SkipSudo = "",

    # USER Scope
    [string]$UserInclude  = "",
    [string]$UserExclude  = "",
    [string]$UserMap      = "",
    [string]$UserCopy     = "",
    [string]$UserHardlink = "",
    [string]$UserJunction = "",

    # SUDO_USER Scope (accepted for CLI parity; unused on Windows)
    [string]$SudoInclude  = "",
    [string]$SudoExclude  = "",
    [string]$SudoMap      = "",
    [string]$SudoCopy     = "",

    # ROOT Scope
    [string]$RootInclude  = "",
    [string]$RootExclude  = "",
    [string]$RootMap      = "",
    [string]$RootCopy     = "",
    [string]$RootHardlink = "",
    [string]$RootJunction = ""
)

$ErrorActionPreference = "Stop"

$UserTarget    = if ($env:USER_TARGET)
{ $env:USER_TARGET 
} else
{ $env:USERPROFILE 
}
$RootTarget    = if ($env:ROOT_TARGET)
{ $env:ROOT_TARGET 
} else
{ "C:\" 
}
$GlobalIgnores = @(".DS_Store", ".stow-local-ignore", "Thumbs.db", "desktop.ini")

# ==============================================================================
# 1. Rule Parsing & Path Normalization Helpers
# ==============================================================================

function Split-RuleTokens
{
    param([string]$Raw)
    if ([string]::IsNullOrWhiteSpace($Raw))
    { return @() 
    }
    # Split on unescaped whitespace, then unescape `\ ` into literal spaces
    $tokens = $Raw -split '(?<!\\)\s+' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    return @($tokens | ForEach-Object { $_ -replace '\\ ', ' ' })
}

function Normalize-UnixPath
{
    param([string]$Path)
    if ([string]::IsNullOrEmpty($Path))
    { return "" 
    }
    return ($Path -replace '\\', '/').Trim('/')
}

# Parses raw rule strings into structured objects:
#   @{ Src = ".config/zed"; Dst = "AppData/Local/Zed"; Strategy = "junction"; Length = 11 }
function Parse-RuleList
{
    param(
        [string]$Raw,
        [string]$Strategy = ""
    )
    $results = @()
    foreach ($tok in (Split-RuleTokens -Raw $Raw))
    {
        $srcPart = $tok
        $dstPart = $null

        # Split `src:dst` only if not a `re:` regex pattern
        if (-not $tok.StartsWith("re:") -and $tok.Contains(":"))
        {
            $parts = $tok -split ':', 2
            $srcPart = $parts[0]
            if (-not [string]::IsNullOrWhiteSpace($parts[1]))
            {
                $dstPart = Normalize-UnixPath -Path $parts[1]
            }
        }

        if (-not $srcPart.StartsWith("re:"))
        {
            $srcPart = Normalize-UnixPath -Path $srcPart
        }

        if ([string]::IsNullOrWhiteSpace($srcPart))
        { continue 
        }

        $results += [PSCustomObject]@{
            Src      = $srcPart
            Dst      = $dstPart
            Strategy = $Strategy
            Length   = $srcPart.Length
        }
    }
    return $results
}

# ==============================================================================
# 2. Pattern Matching Engine (Prefixes, Globs, and `re:` Regex)
# ==============================================================================

function Test-PatternMatch
{
    param(
        [string]$RelUnix,
        [string]$Pattern
    )
    if ([string]::IsNullOrWhiteSpace($Pattern))
    { return $false 
    }

    $fileName = Split-Path -Path $RelUnix -Leaf

    if ($Pattern.StartsWith("re:"))
    {
        $rx = $Pattern.Substring(3)
        return ($RelUnix -match $rx -or $fileName -match $rx)
    }

    $patNorm = Normalize-UnixPath -Path $Pattern

    # Exact path or directory prefix match (for non-wildcard rules)
    if (-not ($patNorm.Contains("*") -or $patNorm.Contains("?")))
    {
        return ($RelUnix -eq $patNorm -or $RelUnix.StartsWith("$patNorm/"))
    }

    # Wildcard glob match against full path, prefix, or basename (if no slash in pattern)
    if ($RelUnix -like $patNorm -or $RelUnix -like "$patNorm/*")
    {
        return $true
    }
    if (-not $patNorm.Contains("/") -and ($fileName -like $patNorm))
    {
        return $true
    }

    return $false
}

function Test-MatchesAnyRule
{
    param(
        [string]$RelUnix,
        [object[]]$Rules
    )
    foreach ($r in $Rules)
    {
        if (Test-PatternMatch -RelUnix $RelUnix -Pattern $r.Src)
        {
            return $true
        }
    }
    return $false
}

# ==============================================================================
# 3. Stage 1 (Filter), Stage 2 (Remap), and Stage 3 (Strategy) Resolvers
# ==============================================================================

# Stage 1: Filter check
function Test-ShouldDeploy
{
    param(
        [string]$RelUnix,
        [object[]]$IncludeRules,
        [object[]]$ExcludeRules
    )
    $leaf = Split-Path -Path $RelUnix -Leaf
    if ($GlobalIgnores -contains $leaf)
    { return $false 
    }

    # Exclude always takes precedence
    if ($ExcludeRules.Count -gt 0 -and (Test-MatchesAnyRule -RelUnix $RelUnix -Rules $ExcludeRules))
    {
        return $false
    }

    # If include rules exist, operate in allowlist mode
    if ($IncludeRules.Count -gt 0)
    {
        return (Test-MatchesAnyRule -RelUnix $RelUnix -Rules $IncludeRules)
    }

    # Default-allow
    return $true
}

# Stage 2: Resolve destination path using longest matching mapping rule
function Resolve-MappedDestUnix
{
    param(
        [string]$RelUnix,
        [object[]]$AllMapRules
    )
    $bestMatch = $null
    foreach ($m in $AllMapRules)
    {
        if ([string]::IsNullOrWhiteSpace($m.Dst))
        { continue 
        }
        if ($m.Src.StartsWith("re:"))
        { continue 
        }

        if ($RelUnix -eq $m.Src -or $RelUnix.StartsWith("$($m.Src)/"))
        {
            if ($null -eq $bestMatch -or $m.Length -gt $bestMatch.Length)
            {
                $bestMatch = $m
            }
        }
    }

    if ($null -eq $bestMatch)
    {
        return $RelUnix
    }

    if ($RelUnix -eq $bestMatch.Src)
    {
        return $bestMatch.Dst
    }

    $suffix = $RelUnix.Substring($bestMatch.Src.Length).TrimStart('/')
    return "$($bestMatch.Dst)/$suffix"
}

# Stage 3: Resolve deployment strategy (`junction`, `hardlink`, or `copy`)
# Uses longest-path specificity so deeper file rules override parent folder rules.
function Resolve-Strategy
{
    param(
        [string]$RelUnix,
        [object[]]$StrategyRules,
        [string]$DefaultStrategy = "copy"
    )
    $bestMatch = $null
    foreach ($s in $StrategyRules)
    {
        if (Test-PatternMatch -RelUnix $RelUnix -Pattern $s.Src)
        {
            if ($null -eq $bestMatch -or $s.Length -gt $bestMatch.Length)
            {
                $bestMatch = $s
            }
        }
    }

    if ($null -ne $bestMatch)
    {
        return $bestMatch.Strategy
    }
    return $DefaultStrategy
}

# ==============================================================================
# 4. Filesystem Action Helpers (Deploy & Remove)
# ==============================================================================

function Remove-EmptyParentDirs
{
    param(
        [string]$StartDir,
        [string]$StopRoot
    )
    $normStop = $StopRoot.TrimEnd('\', '/')
    $curr = $StartDir
    while (-not [string]::IsNullOrWhiteSpace($curr) -and $curr.TrimEnd('\', '/') -ne $normStop)
    {
        if (-not (Test-Path -LiteralPath $curr))
        { break 
        }
        $children = @(Get-ChildItem -LiteralPath $curr -Force -ErrorAction SilentlyContinue)
        if ($children.Count -eq 0)
        {
            Remove-Item -LiteralPath $curr -Force
            $curr = Split-Path -Path $curr -Parent
        } else
        {
            break
        }
    }
}

function Invoke-DeployJunction
{
    param(
        [string]$SourceDirAbs,
        [string]$TargetDirAbs
    )
    $parentDir = Split-Path -Path $TargetDirAbs -Parent
    if (-not (Test-Path -LiteralPath $parentDir))
    {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path -LiteralPath $TargetDirAbs)
    {
        $existing = Get-Item -LiteralPath $TargetDirAbs -Force
        if ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
        {
            # Remove existing junction/symlink safely without deleting repo contents
            cmd.exe /c rmdir "`"$TargetDirAbs`"" | Out-Null
        } else
        {
            Remove-Item -LiteralPath $TargetDirAbs -Recurse -Force
        }
    }

    New-Item -ItemType Junction -Path $TargetDirAbs -Target $SourceDirAbs | Out-Null
}

function Invoke-RemoveJunction
{
    param(
        [string]$TargetDirAbs,
        [string]$DestRoot
    )
    if (Test-Path -LiteralPath $TargetDirAbs)
    {
        $existing = Get-Item -LiteralPath $TargetDirAbs -Force
        if ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
        {
            cmd.exe /c rmdir "`"$TargetDirAbs`"" | Out-Null
        } else
        {
            Remove-Item -LiteralPath $TargetDirAbs -Recurse -Force
        }
        $parentDir = Split-Path -Path $TargetDirAbs -Parent
        Remove-EmptyParentDirs -StartDir $parentDir -StopRoot $DestRoot
    }
}

function Invoke-DeployFile
{
    param(
        [string]$SourceFileAbs,
        [string]$TargetFileAbs,
        [string]$Strategy
    )
    $parentDir = Split-Path -Path $TargetFileAbs -Parent
    if (-not (Test-Path -LiteralPath $parentDir))
    {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path -LiteralPath $TargetFileAbs)
    {
        Remove-Item -LiteralPath $TargetFileAbs -Force
    }

    if ($Strategy -eq "hardlink")
    {
        $srcRoot = [System.IO.Path]::GetPathRoot($SourceFileAbs)
        $dstRoot = [System.IO.Path]::GetPathRoot($TargetFileAbs)
        if ($srcRoot -ne $dstRoot)
        {
            Write-Warning "Cross-volume hardlink unsupported ($srcRoot -> $dstRoot) for '$TargetFileAbs'; falling back to copy."
            Copy-Item -LiteralPath $SourceFileAbs -Destination $TargetFileAbs -Force
        } else
        {
            New-Item -ItemType HardLink -Path $TargetFileAbs -Target $SourceFileAbs | Out-Null
        }
    } else
    {
        Copy-Item -LiteralPath $SourceFileAbs -Destination $TargetFileAbs -Force
    }
}

function Invoke-RemoveFile
{
    param(
        [string]$TargetFileAbs,
        [string]$DestRoot
    )
    if (Test-Path -LiteralPath $TargetFileAbs)
    {
        Remove-Item -LiteralPath $TargetFileAbs -Force
        $parentDir = Split-Path -Path $TargetFileAbs -Parent
        Remove-EmptyParentDirs -StartDir $parentDir -StopRoot $DestRoot
    }
}

# ==============================================================================
# 5. Scope Synchronization Engine
# ==============================================================================

function Sync-Scope
{
    param(
        [string]$ScopeName,
        [string]$SourceDir,
        [string]$DestDir,
        [string]$IncludeRaw,
        [string]$ExcludeRaw,
        [string]$MapRaw,
        [string]$CopyRaw,
        [string]$HardlinkRaw,
        [string]$JunctionRaw
    )
    if (-not (Test-Path -LiteralPath $SourceDir))
    { return 
    }

    $srcRootAbs = (Resolve-Path -LiteralPath $SourceDir).Path

    $includeRules  = @(Parse-RuleList -Raw $IncludeRaw)
    $excludeRules  = @(Parse-RuleList -Raw $ExcludeRaw)
    $explicitMaps  = @(Parse-RuleList -Raw $MapRaw)
    $copyRules     = @(Parse-RuleList -Raw $CopyRaw     -Strategy "copy")
    $hardlinkRules = @(Parse-RuleList -Raw $HardlinkRaw -Strategy "hardlink")
    $junctionRules = @(Parse-RuleList -Raw $JunctionRaw -Strategy "junction")

    $allStrategyRules = @($copyRules + $hardlinkRules + $junctionRules)
    # Any rule with `:dst` (explicit map or inline strategy remap) participates in path translation
    $allMapRules      = @($explicitMaps + $allStrategyRules | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Dst) })

    Write-Host "-> [$ScopeName] $($Action.ToUpper()) $SourceDir -> $DestDir"

    # Track directories handled as Junctions so file-level traversal skips their children
    $handledJunctionPrefixes = @()

    # Pass 1: Process Directory Junctions (sorted shallowest-first)
    $allDirs = @(Get-ChildItem -LiteralPath $srcRootAbs -Recurse -Directory -Force |
            Sort-Object { $_.FullName.Length })

    foreach ($dir in $allDirs)
    {
        $relWin  = $dir.FullName.Substring($srcRootAbs.Length).TrimStart('\', '/')
        $relUnix = Normalize-UnixPath -Path $relWin

        # Skip if already inside a parent junction
        $insideJunction = $false
        foreach ($jp in $handledJunctionPrefixes)
        {
            if ($relUnix -eq $jp -or $relUnix.StartsWith("$jp/"))
            {
                $insideJunction = $true
                break
            }
        }
        if ($insideJunction)
        { continue 
        }

        # Stage 1: Filter
        if (-not (Test-ShouldDeploy -RelUnix $relUnix -IncludeRules $includeRules -ExcludeRules $excludeRules))
        {
            continue
        }

        # Stage 3 check: Is this directory configured as a `junction`?
        $strategy = Resolve-Strategy -RelUnix $relUnix -StrategyRules $allStrategyRules -DefaultStrategy "copy"
        if ($strategy -eq "junction")
        {
            # Stage 2: Remap
            $destUnix  = Resolve-MappedDestUnix -RelUnix $relUnix -AllMapRules $allMapRules
            $destWin   = $destUnix -replace '/', '\'
            $targetAbs = Join-Path $DestDir $destWin

            if ($Action -eq "deploy")
            {
                Invoke-DeployJunction -SourceDirAbs $dir.FullName -TargetDirAbs $targetAbs
            } else
            {
                Invoke-RemoveJunction -TargetDirAbs $targetAbs -DestRoot $DestDir
            }

            $handledJunctionPrefixes += $relUnix
        }
    }

    # Pass 2: Process Individual Files (hardlink or copy)
    $allFiles = @(Get-ChildItem -LiteralPath $srcRootAbs -Recurse -File -Force |
            Sort-Object { $_.FullName.Length })

    foreach ($file in $allFiles)
    {
        $relWin  = $file.FullName.Substring($srcRootAbs.Length).TrimStart('\', '/')
        $relUnix = Normalize-UnixPath -Path $relWin

        # Skip files already covered by a directory junction
        $insideJunction = $false
        foreach ($jp in $handledJunctionPrefixes)
        {
            if ($relUnix.StartsWith("$jp/"))
            {
                $insideJunction = $true
                break
            }
        }
        if ($insideJunction)
        { continue 
        }

        # Stage 1: Filter
        if (-not (Test-ShouldDeploy -RelUnix $relUnix -IncludeRules $includeRules -ExcludeRules $excludeRules))
        {
            continue
        }

        # Stage 2: Remap
        $destUnix  = Resolve-MappedDestUnix -RelUnix $relUnix -AllMapRules $allMapRules
        $destWin   = $destUnix -replace '/', '\'
        $targetAbs = Join-Path $DestDir $destWin

        # Stage 3: Strategy (`hardlink` or `copy`)
        $strategy = Resolve-Strategy -RelUnix $relUnix -StrategyRules $allStrategyRules -DefaultStrategy "copy"

        if ($Action -eq "deploy")
        {
            Invoke-DeployFile -SourceFileAbs $file.FullName -TargetFileAbs $targetAbs -Strategy $strategy
        } else
        {
            Invoke-RemoveFile -TargetFileAbs $targetAbs -DestRoot $DestDir
        }
    }
}

# ==============================================================================
# 6. Main Execution Entrypoint
# ==============================================================================

Write-Host "$($Action.ToUpper()): Package '$Package' (Windows Helper)"

# Scope 1: USER (<Package>\USER -> $UserTarget)
Sync-Scope `
    -ScopeName   "user" `
    -SourceDir   (Join-Path $Package "USER") `
    -DestDir     $UserTarget `
    -IncludeRaw  $UserInclude `
    -ExcludeRaw  $UserExclude `
    -MapRaw      $UserMap `
    -CopyRaw     $UserCopy `
    -HardlinkRaw $UserHardlink `
    -JunctionRaw $UserJunction

# Scope 2: ROOT (<Package>\ROOT -> $RootTarget)
Sync-Scope `
    -ScopeName   "root" `
    -SourceDir   (Join-Path $Package "ROOT") `
    -DestDir     $RootTarget `
    -IncludeRaw  $RootInclude `
    -ExcludeRaw  $RootExclude `
    -MapRaw      $RootMap `
    -CopyRaw     $RootCopy `
    -HardlinkRaw $RootHardlink `
    -JunctionRaw $RootJunction
