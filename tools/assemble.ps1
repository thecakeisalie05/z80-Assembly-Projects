# ...existing code...
param(
    [Parameter(Mandatory=$true)][string]$InputPath
)

function Write-Err {
    param([string]$m)
    Write-Host "ERROR: $m" -ForegroundColor Red
}

if (-not (Test-Path $InputPath)) {
    Write-Err "Input file '$InputPath' not found."
    exit 2
}

$fullInput = (Resolve-Path $InputPath).Path
$inDir = Split-Path $fullInput -Parent
$base = [System.IO.Path]::GetFileNameWithoutExtension($fullInput)
$outBin = Join-Path $inDir ($base + ".bin")
$outHex = Join-Path $inDir ($base + ".hex")

Write-Host "Assembling: $fullInput -> $outHex (via pasmo temporary $outBin)" -ForegroundColor Yellow

# Find pasmo only (env, tools, or PATH)
$candidates = @()
if ($env:PASMO) { $candidates += $env:PASMO }

$scriptTools = Join-Path $PSScriptRoot "..\tools"
if (Test-Path (Join-Path $scriptTools "pasmo.exe")) { $candidates += (Join-Path $scriptTools "pasmo.exe") }

try {
    $cmd = Get-Command pasmo -ErrorAction Stop
    if ($cmd) { $candidates += $cmd.Source }
} catch { }

$candidates = $candidates | Select-Object -Unique

if ($candidates.Count -eq 0) {
    Write-Err "No pasmo found. Put pasmo.exe in 'tools' or add to PATH, or set PASMO environment variable."
    exit 3
}

$selected = ($candidates | Select-Object -First 1)
$exe = [string]$selected
$exe = $exe.Trim()

Write-Host "Using pasmo: '$exe' (type: $($exe.GetType().FullName))" -ForegroundColor Yellow

# Run pasmo -> produce binary (use --verboseshow and ensure include path is source folder)
$pasmoArgs = @("-v", "-I", $inDir, $fullInput, $outBin)
Write-Host "Running: $exe $($pasmoArgs -join ' ')" -ForegroundColor Yellow

Push-Location $inDir
try {
    & "$exe" @pasmoArgs
    $lc = $LASTEXITCODE
} finally {
    Pop-Location
}

if ($lc -ne 0) {
    Write-Err "pasmo returned exit code $lc"
    exit $lc
}

if (-not (Test-Path $outBin)) {
    Write-Err "pasmo succeeded but output binary '$outBin' not found."
    exit 4
}

# Parse ORG from source to determine start address (supports 0400h, 0x0400, or decimal)
function Parse-Number($s) {
    if ($s -match '^[0-9]+$') { return [int]$s }
    if ($s -match '^[0-9A-Fa-f]+[hH]$') {
        $hex = $s.Substring(0, $s.Length - 1)
        return [Convert]::ToInt32($hex,16)
    }
    if ($s -match '^0[xX][0-9A-Fa-f]+$') {
        return [Convert]::ToInt32($s.Substring(2),16)
    }
    throw "Unrecognized numeric format: $s"
}

$src = Get-Content -Raw -Path $fullInput
$origin = 0
if ($src -match '(?mi)^\s*ORG\s+([0-9A-Fa-fxX]+h?)') {
    try {
        $origin = Parse-Number($matches[1])
    } catch {
        Write-Host "WARN: couldn't parse ORG value '$($matches[1])', defaulting origin 0" -ForegroundColor Red
        $origin = 0
    }
} else {
    Write-Host "No ORG found; defaulting origin = 0" -ForegroundColor Red
}

Write-Host ("Converting binary {0} bytes to Intel HEX starting at {1:X4}h" -f ((Get-Item $outBin).Length), $origin) -ForegroundColor Yellow

# Read binary and generate Intel HEX
$bytes = [System.IO.File]::ReadAllBytes($outBin)
$outLines = New-Object System.Collections.Generic.List[string]

$addr = $origin -band 0xFFFF
$offset = 0
$max = $bytes.Length

# If origin > 0xFFFF, we should emit extended linear address records. This simple converter assumes 16-bit addressing.
# For most Z80 targets within 64K this is fine. If you need >64K support, let me know.
$recordSize = 16
while ($offset -lt $max) {
    $count = [Math]::Min($recordSize, $max - $offset)
    $hi = ($addr -shr 8) -band 0xFF
    $lo = $addr -band 0xFF
    $sum = $count + $hi + $lo + 0 # record type 00
    $dataBytes = $bytes[$offset..($offset + $count - 1)]
    $dataHex = ""
    foreach ($b in $dataBytes) { $sum += $b; $dataHex += $b.ToString("X2") }
    $checksum = ((- $sum) -shr 0) -band 0xFF
    $line = ":" + ($count.ToString("X2")) + ($hi.ToString("X2")) + ($lo.ToString("X2")) + "00" + $dataHex + ($checksum.ToString("X2"))
    $outLines.Add($line)
    $addr = ($addr + $count) -band 0xFFFF
    $offset += $count
}

# End Of File record
$outLines.Add(":00000001FF")

# Write hex file (ASCII)
$outLines | Out-File -FilePath $outHex -Encoding ASCII -Force

Write-Host "Success: wrote Intel HEX to $outHex" -ForegroundColor Green
exit 0
// ...existing code...