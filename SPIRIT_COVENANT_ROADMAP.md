# SPIRIT COVENANT — Solo Dev Roadmap

> Berdasarkan Blueprint v1.4 · Dibuat Juli 2026 · Update 20 Juli 2026 (migrasi ke Godot)
> Engine: Godot 4.7 (GDScript) · Art: CSP + Live2D Cubism 5.0 (via GDCubism)

---

## Status Sekarang (Sudah Ada)

Sistem yang sudah diimplementasi di Godot (`battle.gd`, `enemy.gd`, `spirit.gd`):

- ✅ Grid map (TileMap) + battle scene dasar
- ✅ Deploy system (spirit roster + card di panel bawah)
- ✅ Enemy waypoint pathfinding
- ✅ Block mechanic melee (grab + hold musuh di radius) dan ranged (cari target terdekat)
- ✅ Crystal HP / DP system
- ✅ Attack, projectile, dan damage flash dasar

Sistem Live2D (baru selesai 20 Juli 2026):

- ✅ **GDCubism ter-compile dari source** dan aktif di project (bukan plugin siap-pakai — dibangun manual lewat SCons + MSVC Build Tools + Cubism SDK for Native R4_1)
- ✅ Model Live2D Raookami (`raookami_idle`) render di battle scene, ukuran & posisi sudah disesuaikan ke tile
- ✅ Idle motion loop mulus (`start_motion_loop()`, bukan `start_motion()` biasa)
- ✅ `spirit.gd` sudah punya fallback otomatis: kalau spirit punya file `.model3.json`, pakai Live2D; kalau tidak, tetap pakai sistem PNG/placeholder lama — jadi 4 Spirit lain tidak perlu Live2D dulu buat tetap bisa dimainkan

Artinya: **fondasi gameplay loop sudah ada, dan Live2D sudah masuk lebih awal dari rencana** (blueprint aslinya menaruh integrasi Live2D di Fase 2, tapi Raookami sudah jalan duluan di titik ini). **Fase 0 sudah selesai penuh per 22 Juli 2026** — termasuk StageConfig (data stage dipisah dari hardcode `battle.gd` ke `data/stage_01.tres`), version control (Git + GitHub, repo private), dan crash reporting (Sentry, sudah terverifikasi event masuk ke dashboard). Kamu sekarang siap masuk Fase 1.

---

## Catatan Migrasi Engine (Unity → Godot)

Project sempat direncanakan pakai Unity (lihat blueprint v1.3), lalu balik lagi ke Godot pada 20 Juli 2026. Alasan utamanya: asset Live2D yang sudah dibuat (`.moc3`, `.model3.json`, `.motion3.json`, dll) portable lintas engine, jadi tidak ada yang hilang dari keputusan ini — hanya butuh setup toolchain compile GDCubism satu kali (sudah selesai). Kalau butuh setup ulang di mesin lain, langkah singkatnya:

1. Install Visual Studio Build Tools (workload "Desktop development with C++")
2. Install Python + `pip install scons==4.10.1` (versi lama sempat gagal deteksi MSVC 2026)
3. `git clone` GDCubism + `git submodule update --init`
4. Download Cubism SDK for Native **R4_1** (bukan versi terbaru — versi terbaru belum sediakan `.lib` untuk toolset MSVC terbaru)
5. `scons platform=windows arch=x86_64 target=template_debug` (dan `template_release`)
6. Copy folder `addons/gd_cubism` hasil build ke project

---

## Prinsip Roadmap Ini

1. **Playable dulu, polish belakangan** — setiap milestone harus menghasilkan sesuatu yang bisa dimainkan
2. **Art & code paralel** — Live2D tidak harus selesai sebelum gameplay bisa ditest
3. **Scope freeze per fase** — tidak tambah fitur baru sebelum fase selesai
4. **Solo dev buffer** — semua estimasi dikali 1.5x dari perkiraan normal

---

## FASE 0 — Stabilisasi (1–2 minggu)

> Beresin fondasi yang ada sebelum lanjut

Tujuan: pastikan semua sistem yang sudah ada tidak ada bug critical, dan project structure rapi.

### Checklist

