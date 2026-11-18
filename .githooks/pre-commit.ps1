# ============================================================================
# .githooks/pre-commit.ps1
#
# Firewall otomatis sebelum commit: jalankan check_deadcode.ps1, dan BLOKIR
# commit kalau ditemukan dead code di kode sendiri (bukan di addons/.godot).
#
# Cara aktifkan (jalankan SEKALI saja per clone/mesin):
#   git config core.hooksPath .githooks
#
# Setelah itu, "git commit" otomatis menjalankan file ini duluan.
# Kalau mau skip sekali-sekali (misal WIP commit): git commit --no-verify
# ============================================================================

Write-Host "`n[pre-commit] Menjalankan dead code check sebelum commit..." -ForegroundColor Cyan

try {
    $output = & "./check_deadcode.ps1" 2>&1
    $output | ForEach-Object { Write-Host $_ }

    $foundIssue = $output -join "`n" | Select-String -Pattern "Ditemukan \d+ item dead code"

    if ($foundIssue) {
        Write-Host "`n[pre-commit] DIBLOKIR: masih ada dead code di kode kamu sendiri." -ForegroundColor Red
        Write-Host "[pre-commit] Beresin dulu, atau pakai 'git commit --no-verify' kalau sengaja (misal WIP)." -ForegroundColor Red
        exit 1
    }

    Write-Host "[pre-commit] Lolos, lanjut commit." -ForegroundColor Green
    exit 0
} catch {
    # Kalau gdshrapt/tool-nya sendiri error (bukan soal dead code), jangan blokir commit.
    # Ini supaya hook tidak jadi penghalang kalau tool-nya belum terpasang di mesin baru.
    Write-Host "[pre-commit] Peringatan: gagal jalankan check_deadcode.ps1 ($_). Commit tetap dilanjutkan." -ForegroundColor Yellow
    exit 0
}
