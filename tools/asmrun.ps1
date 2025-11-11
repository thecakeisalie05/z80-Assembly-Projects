param(
    [Parameter(Mandatory=$true)][string]$InputPath
)

function Write-Err { param([string]$m) Write-Host "ERROR: $m" -ForegroundColor Red }

if (-not (Test-Path $InputPath)) {
    Write-Err "Input file '$InputPath' not found."
    exit 2
}

$fullInput = (Resolve-Path $InputPath).Path
$inDir = Split-Path $fullInput -Parent
$base = [System.IO.Path]::GetFileNameWithoutExtension($fullInput)
$outHex = Join-Path $inDir ($base + ".hex")

# locate assemble.ps1 (expected next to this script)
$assembleScript = Join-Path $PSScriptRoot "assemble.ps1"
if (-not (Test-Path $assembleScript)) {
    Write-Err "assemble.ps1 not found in tools folder ($assembleScript)."
    exit 3
}

Write-Host "Running assemble.ps1 on $fullInput ..." -ForegroundColor Yellow
# Call assemble.ps1 (it will create the .hex next to the input file)
& "$assembleScript" -InputPath "$fullInput"
$rc = $LASTEXITCODE
if ($rc -ne 0) {
    Write-Err "assemble.ps1 failed with exit code $rc"
    exit $rc
}

if (-not (Test-Path $outHex)) {
    Write-Err "Expected output hex '$outHex' not found after assemble."
    exit 4
}

# find zemu.exe (prefer tools\zemu.exe, then PATH 'zemu')
$candidates = @()
$localZemu = Join-Path $PSScriptRoot "zemu.exe"
if (Test-Path $localZemu) { $candidates += $localZemu }
try {
    $cmd = Get-Command zemu -ErrorAction Stop
    if ($cmd) { $candidates += $cmd.Source }
} catch { }

$candidates = $candidates | Select-Object -Unique
if ($candidates.Count -eq 0) {
    Write-Err "zemu.exe not found. Put zemu.exe in the tools folder or on PATH."
    exit 5
}

$zemu = [string]($candidates | Select-Object -First 1)
$zemu = $zemu.Trim()
Write-Host "Launching zemu: '$zemu' with '$outHex' ..." -ForegroundColor Yellow

# Execute zemu with the hex file as the first argument
& "$zemu" "$outHex"
$zrc = $LASTEXITCODE
if ($zrc -ne 0) {
    Write-Err "zemu exited with code $zrc"
    exit $zrc
}

Write-Host "zemu finished (exit code 0)." -ForegroundColor Green
exit 0