# ============================================================================
# .githooks/post-commit.ps1
#
# Setelah commit berhasil, otomatis jalankan sync_docs.ps1 supaya
# CURRENT_STATE.md langsung mencerminkan commit terbaru. Tidak memblokir
# apapun (commit sudah terjadi) - ini murni housekeeping otomatis.
# ============================================================================

Write-Host "`n[post-commit] Sinkronisasi dokumen otomatis..." -ForegroundColor Cyan

try {
    & "./sync_docs.ps1"
} catch {
    Write-Host "[post-commit] sync_docs.ps1 gagal jalan: $_" -ForegroundColor Yellow
    Write-Host "[post-commit] Tidak masalah, commit tetap tersimpan. Jalankan manual nanti kalau perlu." -ForegroundColor Yellow
}
