# SPIRIT COVENANT — Solo Dev Roadmap

> Berdasarkan Blueprint v2.0 · Dibuat Juli 2026 · Update 18 Nov 2026 (sinkronisasi GDD v2.0 & audit kode)
> Engine: Godot 4.7 (GDScript) · Art: CSP + Modular Chibi (`Skeleton2D` Godot) + Live2D Cubism 5.0 (GDCubism untuk maskot/skin spesial)

> ℹ️ **Cara baca file ini:** Setiap item checklist punya tag `<!--id:xxx-->` di akhir baris. Tag ini dipakai `sync_docs.ps1` untuk mencocokkan task Kanban yang sudah Done dan mencentang baris yang sesuai secara otomatis. **Jangan hapus tag ini** walau kelihatan aneh — itu bukan komentar biasa, itu kunci sinkronisasi. Histori detail teknis (tanggal, angka FPS, cara compile, dll) ada di Git log dan commit message, bukan di sini — roadmap ini sengaja dijaga ringkas di level fase.

---

## Status Sekarang (Ringkas)

Fondasi gameplay loop sudah ada dan jalan: grid map, deploy system, enemy pathfinding, block mechanic (melee+ranged), Crystal HP/CP (saat ini di HUD masih tertulis `DP`), attack & projectile dasar. GDCubism (plugin Live2D unofficial) sudah berhasil di-compile dan terintegrasi — Raookami chibi sudah render dengan Live2D idle motion di battle scene. **Fase 0 dan sebagian besar Fase 1 sudah selesai.** Lihat `CURRENT_STATE.md` untuk snapshot ter-update otomatis.

### Catatan Migrasi Engine (Unity → Godot)

Project sempat direncanakan pakai Unity, lalu pindah ke Godot (20 Juli 2026) karena asset Live2D portable lintas engine — tidak ada yang hilang dari keputusan ini. Kalau perlu setup ulang toolchain GDCubism di mesin lain, langkah ringkasnya: install MSVC Build Tools (C++ workload) → `pip install scons==4.10.1` → clone GDCubism + submodule → download Cubism SDK for Native **R4_1** (bukan versi terbaru, versi terbaru belum sediakan lib untuk MSVC terbaru) → `scons platform=windows arch=x86_64 target=template_debug` (+ `template_release`) → copy `addons/gd_cubism` ke project.

---

## Prinsip Roadmap Ini

1. **Playable dulu, polish belakangan** — setiap milestone harus menghasilkan sesuatu yang bisa dimainkan
2. **Art & code paralel** — aset modular tidak harus selesai semua sebelum gameplay bisa ditest
3. **Scope freeze per fase** — tidak tambah fitur baru sebelum fase selesai
4. **Solo dev buffer** — semua estimasi dikali 1.5x dari perkiraan normal
5. **Roadmap ini level fase, bukan level teknis** — detail implementasi hidup di task Kanban, bukan di sini

---

## FASE 0 — Stabilisasi (1–2 minggu) ✅ SELESAI (22 Juli 2026)

> Beresin fondasi yang ada sebelum lanjut

- [x] Audit script untuk null reference & race condition tersembunyi <!--id:fase0.audit_null--> *(pola `is_instance_valid()` konsisten dipakai; race condition `_spawn_enemy()` sudah diperbaiki)*
- [x] Block mechanic aman dari crash saat Spirit di-retreat/mati saat blocking <!--id:fase0.block_safety-->
- [x] Setup Git/GitHub (repo private) <!--id:fase0.git_setup-->
- [x] Pisahkan StageConfig dari hardcode (`stage_config.gd` + `data/chapter/1/stage_01.tres`) <!--id:fase0.stage_config-->
- [x] Simple test scene end-to-end: Spirit + enemy + Crystal, kondisi Victory/Lose terverifikasi <!--id:fase0.e2e_test-->
- [x] Baseline performa Live2D (Godot Profiler) — ~60 FPS stabil dengan 1 model Live2D aktif <!--id:fase0.perf_baseline--> *(belum dites: multi-Spirit bersamaan & device Android asli)*
- [x] Setup Sentry untuk auto-capture crash report <!--id:fase0.sentry-->

### Live Ops & Komunitas (paralel, tidak terikat fase manapun)

