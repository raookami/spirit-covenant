$env:DOTNET_ROLL_FORWARD = 'LatestMajor'
$tempFile = Join-Path $env:TEMP "gdshrapt_raw_output.txt"
gdshrapt dead-code . *> $tempFile

Write-Host "=== Info file ==="
Get-Item $tempFile | Select-Object Length, Name

Write-Host ""
Write-Host "=== Baca dengan Get-Content biasa (tanpa -Encoding), ambil baris yang mengandung '.gd:' ==="
$lines1 = Get-Content $tempFile
$matched1 = $lines1 | Where-Object { $_ -match '\.gd:$' }
Write-Host "Jumlah match: $($matched1.Count)"
$matched1 | Select-Object -First 3

Write-Host ""
Write-Host "=== Baca dengan -Raw lalu split manual ==="
$raw = Get-Content $tempFile -Raw
Write-Host "Panjang raw: $($raw.Length)"
$lines2 = $raw -split "`r`n"
Write-Host "Jumlah baris hasil split CRLF: $($lines2.Count)"
$matched2 = $lines2 | Where-Object { $_ -match '\.gd:$' }
Write-Host "Jumlah match (CRLF split): $($matched2.Count)"
$matched2 | Select-Object -First 3

Write-Host ""
Write-Host "=== Contoh baris mentah index 20-25 dari Get-Content biasa, tampilkan sebagai -join ',' char codes ==="
for ($i = 20; $i -lt 26; $i++) {
    if ($i -lt $lines1.Count) {
        Write-Host "Line $i : [$($lines1[$i])]"
    }
}