param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,
    [switch]$Uninstall,
    [switch]$Elevated
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$ProjectRoot = [IO.Path]::GetFullPath($ProjectRoot)
$vendorRoot = Join-Path $ProjectRoot 'Vendor\AutoHotInterception'
$libRoot = Join-Path $vendorRoot 'Lib'
$pendingRestartMarker = Join-Path $vendorRoot '.driver-restart-required'
$setupResultFile = Join-Path $vendorRoot '.setup-result'
$uninstallPendingMarker = Join-Path $vendorRoot '.uninstall-reboot-required'
$uninstalledMarker = Join-Path $vendorRoot '.ahi-uninstalled'
$setupLockFile = Join-Path $vendorRoot '.setup.lock'
$logRoot = Join-Path $vendorRoot 'Logs'
$errorLog = Join-Path $logRoot 'AutoHotInterception-Setup-Error.txt'
$setupLog = Join-Path $logRoot 'AutoHotInterception-Setup.log'
$uninstallWrapper = Join-Path $vendorRoot 'Uninstall AutoHotInterception.cmd'
$driverInstaller = Join-Path $vendorRoot 'install-interception.exe'
$licensesFile = Join-Path $vendorRoot 'LICENSES.txt'
$setupLockHandle = $null

$expectedHashes = @{
    'Lib\AutoHotInterception.ahk' = '39d0e981a743166e292b631c3314671142075538e37b80bce5cd910bc1078f0b'
    'Lib\CLR.ahk' = 'c684eddb313be0587aff0cec634a4bd777baac44a8bea639936cfca80c480cc6'
    'Lib\AutoHotInterception.dll' = 'f993d7c9c9f37f1ff28246cfe620caae9efab92aa0fa1b57a7c615d68d034a17'
    'Lib\x86\interception.dll' = '9e1def27b804df9ba97fd07f9de835c70660ae568c00950102f70034e293a684'
    'Lib\x64\interception.dll' = 'ab88164c11b1b48488772d4c3bfaa4509d5b0ae9dbc5a691dc4f96f0260443c8'
    'install-interception.exe' = 'e137863a79da797f08e7a137280ff2a123809044a888fd75ce9c973198915abe'
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-SetupLog([string]$Message) {
    New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
    Add-Content -LiteralPath $setupLog -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' | ' + $Message) -Encoding UTF8
}

function Write-SetupResult([string]$Value) {
    New-Item -ItemType Directory -Force -Path $vendorRoot | Out-Null
    Set-Content -LiteralPath $setupResultFile -Value $Value -Encoding ASCII
}

function Get-UpperFilters([string]$ClassGuid) {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\$ClassGuid"
    try {
        $value = (Get-ItemProperty -LiteralPath $path -Name UpperFilters -ErrorAction Stop).UpperFilters
        if ($null -eq $value) { return @() }
        return @($value | ForEach-Object { [string]$_ })
    } catch { return @() }
}

