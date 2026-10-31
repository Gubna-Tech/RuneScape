# User-owned files for LLARS configuration snapshots. PowerShell 5.1 compatible.
# Stage: collect optional themes, Creator registry, and registry-owned script folders.
# Restore: add only missing files; existing different files are never overwritten.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('Stage','Restore')][string]$Mode,
    [Parameter(Mandatory=$true)][string]$Root,
    [Parameter(Mandatory=$true)][string]$Snapshot
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

function Full([string]$Path) { return [IO.Path]::GetFullPath($Path).TrimEnd('\') }
function Assert-Inside([string]$Base, [string]$Path) {
    $baseFull = Full $Base; $pathFull = Full $Path
    if (-not $pathFull.StartsWith($baseFull + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'User file path must remain under the selected LLARS installation.'
    }
}
function Check-PlainPath([string]$Base, [string]$Path) {
    Assert-Inside $Base $Path
    $relative = (Full $Path).Substring((Full $Base).Length + 1)
    if ($relative -match '[\x00-\x1f]' -or $relative -match '[<>|"?*]') { throw 'Invalid user file path.' }
    $cursor = Full $Base
    if ((Get-Item -LiteralPath $cursor).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Root folder is a reparse point.' }
    foreach ($segment in ($relative -split '\\')) {
        if (-not $segment -or $segment -eq '.' -or $segment -eq '..') { throw 'Unsafe user file path.' }
        $cursor = Join-Path $cursor $segment
        if (Test-Path -LiteralPath $cursor) {
            $info = Get-Item -LiteralPath $cursor -Force
            if ($info.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Reparse point in user content.' }
        }
    }
}
function Relative([string]$Base,[string]$Path) { return (Full $Path).Substring((Full $Base).Length + 1) }
function Copy-SafeFile([string]$Source,[string]$Destination) {
    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Copy-Item -LiteralPath $Source -Destination $Destination -ErrorAction Stop
    if ((Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash) {
        throw 'Copied user file failed checksum validation.'
    }
}
function Add-Tree([string]$Path, [string]$Base, [Collections.Generic.HashSet[string]]$Files) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    Check-PlainPath $Base $Path
    if ((Get-Item -LiteralPath $Path -Force).PSIsContainer) {
        # Enumerate one level at a time, checking every directory BEFORE descent.
        # An unchecked -Recurse enumeration could traverse a reparse-point tree.
        $pending = [Collections.Generic.Stack[string]]::new()
        $pending.Push((Full $Path))
        while ($pending.Count -gt 0) {
            $folder = $pending.Pop()
            Check-PlainPath $Base $folder
            foreach ($item in (Get-ChildItem -LiteralPath $folder -Force -ErrorAction Stop)) {
                Check-PlainPath $Base $item.FullName
                if ($item.PSIsContainer) { $pending.Push((Full $item.FullName)) }
                else { [void]$Files.Add((Full $item.FullName)) }
            }
        }
    } else { [void]$Files.Add((Full $Path)) }
}
function Creator-Directories([string]$Base) {
    $file = Join-Path $Base 'Scripts\LLARS Creator Registry.ini'
    if (-not (Test-Path -LiteralPath $file)) { return }
    Check-PlainPath $Base $file
    $section = ''
    $entries = @{}
    foreach ($line in [IO.File]::ReadAllLines($file)) {
        if ($line -match '^\[Item([0-9]+)\]\s*$') {
            $section = $Matches[1]; $entries[$section] = @{}; continue
        }
        if ($line -match '^\[') { $section = ''; continue }
        if ($section -ne '' -and $line -match '^(RootDirectory|RelativeDirectory|FileName)=(.*)$') {
            $entries[$section][$Matches[1]] = $Matches[2].Trim()
        }
    }
    foreach ($item in $entries.Values) {
        if (-not $item.ContainsKey('RootDirectory') -or -not $item.ContainsKey('RelativeDirectory') -or -not $item.ContainsKey('FileName')) { throw 'Incomplete Creator registry record.' }
        $family = $item['RootDirectory']
        if ($family -cne 'Scripts' -and $family -cne 'Scripts - Menu Entry Swapper') { throw 'Unsafe Creator registry root.' }
        $relative = $item['RelativeDirectory']
        if (-not $relative -or $relative -match '^[\\/]' -or $relative -match '(^|[\\/])\.\.?([\\/]|$)' -or $relative -match '[:/\x00-\x1f]' ) { throw 'Unsafe Creator registry directory.' }
        $target = Join-Path (Join-Path $Base $family) $relative
        Check-PlainPath $Base $target
        if (Test-Path -LiteralPath $target) { Write-Output $target }
    }
}

try {
    $Root = Full $Root; $Snapshot = Full $Snapshot
    if (-not (Test-Path -LiteralPath $Root -PathType Container)) { throw 'LLARS installation not found.' }
    if (-not (Test-Path -LiteralPath $Snapshot -PathType Container)) { throw 'Backup snapshot folder not found.' }
    $userFiles = Join-Path $Snapshot 'User Files'
    $manifest = Join-Path $userFiles '.snapshot-sha256.txt'
    # A valid checksum alone does not authorize an arbitrary installation path.
    # Only explicitly user-owned content may be restored from a snapshot.
    function Assert-UserOwned([string]$RelativePath, [string[]]$CreatorRoots) {
        if ($RelativePath -ieq 'Scripts\LLARS Creator Registry.ini') { return }
        if ($RelativePath -match '^(?i:Scripts\\Custom\\).+') { return }
        if ($RelativePath -match '^(?i:Assets\\UI\\header_)([A-Za-z0-9_-]+)\.png$') {
            $id = $Matches[1].ToLowerInvariant()
            if ($id -in @('ribbon','terrain','topographic','honeycomb','mosaic','spiral','digital_wave','polygon_grid','nebula_cloud','shadow_botanica')) {
                throw 'Shipped header images cannot be restored from user snapshots.'
            }
            return
        }
        foreach ($prefix in $CreatorRoots) {
            if ($RelativePath.StartsWith($prefix + '\', [StringComparison]::OrdinalIgnoreCase)) { return }
        }
        throw ('Snapshot contains a non-user-owned file path: ' + $RelativePath)
    }
    if ($Mode -eq 'Stage') {
        if (Test-Path -LiteralPath $userFiles) { throw 'User Files staging destination is not empty.' }
        $files = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $registry = Join-Path $Root 'Scripts\LLARS Creator Registry.ini'
        Add-Tree $registry $Root $files
        Add-Tree (Join-Path $Root 'Scripts\Custom') $Root $files
        foreach ($path in @(Creator-Directories $Root)) { Add-Tree $path $Root $files }
        $assetRoot = Join-Path $Root 'Assets\UI'
        $originals = @('header_ribbon.png','header_terrain.png','header_topographic.png','header_honeycomb.png','header_mosaic.png','header_spiral.png','header_digital_wave.png','header_polygon_grid.png','header_nebula_cloud.png','header_shadow_botanica.png')
        if (Test-Path -LiteralPath $assetRoot) {
            foreach ($file in (Get-ChildItem -LiteralPath $assetRoot -File -Force -ErrorAction Stop)) {
                if ($file.Name -match '^header_[A-Za-z0-9_-]+\.png$' -and $originals -notcontains $file.Name) {
                    Check-PlainPath $Root $file.FullName
                    [void]$files.Add((Full $file.FullName))
                }
            }
        }
        New-Item -ItemType Directory -Path $userFiles -Force | Out-Null
        $lines = [Collections.Generic.List[string]]::new()
        foreach ($source in @($files | Sort-Object)) {
            Check-PlainPath $Root $source
            $relative = Relative $Root $source
            $target = Join-Path $userFiles $relative
            Copy-SafeFile $source $target
            $hash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
            $lines.Add($hash + "`t" + $relative)
        }
        [IO.File]::WriteAllLines($manifest, $lines.ToArray(), ([Text.UTF8Encoding]::new($false)))
        Write-Output ('Staged {0} registered/user-owned file(s).' -f $lines.Count)
    } else {
        # Old backups contain only Config.ini. Compatibility is intentional.
        if (-not (Test-Path -LiteralPath $userFiles)) { exit 0 }
        if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) { throw 'User Files snapshot manifest missing.' }
        $pending = [Collections.Generic.List[object]]::new()
        $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        # Trust only creator folders declared by the backed-up Creator registry.
        $creatorRoots = @()
        foreach ($dir in @(Creator-Directories $userFiles)) {
            $creatorRoots += (Relative $userFiles $dir)
        }
        foreach ($line in [IO.File]::ReadAllLines($manifest)) {
            if ($line -notmatch '^([0-9a-fA-F]{64})\t(.+)$') { throw 'Invalid user snapshot manifest.' }
            $hash = $Matches[1]; $relative = $Matches[2]
            if ($relative -match '[\x00-\x1f]' -or $relative -match '(^|[\\/])\.\.?([\\/]|$)' -or $relative -match '^[\\/]' -or $relative -match ':') { throw 'Unsafe restoration path.' }
            if (-not $seen.Add($relative)) { throw 'Duplicate snapshot entry.' }
            Assert-UserOwned $relative $creatorRoots
            $source = Join-Path $userFiles $relative
            $target = Join-Path $Root $relative
            Check-PlainPath $userFiles $source
            Check-PlainPath $Root $target
            if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw 'Snapshot file missing.' }
            if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -ine $hash) { throw 'Snapshot file does not match its checksum.' }
            if (Test-Path -LiteralPath $target) {
                if ((Get-Item -LiteralPath $target -Force).PSIsContainer) { throw 'File conflicts with an existing directory.' }
                if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ine $hash) { throw ('User file conflict: ' + $relative + '. Resolve manually; no overwrite performed.') }
            } else { $pending.Add(@($source,$target)) }
        }
        $created = [Collections.Generic.List[string]]::new()
        try {
            foreach ($pair in $pending) {
                Copy-SafeFile $pair[0] $pair[1]
                $created.Add($pair[1])
            }
        } catch {
            foreach ($path in $created) { Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue }
            throw
        }
        Write-Output ('Restored {0} missing user-owned file(s); existing files preserved.' -f $created.Count)
    }
} catch { Write-Error ('LLARS User Files: ' + $_.Exception.Message); exit 1 }
