# Script Otomatis: Baca Git Log + Baca Kanban Godot
$kanbanPath = "kanban_tasks_data.kanban"
$statePath = "docs/CURRENT_STATE.md"

Write-Host "Menganalisis Git Log dan Kanban Board..." -ForegroundColor Cyan

# 1. Ambil 3 commit terakhir
$recentCommits = git log -3 --pretty=format:"- %s" 2>$null
if (-not $recentCommits) { $recentCommits = "- Belum ada commit terbaru." }

# 2. Baca file Kanban dengan Loop yang Aman
$pendingTasks = @()
if (Test-Path $kanbanPath) {
    try {
        $kanbanData = Get-Content $kanbanPath -Raw | ConvertFrom-Json
        
        $tasksList = @()
        foreach ($stage in $kanbanData.stages) {
            # Cari kartu di kolom Doing, kalau kosong cari di Todo
            if ($stage.title -eq "Doing" -or $stage.title -eq "Todo") {
                foreach ($taskUuid in $stage.tasks) {
                    $taskObj = $kanbanData.tasks | Where-Object { $_.uuid -eq $taskUuid }
                    if ($taskObj) {
                        # Bersihkan spasi di awal judul
                        $cleanTitle = $taskObj.title.Trim()
                        $tasksList += "- [ ] $cleanTitle"
                    }
                }
            }
        }
        
        if ($tasksList.Count -gt 0) {
            $pendingTasks = $tasksList | Select-Object -First 3
        } else {
            $pendingTasks = @("- Semua kartu Done! Waktunya bikin stage baru.")
        }
    } catch {
        $pendingTasks = @("- Gagal membaca JSON Kanban. Cek format file.")
    }
} else {
    $pendingTasks = @("- File kanban_tasks_data.kanban tidak ditemukan.")
}

# 3. Susun Markdown (Tanpa Emoji biar tidak jadi Alien)
$newState = @"
# CURRENT_STATE.md (Auto-Generated)
_Update terakhir: $(Get-Date -Format "dd MMM yyyy HH:mm")_

## [LOG] BARU SAJA DIKERJAKAN (Dari Git Log)
$recentCommits

## [NEXT] 3 TASKS BERIKUTNYA (Dari Kanban Godot)
$($pendingTasks -join "`n")

## [INFO] CATATAN PENTING
- (Tambahkan catatan manual di sini jika ada bug atau hal yang butuh perhatian khusus)
"@

# 4. Tulis ke file (Paksa pakai UTF-8 tanpa BOM)
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText((Resolve-Path $statePath), $newState, $Utf8NoBomEncoding)

Write-Host "SUKSES! Sinkronisasi Kanban -> CURRENT_STATE berhasil." -ForegroundColor Green