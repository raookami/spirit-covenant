$env:DOTNET_ROLL_FORWARD = 'LatestMajor'
$tempFile = Join-Path $env:TEMP "gdshrapt_raw_output.txt"
gdshrapt dead-code . *> $tempFile

$lines = Get-Content $tempFile
$target = $lines[24]

Write-Host "Baris: [$target]"
Write-Host "Panjang: $($target.Length)"
Write-Host "Kode karakter tiap huruf (10 terakhir):"
$chars = $target.ToCharArray()
$start = [Math]::Max(0, $chars.Length - 10)
for ($i = $start; $i -lt $chars.Length; $i++) {
    Write-Host "  [$i] '$($chars[$i])' = $([int]$chars[$i])"
}