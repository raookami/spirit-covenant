# Script Otomatis untuk Update CURRENT_STATE.md
$roadmapPath = "docs/SPIRIT_COVENANT_ROADMAP.md"
$statePath = "docs/CURRENT_STATE.md"

Write-Host "Menganalisis Roadmap dan Git Log..." -ForegroundColor Cyan

# 1. Ambil 3 commit terakhir
$recentCommits = git log -3 --pretty=format:"- %s" 2>$null
if (-not $recentCommits) { $recentCommits = "- Belum ada commit terbaru." }

# 2. Cari 3 task berikutnya yang belum dicentang di Roadmap
$roadmap = Get-Content $roadmapPath
$pendingTasks = $roadmap | Where-Object { $_ -match "- \[ \]" } | Select-Object -First 3
if (-not $pendingTasks) { $pendingTasks = "- Semua task di roadmap mungkin sudah selesai!" }

# 3. Susun format Markdown-nya
$newState = @"
# CURRENT_STATE.md (Auto-Generated)
_Update terakhir: $(Get-Date -Format "dd MMM yyyy HH:mm")_

## 🕒 BARU SAJA DIKERJAKAN (Dari Git Log)
$recentCommits

## ⏭️ 3 TASKS BERIKUTNYA (Dari Roadmap)
$($pendingTasks -join "`n")

## ⚠️ CATATAN PENTING
- (Tambahkan catatan manual di sini jika ada *bug* atau hal yang butuh perhatian khusus)
"@

# 4. Tulis ke file CURRENT_STATE.md
$newState | Out-File -FilePath $statePath -Encoding utf8
Write-Host "SUKSES! docs/CURRENT_STATE.md berhasil diperbarui secara otomatis." -ForegroundColor Green