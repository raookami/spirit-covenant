$testLine = "addons\kanban_tasks\data\board.gd:"
Write-Host "Panjang string: $($testLine.Length)"
Write-Host "Karakter terakhir (code): $([int][char]$testLine[-1])"
Write-Host "Match hasil: $($testLine -match '\.gd:$')"