function Test-UpperFilter([string]$ClassGuid, [string]$FilterName) {
    foreach ($filter in @(Get-UpperFilters $ClassGuid)) {
        if ([string]::Equals($filter.Trim(), $FilterName, [StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    return $false
}

function Test-DriverRegistered {
    $keyboardClass = '{4D36E96B-E325-11CE-BFC1-08002BE10318}'
    $mouseClass = '{4D36E96F-E325-11CE-BFC1-08002BE10318}'
    $driverRoot = Join-Path $env:SystemRoot 'System32\drivers'
    return ((Test-UpperFilter $keyboardClass 'keyboard') -and
            (Test-UpperFilter $mouseClass 'mouse') -and
            (Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\keyboard') -and
            (Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\mouse') -and
            (Test-Path -LiteralPath (Join-Path $driverRoot 'keyboard.sys')) -and
            (Test-Path -LiteralPath (Join-Path $driverRoot 'mouse.sys')))
}

function Test-DriverFilterResidue {
    $keyboardClass = '{4D36E96B-E325-11CE-BFC1-08002BE10318}'
    $mouseClass = '{4D36E96F-E325-11CE-BFC1-08002BE10318}'
    return ((Test-UpperFilter $keyboardClass 'keyboard') -or (Test-UpperFilter $mouseClass 'mouse'))
}

function Get-InterceptionResidueSnapshot {
    $keyboardClass = '{4D36E96B-E325-11CE-BFC1-08002BE10318}'
    $mouseClass = '{4D36E96F-E325-11CE-BFC1-08002BE10318}'
    $driverRoot = Join-Path $env:SystemRoot 'System32\drivers'
    return [ordered]@{
        KeyboardFilter = (Test-UpperFilter $keyboardClass 'keyboard')
        MouseFilter = (Test-UpperFilter $mouseClass 'mouse')
        KeyboardService = (Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\keyboard')
        MouseService = (Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Services\mouse')
        KeyboardFile = (Test-Path -LiteralPath (Join-Path $driverRoot 'keyboard.sys'))
        MouseFile = (Test-Path -LiteralPath (Join-Path $driverRoot 'mouse.sys'))
    }
}

function Format-InterceptionResidueSnapshot($Snapshot) {
    return ('keyboardFilter={0}; mouseFilter={1}; keyboardService={2}; mouseService={3}; keyboard.sys={4}; mouse.sys={5}' -f `
        $Snapshot.KeyboardFilter, $Snapshot.MouseFilter, $Snapshot.KeyboardService, $Snapshot.MouseService, $Snapshot.KeyboardFile, $Snapshot.MouseFile)
}

function Test-BundledPayload([switch]$InstallerOnly) {
    $keys = if ($InstallerOnly) { @('install-interception.exe') } else { @($expectedHashes.Keys) }
    foreach ($relativePath in $keys) {
        $fullPath = Join-Path $vendorRoot $relativePath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            throw ('BUNDLE: Required bundled file is missing: Vendor\AutoHotInterception\' + $relativePath)
        }
        $actual = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if (-not [string]::Equals($actual, $expectedHashes[$relativePath], [StringComparison]::OrdinalIgnoreCase)) {
            throw ('BUNDLE: Bundled file failed integrity verification: Vendor\AutoHotInterception\' + $relativePath)
        }
    }
    return $true
}

function Unblock-BundledPayload([switch]$InstallerOnly) {
    $keys = if ($InstallerOnly) { @('install-interception.exe') } else { @($expectedHashes.Keys) }
    foreach ($relativePath in $keys) {
        $fullPath = Join-Path $vendorRoot $relativePath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { continue }
        try {
            Unblock-File -LiteralPath $fullPath -ErrorAction Stop
        } catch {
            throw ('BUNDLE: Windows could not unblock Vendor\AutoHotInterception\' + $relativePath + ': ' + $_.Exception.Message)
        }
    }
}

function Get-CurrentBootStamp {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        return $os.LastBootUpTime.ToString('yyyyMMddHHmmss')
    } catch {
        try {
            $raw = (Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
            if ($raw) { return ([string]$raw).Substring(0, 14) }
        } catch { }
    }
    return ''
}

function Clear-UninstallFinalizeSchedule {
    $runOnceKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
    Remove-ItemProperty -LiteralPath $runOnceKey -Name 'LLARS-AHI-Finalize-Uninstall' -ErrorAction SilentlyContinue
}

function Invoke-DriverInstaller([string]$Installer, [string]$Argument) {
    $workingDir = Split-Path -Parent $Installer
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Installer
    $psi.Arguments = $Argument
    $psi.WorkingDirectory = $workingDir
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $process = [Diagnostics.Process]::Start($psi)
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    return [pscustomobject]@{ ExitCode = [int]$process.ExitCode; Output = (($stdout + "`r`n" + $stderr).Trim()) }
}

function Remove-LLARSAhiLocalState {
    # Keep only the uninstall wrapper while cleanup is running;
    # the one-reboot marker is recreated immediately afterward.
    if (Test-Path -LiteralPath $vendorRoot) {
        foreach ($item in @(Get-ChildItem -LiteralPath $vendorRoot -Force)) {
            if ([string]::Equals($item.FullName, $uninstallWrapper, [StringComparison]::OrdinalIgnoreCase) -or
                [string]::Equals($item.FullName, $setupLockFile, [StringComparison]::OrdinalIgnoreCase)) { continue }
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# Keep a normal PowerShell parent alive while one elevated child performs the
# privileged install/uninstall. This gives LLARS a reliable post-UAC return.
if (-not $Elevated -and -not (Test-IsAdministrator)) {
    try {
        $exe = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"{0}"' -f $PSCommandPath),'-ProjectRoot',('"{0}"' -f $ProjectRoot),'-Elevated')
        if ($Uninstall) { $argList += '-Uninstall' }
        $child = Start-Process -FilePath $exe -Verb RunAs -ArgumentList $argList -Wait -PassThru -ErrorAction Stop
        try { Write-SetupLog ('Bootstrap observed elevated child exit code: ' + [int]$child.ExitCode) } catch { }
        exit [int]$child.ExitCode
    } catch {
        if ($_.Exception.NativeErrorCode -eq 1223) {
            try { Write-SetupLog 'Bootstrap: UAC was cancelled by the user.' } catch { }
            exit 1223
        }
        try { Write-SetupLog ('Bootstrap failure: ' + $_.Exception.Message) } catch { }
        throw
    }
}

try {
    New-Item -ItemType Directory -Force -Path $vendorRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

    # Exclusive handle serializes setup while tolerating a stale lock file.
    $deadline = [DateTime]::UtcNow.AddSeconds(20)
    while ($null -eq $setupLockHandle) {
        try {
            $setupLockHandle = [IO.File]::Open($setupLockFile, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
        } catch [IO.IOException] {
            if ([DateTime]::UtcNow -ge $deadline) { throw 'Timed out waiting for another LLARS AHI setup process to finish.' }
            Start-Sleep -Milliseconds 250
        }
    }

    Remove-Item -LiteralPath $setupResultFile -Force -ErrorAction SilentlyContinue
    Add-Content -LiteralPath $setupLog -Value ('LLARS AutoHotInterception setup | ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' | PID=' + $PID + ' | Mode=' + $(if ($Uninstall) { 'Uninstall' } else { 'Install' })) -Encoding UTF8

    if ($Uninstall) {
        Clear-UninstallFinalizeSchedule
        Test-BundledPayload -InstallerOnly | Out-Null
        Unblock-BundledPayload -InstallerOnly
        $before = Get-InterceptionResidueSnapshot
        Write-SetupLog ('Uninstall preflight: ' + (Format-InterceptionResidueSnapshot $before))
        $driverRun = Invoke-DriverInstaller $driverInstaller '/uninstall'
        Write-SetupLog ('Interception /uninstall output: ' + ($driverRun.Output -replace "`r?`n", ' | '))
        Write-SetupLog ('Interception /uninstall exit code: ' + $driverRun.ExitCode)
        if ($driverRun.ExitCode -ne 0) { throw ('Interception uninstaller failed with exit code ' + $driverRun.ExitCode) }
        $after = Get-InterceptionResidueSnapshot
        Write-SetupLog ('Uninstall postcheck: ' + (Format-InterceptionResidueSnapshot $after))
        if ($after.KeyboardFilter -or $after.MouseFilter) {
            throw 'Interception is still registered in keyboard/mouse UpperFilters after the official uninstall. LLARS stopped without manually editing the Windows input stack.'
        }
        Write-SetupLog 'Official Interception uninstall verified. One Windows restart is required to finish unloading/deleting pending driver remnants.'
        # Keep the bundled runtime/installer in the LLARS folder. The files are inert
        # without the Windows filter driver until AHI is installed again.
        Set-Content -LiteralPath $uninstallPendingMarker -Value (Get-CurrentBootStamp) -Encoding ASCII
        Set-Content -LiteralPath $uninstalledMarker -Value 'Interception driver intentionally uninstalled; Windows restart required to finish unloading.' -Encoding ASCII
        Remove-Item -LiteralPath $setupResultFile -Force -ErrorAction SilentlyContinue
        exit 3010
    }

    Clear-UninstallFinalizeSchedule
    Remove-Item -LiteralPath $uninstallPendingMarker -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $uninstalledMarker -Force -ErrorAction SilentlyContinue

    # Use only the bundled, integrity-checked payload.
    Test-BundledPayload | Out-Null
    Unblock-BundledPayload
    Write-SetupLog 'Bundled AHI/Interception payload integrity verified and Windows downloaded-file blocks cleared; no network download is required.'

    if (Test-DriverRegistered) {
        Remove-Item -LiteralPath $errorLog -Force -ErrorAction SilentlyContinue
        Write-SetupResult 'READY'
        Write-SetupLog 'Interception is already registered. No driver reinstall or reboot is required by this run.'
        exit 0
    }

    $driverRun = Invoke-DriverInstaller $driverInstaller '/install'
    Write-SetupLog ('Interception /install output: ' + ($driverRun.Output -replace "`r?`n", ' | '))
    Write-SetupLog ('Interception /install exit code: ' + $driverRun.ExitCode)
    if ($driverRun.ExitCode -ne 0) { throw ('Interception installer failed with exit code ' + $driverRun.ExitCode) }
    if (-not (Test-DriverRegistered)) {
        throw 'Interception installer returned success, but Windows filter registration could not be verified.'
    }

    Set-Content -LiteralPath $pendingRestartMarker -Value (Get-CurrentBootStamp) -Encoding ASCII
    Write-SetupResult 'RESTART_REQUIRED'
    Remove-Item -LiteralPath $errorLog -Force -ErrorAction SilentlyContinue
    Write-SetupLog 'Successful bundled Interception install verified. Restart marker/result written for LLARS UI.'
    exit 3010
}
catch {
    $failureState = if ($_.Exception.Message -like 'BUNDLE:*') { 'BUNDLE_ERROR' } else { 'FAILED' }
    if (-not $Uninstall) {
        try { Write-SetupResult $failureState } catch { }
    }
    try { Write-SetupLog (($failureState + ': ') + $_.Exception.Message) } catch { }
    try {
        New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
        $details = @()
        $details += 'LLARS AutoHotInterception setup failed.'
        $details += ('Time: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
        $details += ('Message: ' + $_.Exception.Message)
        $details += ('Mode: ' + $(if ($Uninstall) { 'Uninstall' } else { 'Install' }))
        $details += ('PowerShell: ' + $PSVersionTable.PSVersion.ToString())
        $details += ('Windows: ' + [Environment]::OSVersion.VersionString)
        $details += ('Process 64-bit: ' + [Environment]::Is64BitProcess)
        $details += ('OS 64-bit: ' + [Environment]::Is64BitOperatingSystem)
        $details += ''
        $details += ($_ | Out-String)
        Set-Content -LiteralPath $errorLog -Value $details -Encoding UTF8
    } catch { }
    exit 1
}
finally {
    if ($setupLockHandle) { try { $setupLockHandle.Dispose() } catch { } }
    try { Remove-Item -LiteralPath $setupLockFile -Force -ErrorAction SilentlyContinue } catch { }
}