- [x] Review semua script yang ada — pastikan tidak ada null reference tersembunyi (cek `is_instance_valid()` di semua tempat yang pegang referensi node lain) — audit selesai, pola `is_instance_valid()` sudah konsisten dipakai di semua referensi silang spirit↔enemy↔battle
- [x] Tambah null check di wave/enemy spawning (terutama saat wave kosong / enemies array) — sekaligus perbaiki race condition di `_spawn_enemy()`: `setup(ENEMY_PATH)` sekarang dipanggil **sebelum** `add_child()`, karena `_ready()` jalan langsung saat `add_child()` dan sebelumnya `path` masih kosong di titik itu (sempat "kebetulan jalan" lewat flag `_initialized`, sekarang rapi)
- [x] Pastikan block mechanic di `spirit.gd` tidak crash kalau Spirit di-undeploy saat sedang blocking musuh — `_try_retreat()` di `battle.gd` sekarang panggil `enemy.clear_blocked()` ke semua musuh yang sedang di-block spirit tsb sebelum `queue_free()`, jadi musuh langsung lanjut jalan tanpa delay 1 frame kosong
- [x] Setup Git / version control kalau belum ada — repo `raookami/spirit-covenant` sudah di-init, `.gitignore` sudah exclude `.godot/`, `.import`, build artifact GDCubism, dan sudah di-push ke GitHub (private repo)
- [x] Buat Resource (`.tres`) atau JSON untuk `StageConfig` — pisahkan data stage dari hardcode — dibuat sebagai custom Resource class (`stage_config.gd` + `data/stage_01.tres`), `battle.gd` sekarang load config di `_ready()` lewat `_load_stage_config()`, dengan fallback ke nilai default lama kalau file config gagal ditemukan (tidak silent-break)
- [x] Simple test scene: Spirit (Raoo) + jalur enemy + Crystal HP — sudah jalan di `battle.tscn`, tinggal pastikan kondisi menang/kalah lengkap — **kondisi Victory sudah terverifikasi jalan** (battle test 22 Juli 2026 berhasil sampai layar VICTORY)
- [x] GDCubism toolchain siap dipakai kapan saja untuk karakter berikutnya (sudah tidak perlu setup ulang compiler dari nol)
- [x] Cek performa Live2D Raookami pakai Godot Profiler (Debugger > Profiler) — catat FPS/render time baseline sekarang, sebelum nambah karakter Live2D lain — **hasil (22 Juli 2026): Frame Time ~16.44ms rata-rata ≈ 60 FPS stabil, dengan 1 model Live2D Raookami aktif render selama battle penuh sampai Victory.** Grafik frame time relatif stabil, ada beberapa spike wajar (kemungkinan saat spawn enemy). **Belum dites:** multi-Spirit Live2D render bersamaan, dan device Android low-end/mid-range asli (baru dites di PC dev) — perlu diulang begitu karakter Live2D ke-2 masuk
- [x] Setup Sentry (atau tool sejenis, ada free tier) buat auto-capture crash report dari build yang dibagikan ke orang lain — supaya nggak cuma mengandalkan pemain sukarela lapor bug manual — **selesai (22 Juli 2026):** SDK resmi `sentry-godot` v2.1.0 terpasang, DSN terkonfigurasi, event test "Hello, World!" berhasil masuk ke dashboard (project `spirit-covenant` di sentry.io)

### Live Ops & Komunitas (Bisa Mulai Paralel, Tidak Terikat Fase Manapun)

- [ ] Buat Discord server khusus Spirit Covenant (bukan server personal gabungan project) — mulai dari sekarang, tidak perlu menunggu mendekati rilis
- [ ] Struktur channel minimal: `#devlog`, `#general`, `#bug-report`, `#feedback-ideas` — jangan kebanyakan channel kosong di awal
- [ ] Mulai posting devlog rutin (progress kecil, 1-2 post/minggu) — momentum yang sudah ada (GDCubism compile berhasil, Raookami Live2D jalan) worth dishare, jangan tunggu sampai "ada yang besar" buat diposting
- [ ] Komunikasikan transparan bahwa ini solo dev project — membantu ekspektasi pemain soal kecepatan patch/response jadi lebih realistis

### Output Fase 0

Satu scene yang bisa dimainkan end-to-end: tempatkan Spirit → musuh datang → Crystal bisa hancur atau survive. **✅ Fase 0 selesai penuh (22 Juli 2026)** — semua item checklist tuntas, termasuk kerapian kode (race condition spawn enemy, retreat/block cleanup), tooling (Git+GitHub, Sentry), dan validasi performa baseline (60 FPS stabil dengan 1 model Live2D).

---

## FASE 1 — Playable Prototype (3–4 minggu)

> Game bisa dimainkan, belum harus bagus

