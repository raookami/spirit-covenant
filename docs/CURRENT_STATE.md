# CURRENT_STATE.md — 13 Nov 2026

## 📍 POSISI SEKARANG

Fase 1 Minggu 2 selesai. Berhenti di awal Minggu 3 (enemy type differentiation).

## ✅ SUDAH JALAN (terverifikasi dari kode)

- StageConfig .tres + fallback
- Grid render + tile highlight drag
- Deploy via drag + direction picker 4 panah (DP dipotong setelah konfirmasi arah)
- Retreat manual (klik kanan) + kematian battle → cooldown 8 detik sama
- Block melee radius 0.6 tile + ranged targeting
- Attack pattern grid-based 4 arah per Spirit (bukan rotasi matematis)
- Live2D Raookami idle loop via start_motion_loop() + fallback PNG
- Victory/Defeat banner
- DP regen + card availability tint + cooldown label
- stage_01.tres lengkap & valid (5x10 grid, 15 waypoint, semua di PATH)

## 🔄 SEDANG DIKERJAKAN

(tidak ada — berhenti di akhir Minggu 2)

## ⏭️ 3 TASKS BERIKUTNYA (Fase 1 Minggu 3)

1. Enemy type differentiation: Grunt, Brute, Sprinter
2. Wave system + Wave UI counter "Wave 1/5"
3. Object pooling untuk enemy + projectile + damage popup

## ⚠️ CATATAN PENTING

- enemy.gd: TESTING_TANKY_ENEMY sudah dimatikan, hp=60 block_atk=3 (13 Nov 2026)
- battle.gd: get_blocking_enemies() = DEAD CODE, tidak dipanggil siapa pun
- \_load_stage_config(): fallback handle "gagal load", belum handle "load tapi map_layout kosong"
- spirit.gd take_damage(): masih rata-rata phys_def/magic_def (temporary, Fase 2+)
- spirit.gd: skill energy bar masih placeholder kosong (Fase 2)
- Crystal of Covenant: belum ada visual di battle scene (hanya angka di HUD)
- sentry_test.gd: file test, boleh pindah ke /tests/ nanti

## 📝 BLUEPRINT SYNC

- Sync terakhir: Juli 2026
- Sync berikutnya: akhir Fase 1
- Item v1.5: lihat DECISIONS.md section 6

## 🔧 COMMAND CEPAT

- Lint: gdlint .
- Cek syntax: godot --headless --check-only --script scenes/spirit.gd
- Git log: git log --oneline -10

_Update terakhir: 13 Nov 2026 — setelah enemy.gd balance fix_