- [x] Buat Discord server khusus Spirit Covenant <!--id:liveops.discord_server-->
- [x] Struktur channel minimal: `#devlog`, `#general`, `#bug-report`, `#feedback-ideas` <!--id:liveops.discord_channels-->
- [x] Mulai posting devlog rutin (1-2 post/minggu) <!--id:liveops.devlog-->
- [x] Komunikasikan transparan bahwa ini solo dev project <!--id:liveops.transparency-->

### Output Fase 0

Satu scene yang bisa dimainkan end-to-end: tempatkan Spirit → musuh datang → Crystal bisa hancur atau survive. **✅ Selesai penuh.**

---

## FASE 1 — Playable Prototype (3–4 minggu) 🔄 SEDANG BERJALAN

> Game bisa dimainkan, belum harus bagus. Tujuan: 5 Spirit bisa deploy sesuai role/elemen/damage type, 3 stage berbeda, menang/kalah jelas.

### Spirit System

- [x] Base struktur Spirit (`spirit.gd`: HP, ATK, range, attack_cd, block_count) via `init()` <!--id:fase1.spirit_base-->
- [x] 5 Spirit lengkap dengan stat dari blueprint di `spirit_roster` `.tres` (Raookami, Kuma, Yoshiki, Ratora, Yuki) <!--id:fase1.spirit_roster_5--> *(perlu update rebalance stat, 5 Main Class, 5 Elemen, Manifest/Phantasm DMG, serta perbaikan melee AoE khusus Ratora & arah hadap)*
- [x] Deploy cost system (`CP` / Covenant Point bar di UI) <!--id:fase1.deploy_cost--> *(di kode/UI saat ini masih tertulis `DP`, perlu disesuaikan ke `CP`)*
- [x] Retreat mechanic (klik kanan, cooldown 8 detik) <!--id:fase1.retreat-->
- [x] Direction-picker saat deploy (4 arah, CP dipotong setelah konfirmasi) <!--id:fase1.direction_picker-->

### Stage & Enemy

- [x] 3 enemy type pertama: Grunt, Brute, Sprinter (differensiasi stat/behavior) <!--id:fase1.enemy_types--> *(stat sudah dipisah via `EnemyData` `.tres`; diferensiasi visual, Manifest/Phantasm DEF, & behavior unik menyusul)*
- [ ] Object pooling untuk enemy, projectile, damage number popup <!--id:fase1.object_pooling--> *(Enemy sudah di-pool, namun masih ada bug reset state & double-death; Projectile masih `queue_free()` & Damage Popup belum dibuat)*
- [ ] 3 stage layout berbeda (jalur sederhana, cabang, sempit) <!--id:fase1.3_stage_layouts-->
- [x] Crystal HP visible di UI <!--id:fase1.crystal_hp_ui-->
- [x] Wave UI: "Wave 1/5" counter <!--id:fase1.wave_ui-->

### Game Feel

- [ ] Basic SFX: serangan, enemy mati, crystal kena damage <!--id:fase1.sfx_basic-->
- [ ] Screen shake ringan saat crystal kena hit <!--id:fase1.screen_shake-->
- [ ] Damage number popup <!--id:fase1.damage_popup-->
- [ ] Pause menu sederhana <!--id:fase1.pause_menu-->
- [ ] Onboarding Stage 1 (guided, 1 Spirit dulu, auto-highlight tile) <!--id:fase1.onboarding-->
- [ ] Opsi skip tutorial <!--id:fase1.skip_tutorial-->

### Analytics (mulai akhir Fase 1 / awal Fase 2)

- [ ] Integrasi GameAnalytics (gratis untuk indie) <!--id:fase1.analytics_setup-->
- [ ] Track event dasar: level_start, level_complete, level_fail <!--id:fase1.analytics_events-->

### Output Fase 1

Demo yang bisa dikasih ke orang lain untuk dicoba. Tidak perlu cantik.

---

## FASE 2 — Skill System & Covenant Link (2–3 minggu)

> Implementasi mechanic "pilih 1 dari 3 skill" + mekanik Last Stand `Covenant Link` — core identity game