Tujuan: semua 5 Spirit bisa deploy, 3 stage berbeda, kondisi menang/kalah jelas.

### Minggu 1–2: Spirit System

- [x] Base struktur Spirit ada di `spirit.gd` (HP musuh, ATK, range, attack_cd, block_count) — jalan lewat `init()` dengan data dari roster, bukan lewat class terpisah per Spirit
- [ ] Implement 5 Spirit dengan stat dari blueprint (Raoo sudah punya visual Live2D; Kuma/Yoshiki/Ratora/Koyuuki masih placeholder/PNG — itu sudah oke sesuai desain fallback)
  - Raookami: Frontliner, melee, block tinggi — **stat & visual sudah ada**
  - Kuma: Defender, melee range luas, HP tertinggi
  - Yoshiki: Ranged, ATK tertinggi, HP rendah
  - Ratora: DPS, melee AoE kecil, SPD tinggi
  - Koyuuki: Support/Debuffer, slow musuh
- [x] Deploy cost system (Crystal/DP bar terlihat di UI battle scene)
- [ ] Retreat mechanic (tarik Spirit dari tile, cooldown sebelum bisa deploy lagi)

### Minggu 3: Stage & Enemy

- [ ] 3 enemy type pertama: Grunt, Brute, Sprinter (saat ini `enemy.gd` masih generic — perlu differensiasi stat/behavior per tipe)
- [ ] Object pooling untuk enemy, projectile, dan damage number popup — reuse object alih-alih instantiate/destroy terus-menerus tiap battle. Lebih murah dikerjakan sekarang (bareng pembuatan enemy system) daripada refactor belakangan setelah banyak sistem lain menempel
- [ ] 3 stage layout berbeda (jalur sederhana, jalur cabang, jalur sempit)
- [x] Crystal HP visible di UI — sudah ada bar + angka DP
- [ ] Wave UI: "Wave 1/5" counter

### Minggu 4: Game Feel

- [ ] Basic SFX: serangan, enemy mati, crystal kena damage
- [ ] Screen shake ringan saat crystal kena hit
- [ ] Angka damage muncul saat hit (damage number popup)
- [ ] Pause menu sederhana
- [ ] Onboarding Stage 1: guided/dibatasi — batasi akses ke 1 Spirit dulu (misal Raookami), auto-highlight tile deploy yang baik, desain stage 1 supaya nyaris mustahil kalah (memaafkan kesalahan pemain baru). Mekanik lain (skill selection, Covenant Link, dst) diperkenalkan bertahap di stage-stage berikutnya, bukan sekaligus di awal — selaras dengan prinsip "tutorial implisit" yang sudah ada di Blueprint bagian Enemy Design
- [ ] Opsi skip tutorial buat pemain yang sudah familiar (replay/reinstall)

### Output Fase 1

Demo yang bisa dikasih ke orang lain untuk dicoba. Tidak perlu cantik.

### Analytics (Mulai Akhir Fase 1 / Awal Fase 2)

- [ ] Integrasi GameAnalytics (gratis untuk indie, ada plugin Godot, dashboard retention/funnel sudah jadi tanpa perlu setup manual)
- [ ] Track event dasar: level_start, level_complete, level_fail — untuk lihat di stage mana pemain paling banyak drop-off
- [ ] Ditunda sampai ada beberapa stage yang bisa dimainkan berulang (Fase 0 belum representatif untuk funnel data)
- [ ] Metrik prioritas untuk dipantau setelah rilis: retention D1/D7/D30, stage drop-off, rata-rata hari mencapai hard pity pertama

---

## FASE 2 — Skill System (2–3 minggu)

> Tambah depth gameplay — pilih skill sebelum battle

Tujuan: implementasi mechanic "pilih 1 dari 3 skill" yang jadi core identity game.

### Skill Architecture

- [ ] `SkillData` sebagai Resource (`.tres`) atau Dictionary: nama, deskripsi, tipe (active/passive), parameter
- [ ] `SkillSelector` UI — muncul sebelum battle, pilih 1 dari 3 untuk tiap Spirit yang dibawa
- [ ] `SkillExecutor` component yang attach ke tiap Spirit

### Skill per Spirit (implement satu per satu, test tiap skill)

- [ ] Raookami: Shadow Dash + Dark Howl + Pack Instinct (passive)
- [ ] Kuma: Memory Seal + Foresight Barrier + Glacier Wall (passive)
- [ ] Yoshiki: Camouflage + Tidal Strike + Frost Current (passive)
- [ ] Ratora: Thunder Crash + Blaze Rush + Berserker Soul (passive)
- [ ] Koyuuki: Dream Veil + Hypnotic Song + Ethereal Form (passive)

