$env:DOTNET_ROLL_FORWARD = 'LatestMajor'

$tempFile = Join-Path $env:TEMP "gdshrapt_raw_output.txt"
gdshrapt dead-code . *> $tempFile
$rawLines = Get-Content $tempFile

# Bersihkan kode warna ANSI (contoh: ESC[0m, ESC[31m, dst) dari tiap baris.
# gdshrapt menyisipkan kode warna untuk tampilan terminal, yang mengganggu regex end-of-line.
$ansiPattern = [char]27 + '\[[0-9;]*[a-zA-Z]'
$lines = $rawLines | ForEach-Object { $_ -replace $ansiPattern, '' }

$resultLines = @()
$skipBlock = $false

foreach ($line in $lines) {
    $trimmed = $line.Trim()
    $isHeader = $trimmed -match '\.gd:$'

    if ($isHeader) {
        if ($trimmed -match 'addons[\\/]' -or $trimmed -match '\.godot[\\/]') {
            $skipBlock = $true
            continue
        }
        else {
            $skipBlock = $false
        }
    }
    elseif ($trimmed -eq '') {
        $skipBlock = $false
    }

    if ($skipBlock) {
        continue
    }

    $resultLines += $line
}

$remaining = ($resultLines | Where-Object { $_ -match '\[(FNC|VNR|SNE|CNU)\]' }).Count

Write-Host ""
Write-Host "================================================"
Write-Host " HASIL DEAD CODE CHECK - KODE SENDIRI"
Write-Host "================================================"
Write-Host ""

if ($remaining -eq 0) {
    Write-Host "BERSIH. 0 dead code ditemukan di kode kamu sendiri." -ForegroundColor Green
}
else {
    Write-Host "Ditemukan $remaining item dead code di kode kamu sendiri:" -ForegroundColor Yellow
    Write-Host ""
    $resultLines | ForEach-Object { Write-Host $_ }
}

Write-Host ""
Write-Host "================================================"

Remove-Item $tempFile -ErrorAction SilentlyContinue