- [ ] `SkillData` sebagai Resource/Dictionary (nama, deskripsi, tipe, parameter) <!--id:fase2.skill_data-->
- [ ] `SkillSelector` UI sebelum battle <!--id:fase2.skill_selector_ui-->
- [ ] `SkillExecutor` component per Spirit <!--id:fase2.skill_executor-->
- [ ] Skill Raookami: Shadow Dash + Dark Howl + Pack Instinct <!--id:fase2.skill_raookami-->
- [ ] Skill Kuma: Memory Seal + Foresight Barrier + Glacier Wall <!--id:fase2.skill_kuma-->
- [ ] Skill Yoshiki: Camouflage + Tidal Strike + Frost Current <!--id:fase2.skill_yoshiki-->
- [ ] Skill Ratora: Thunder Crash + Blaze Rush + Berserker Soul <!--id:fase2.skill_ratora-->
- [ ] Skill Koyuuki (Yuki): Dream Veil + Hypnotic Song + Ethereal Form <!--id:fase2.skill_koyuuki-->
- [ ] Covenant Link (Raku): trigger 1x saat musuh pertama lolos (knockback 3/5 tile, reset CD, shield kebal mati + omnibuff 10s, CP beku 10s, recoil -25% HP awal / 50% Max HP) + visual <!--id:fase2.covenant_link-->

### Output Fase 2

Battle terasa strategic dan penuh kejutan — pemain mulai mikir komposisi, tipe damage, elemen, dan timing skill.

---

## FASE 3 — Visual Chibi Modular & Lobby Integration (paralel dengan Fase 2–4)

> ⚠️ Paralel — tidak block gameplay. Battle chibi memakai **1 Template Modular (`Skeleton2D` Godot)** agar seragam dan cepat didaur ulang, sedangkan Live2D difokuskan untuk maskot/ilustrasi spesial Lobby pasca-core.

- [ ] Kuma: buat aset modular di atas template chibi + integrasi `Skeleton2D` (idle/attack/hurt/die) <!--id:fase3.kuma_l2d-->
- [ ] Yoshiki: buat aset modular di atas template chibi + integrasi `Skeleton2D` (idle/attack/hurt/die) <!--id:fase3.yoshiki_l2d-->
- [ ] Ratora: buat aset modular di atas template chibi + integrasi `Skeleton2D` (idle/attack/hurt/die) <!--id:fase3.ratora_l2d-->
- [ ] Yuki (Koyuuki): buat aset modular di atas template chibi + integrasi `Skeleton2D` (idle/attack/hurt/die) <!--id:fase3.koyuuki_l2d-->
- [ ] Raookami: animasi Attack + Hurt (Live2D idle sudah jalan; opsional disatukan ke template modular chibi agar seragam) <!--id:fase3.raookami_attack_hurt-->

> 💡 **Catatan Pipeline:** Gunakan 1 set tampak serong depan (+ flip kiri/kanan) terlebih dahulu; tampak belakang saat menghadap atas (`▲`) adalah polish opsional setelah 5 Spirit selesai. Efek hit/slash cukup memakai aset putih polos yang diwarnai otomatis sesuai elemen oleh Godot.

### Output Fase 3

Seluruh 5 Spirit tampil seragam dan mulus saat battle serta punya wujud interaktif di Lobby.

---

## FASE 4 — Content Build (4–6 minggu)

> Tujuan: **Prolog (5 Stage kontrak 1-per-1)** + **Chapter 1 Kantor Detektif (10 stage, 2 boss)**, progression system basic (Level 1–20 + Bond 1–5)

### Stage Content

- [ ] 10 stage dengan layout & kombinasi enemy berbeda (termasuk 5 Stage Prolog sebagai tutorial + kontrak 1-per-1 Spirit) <!--id:fase4.10_stages-->
- [ ] Stage 1-5: tutorial implisit, satu tipe enemy dominan <!--id:fase4.stage1_5_tutorial-->
- [ ] Stage 6-10: dua tipe kombinasi & pengenalan gimmick/elemen musuh, mulai butuh strategi <!--id:fase4.stage6_10_combo-->
- [ ] Setiap stage punya "momen aha" yang didesain <!--id:fase4.aha_moments-->
- [ ] 3-star rating system (tetap bisa 3-star selama Crystal HP utuh walau Covenant Link sempat terpicu) <!--id:fase4.star_rating-->

### Boss (Stage 5 & 10)

- [ ] Boss 2 fase (HP threshold trigger fase 2) <!--id:fase4.boss_2phase-->
- [ ] Boss pakai kombinasi mechanic enemy biasa <!--id:fase4.boss_combo_mechanic-->
- [ ] Special attack yang butuh respon pemain <!--id:fase4.boss_special_attack-->

### Progression System