### Covenant Link (Raku skill)

- [ ] Satu tombol yang bisa di-tap saat battle
- [ ] Boost Spirit yang dipilih 50% ATK selama 10 detik
- [ ] Cooldown panjang (60 detik)
- [ ] Visual feedback: aura di Spirit yang di-boost

### Output Fase 2

Battle terasa strategic — pemain mulai mikir komposisi dan timing skill.

---

## FASE 3 — Live2D Integration (Paralel dengan Fase 2–4)

> Art pipeline: CSP → Live2D → Godot (via GDCubism)

⚠️ Fase ini paralel — tidak perlu selesai sebelum lanjut gameplay. Tiap karakter bisa diintegrasikan satu-satu saat siap.

✅ **Toolchain sudah beres** — GDCubism ter-compile dan siap dipakai kapan saja, tidak perlu setup ulang compiler untuk karakter berikutnya (lihat catatan migrasi di atas kalau ganti mesin dev).

### Per Karakter (ulangi untuk 4 sisanya — Raookami sudah selesai idle):

- [ ] Layer separation selesai di CSP (zone-based, bukan per-strand)
- [ ] Import ke Live2D Cubism 5.0
- [ ] Rigging dasar: kepala, mata, mulut, badan, tangan
- [ ] Animasi Idle (loop)
- [ ] Animasi Attack (trigger saat spirit menyerang, panggil dari `spirit.gd` `_attack_enemy()`)
- [ ] Animasi Hurt (trigger saat kena damage)
- [ ] Export .moc3 + .model3.json + textures — **cek manual bahwa blok `"Motions"` di `model3.json` benar-benar ada dan menunjuk ke file `.motion3.json` yang benar.** Kejadian di Raookami: motion sempat tidak terbaca sama sekali karena blok ini hilang saat export dari Cubism Editor, meskipun file motion-nya sendiri lengkap.
- [x] Sistem import ke Godot via GDCubism sudah terbukti jalan (pola: taruh folder di `assets/spirites/characters/<id>/`, `spirit.gd` otomatis mendeteksi `.model3.json` dan fallback ke PNG kalau belum ada)
- [x] Pola pemanggilan motion di GDScript sudah ada — pakai `start_motion_loop(group, index, priority, true, true)` untuk animasi loop (idle), `start_motion()` biasa untuk animasi sekali jalan (attack, hit)

### Raookami — status detail (referensi untuk 4 karakter berikutnya)

- [x] Model + idle motion jalan di battle scene, loop mulus
- [ ] Animasi Attack
- [ ] Animasi Hurt
- [ ] Skala & posisi final (sudah ada baseline: `scale = Vector2(0.1, 0.1)`, `position = Vector2(0, -20)` — base ini kemungkinan mirip untuk karakter lain kalau ukuran canvas Cubism-nya konsisten)

### Prioritas urutan karakter:

1. Raookami (mascot, paling sering muncul di screenshot/promo) — **idle selesai**
2. Kuma (Defender, sering ada di early tutorial)
3. Yoshiki, Ratora, Koyuuki (bebas urutan)

### Output Fase 3

Minimal 1 karakter (Raookami) sudah full Live2D in-game. Sisanya menyusul.

---

## FASE 4 — Content Build (4–6 minggu)

> Isi game dengan konten yang cukup untuk first release

Tujuan: **Chapter 1 (10 stage)**, 2 boss (Stage 5 & 10), progression system basic.

> Struktur chapter: Chapter 1 = 10 stage adalah unit rilis pertama yang lengkap (bukan porsi dari 15 stage yang disebut di Blueprint Fase 3 — itu direvisi jadi per-chapter). Chapter 2+ menyusul di update berikutnya setelah Chapter 1 stabil & dapat feedback pemain — selaras dengan prinsip solo dev "playable dulu, polish belakangan".

### Stage Content (Chapter 1)

- [ ] 10 stage dengan layout dan kombinasi enemy berbeda
- [ ] Stage 1–5: tutorial implisit, satu tipe enemy dominan
- [ ] Stage 6–10: dua tipe kombinasi, mulai butuh strategi
- [ ] Setiap stage punya "momen aha" yang didesain (choke point, timing skill, komposisi unik)
- [ ] 3-star rating system (selesai tanpa Spirit mati, Crystal HP >50%, dll)

### Boss (Stage 5 dan 10)

- [ ] Boss punya 2 fase (HP threshold trigger fase 2)
- [ ] Boss menggunakan kombinasi mechanic enemy biasa
- [ ] Special attack yang butuh respon dari pemain

### Progression System

- [ ] Spirit Level 1–20 (EXP dari battle)
- [ ] Stat naik per level (linear, tidak ada power creep)
- [ ] In-game currency (Covenant Shards) dari battle reward
- [ ] Bond system level 1–5 per Spirit: unlock dialog + ilustrasi

### Basic Story

- [ ] Dialog sederhana sebelum tiap stage (Raku + Spirit, max 5 baris)
- [ ] Tidak perlu voice — text + portrait oke
- [ ] Unlock lore fragment setelah selesai stage

### Output Fase 4

Versi yang layak untuk soft release ke teman/komunitas kecil.

---

## FASE 5 — Roguelite Mode: Covenant Run (3–4 minggu)

> Konten replayable tanpa stamina

Tujuan: implementasi mode yang bikin pemain balik lagi tiap hari tanpa ngerasa "wajib".

### Struktur Run

- [ ] Pilih 3 Spirit dari roster
- [ ] 5 stage acak dari pool yang tersedia
- [ ] Setelah tiap stage: pilih 1 dari 3 "Covenant Blessing" (buff temporer selama run)
- [ ] Run selesai = reward Covenant Shards + chance unlock art fragment
- [ ] Run gagal = tetap dapat reward kecil (tidak ada punishment)

### Covenant Blessings (contoh)

- Semua Spirit +15% ATK run ini
- Cost regeneration 2x lebih cepat
- Crystal HP +20% run ini
- Koyuuki skill cooldown -30% run ini

### Output Fase 5

Pemain bisa main tiap hari tanpa ngerasa gated.

---

## FASE 6 — Android Port & Release (2–3 minggu)

> Windows selesai dulu baru Android

- [ ] Godot Export Templates untuk Android (install lewat Editor Settings / Export)
- [ ] UI responsive: Control node dengan anchor/container untuk berbagai resolusi layar
- [ ] Touch input: tap to deploy, swipe untuk lihat Spirit stats
- [ ] Performance check: target 60fps di mid-range Android (cek beban render GDCubism di HP low-end — model Live2D lebih berat dari sprite biasa)
- [ ] Testing di minimal 2 device berbeda
- [ ] Soft release: itch.io (Windows) + Google Play beta

---

## Timeline Ringkas

```
Sekarang
  │
  ├── Fase 0: Stabilisasi        1–2 minggu
  ├── Fase 1: Playable Prototype  3–4 minggu
  ├── Fase 2: Skill System        2–3 minggu  ─┐
  ├── Fase 3: Live2D (paralel)    ongoing     ─┘ jalan bersamaan
  ├── Fase 4: Content Build       4–6 minggu
  ├── Fase 5: Covenant Run        3–4 minggu
  └── Fase 6: Android + Release   2–3 minggu
                                  ──────────
              Total estimasi:    ~4–5 bulan
              (dengan buffer solo dev 1.5x)
```

---

## Scope Freeze Rules

Ini penting untuk solo dev — kalau tidak ada aturan ini, game tidak akan pernah selesai:

**Tidak boleh ditambah sebelum Fase 4 selesai:**

- Alter karakter (ada di Fase pasca-release)
- Gacha system lengkap
- Season event
- Fitur multiplayer / leaderboard apapun
- Daily quest system

**Boleh dikerjain paralel kapan saja:**

- Art / Live2D (tidak block gameplay)
- BGM / SFX
- Blueprint update

---

## Kalau Stuck / Burnout

Ini normal untuk solo dev. Beberapa strategi:

- **Switch ke art mode** — kalau coding mandek, gambar karakter dulu. Progress tetap ada.
- **Mini milestone** — kalau Fase terasa besar, pecah jadi target 1 hari: "hari ini: Raookami bisa deal damage"
- **Show early** — kasih lihat ke orang lain seawal mungkin. Feedback bikin semangat balik.
- **Vibe Coder** — selesaiin dulu, biar coding Spirit Covenant lebih cepat dengan AI assist.

---

_Roadmap ini hidup — update seiring progress._
_Dibuat berdasarkan Spirit Covenant Blueprint v1.4 + progress Godot yang sudah ada (termasuk GDCubism + Raookami Live2D, selesai 20 Juli 2026)._