- [ ] Spirit Level 1-20 (EXP material + Covenant Gold dari battle) <!--id:fase4.spirit_level-->
- [ ] Stat naik linear (tidak ada power creep / HP inflasi) <!--id:fase4.linear_stat-->
- [ ] Covenant Shards dari battle reward <!--id:fase4.currency_shards-->
- [ ] Bond system level 1-5 = Portray / Eidolon (bonus kenyamanan/mekanik + unlock dialog & ilustrasi) <!--id:fase4.bond_system-->

### Basic Story

- [ ] Dialog sebelum/sesudah tiap stage (ringkas, tanpa wajib background rumit, menanam benih plot twist) <!--id:fase4.basic_dialog-->
- [ ] Unlock lore fragment / catatan kasus detektif setelah stage selesai <!--id:fase4.lore_fragment-->

### Output Fase 4

Versi yang layak untuk soft release ke teman/komunitas kecil.

---

## FASE 5 — Roguelite Mode: Covenant Run (3–4 minggu)

> Konten replayable tanpa stamina

- [ ] Pilih 3 Spirit dari roster <!--id:fase5.pick_3_spirit-->
- [ ] 5 stage acak dari pool <!--id:fase5.random_5_stage-->
- [ ] Covenant Blessing: pilih 1 dari 3 buff tiap selesai stage <!--id:fase5.blessing_choice-->
- [ ] Reward tetap didapat walau run gagal (no punishment) <!--id:fase5.no_punishment-->

### Output Fase 5

Pemain bisa main tiap hari tanpa merasa gated.

---

## FASE 6 — Android Port & Release (2–3 minggu)

> Windows selesai dulu baru Android

- [ ] Godot Export Templates untuk Android <!--id:fase6.export_template-->
- [ ] UI responsif (Control node anchor/container) <!--id:fase6.responsive_ui-->
- [ ] Touch input: tap to deploy, swipe untuk stats <!--id:fase6.touch_input-->
- [ ] Performance check 60fps di mid-range Android <!--id:fase6.perf_check_android-->
- [ ] Testing di minimal 2 device berbeda <!--id:fase6.multi_device_test-->
- [ ] Soft release: itch.io (Windows) + Google Play beta <!--id:fase6.soft_release-->

---

## Di Luar Rencana Awal (ditambahkan saat development)

> Diisi otomatis oleh `sync_docs.ps1` ketika ada task Kanban Done yang **tidak** cocok dengan item checklist manapun di atas — artinya ide/kebutuhan yang muncul di tengah jalan, bukan yang direncanakan dari awal. Tidak perlu diedit manual; cukup dibaca sesekali untuk tahu apa saja yang sudah keluar dari rencana original.

<!--AUTO_UNPLANNED_START-->

<!--AUTO_UNPLANNED_END-->

---

## Timeline Ringkas

Sekarang
│
├── Fase 0: Stabilisasi 1–2 minggu ✅ Selesai
├── Fase 1: Playable Prototype 3–4 minggu 🔄 Berjalan
├── Fase 2: Skill & Cov. Link 2–3 minggu ─┐
├── Fase 3: Chibi Modular/Lobby ongoing ─┘ jalan bersamaan
├── Fase 4: Content Build 4–6 minggu
├── Fase 5: Covenant Run 3–4 minggu
└── Fase 6: Android + Release 2–3 minggu
──────────
Total estimasi: ~4–5 bulan
(dengan buffer solo dev 1.5x)

---

## Scope Freeze Rules

**Tidak boleh ditambah sebelum Fase 4 selesai:**

- Alter karakter (dirilis bertahap pasca-rilis setelah seluruh banner 5 Spirit dasar masuk Standard pool)
- Gacha system lengkap
- Season event
- Fitur multiplayer / leaderboard apapun
- Daily quest system

**Boleh dikerjain paralel kapan saja:**

- Art / Modular Chibi (`Skeleton2D`) / Lobby Showcase
- BGM / SFX
- Blueprint update

---

## Kalau Stuck / Burnout

- **Switch ke mode ringan** — kalau coding mandek, kerjakan aset modular atau tulis kasus kecil. Kalau jenuh gambar, mainkan kode di Godot!
- **Mini milestone** — pecah fase besar jadi target 1 hari.
- **Show early** — kasih lihat ke orang lain seawal mungkin.
- **Vibe Coder** — pakai AI assist biar coding lebih cepat.

---

_Roadmap ini hidup — update seiring progress, tapi detail teknis harian hidup di Kanban & Git log, bukan di sini._