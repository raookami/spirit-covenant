# SPIRIT COVENANT — Solo Dev Roadmap

> Berdasarkan Blueprint v1.5 · Dibuat Juli 2026 · Update 18 Nov 2026 (restrukturisasi untuk auto-sync Kanban)
> Engine: Godot 4.7 (GDScript) · Art: CSP + Live2D Cubism 5.0 (via GDCubism)

> ℹ️ **Cara baca file ini:** Setiap item checklist punya tag `<!--id:xxx-->` di akhir baris. Tag ini dipakai `sync_docs.ps1` untuk mencocokkan task Kanban yang sudah Done dan mencentang baris yang sesuai secara otomatis. **Jangan hapus tag ini** walau kelihatan aneh — itu bukan komentar biasa, itu kunci sinkronisasi. Histori detail teknis (tanggal, angka FPS, cara compile, dll) ada di Git log dan commit message, bukan di sini — roadmap ini sengaja dijaga ringkas di level fase.

---

## Status Sekarang (Ringkas)

Fondasi gameplay loop sudah ada dan jalan: grid map, deploy system, enemy pathfinding, block mechanic (melee+ranged), Crystal HP/DP, attack & projectile dasar. GDCubism (plugin Live2D unofficial) sudah berhasil di-compile dan terintegrasi — Raookami sudah render dengan Live2D idle motion di battle scene. **Fase 0 dan sebagian besar Fase 1 sudah selesai.** Lihat `CURRENT_STATE.md` untuk snapshot ter-update otomatis.

### Catatan Migrasi Engine (Unity → Godot)

Project sempat direncanakan pakai Unity, lalu pindah ke Godot (20 Juli 2026) karena asset Live2D portable lintas engine — tidak ada yang hilang dari keputusan ini. Kalau perlu setup ulang toolchain GDCubism di mesin lain, langkah ringkasnya: install MSVC Build Tools (C++ workload) → `pip install scons==4.10.1` → clone GDCubism + submodule → download Cubism SDK for Native **R4_1** (bukan versi terbaru, versi terbaru belum sediakan lib untuk MSVC terbaru) → `scons platform=windows arch=x86_64 target=template_debug` (+ `template_release`) → copy `addons/gd_cubism` ke project.

---

## Prinsip Roadmap Ini

1. **Playable dulu, polish belakangan** — setiap milestone harus menghasilkan sesuatu yang bisa dimainkan
2. **Art & code paralel** — Live2D tidak harus selesai sebelum gameplay bisa ditest
3. **Scope freeze per fase** — tidak tambah fitur baru sebelum fase selesai
4. **Solo dev buffer** — semua estimasi dikali 1.5x dari perkiraan normal
5. **Roadmap ini level fase, bukan level teknis** — detail implementasi hidup di task Kanban, bukan di sini

---

## FASE 0 — Stabilisasi (1–2 minggu) ✅ SELESAI (22 Juli 2026)

> Beresin fondasi yang ada sebelum lanjut

- [x] Audit script untuk null reference & race condition tersembunyi <!--id:fase0.audit_null--> *(pola `is_instance_valid()` konsisten dipakai; race condition `_spawn_enemy()` sudah diperbaiki)*
- [x] Block mechanic aman dari crash saat Spirit di-retreat/mati saat blocking <!--id:fase0.block_safety-->
- [x] Setup Git/GitHub (repo private) <!--id:fase0.git_setup-->
- [x] Pisahkan StageConfig dari hardcode (`stage_config.gd` + `data/stage_01.tres`) <!--id:fase0.stage_config-->
- [x] Simple test scene end-to-end: Spirit + enemy + Crystal, kondisi Victory/Lose terverifikasi <!--id:fase0.e2e_test-->
- [x] Baseline performa Live2D (Godot Profiler) — ~60 FPS stabil dengan 1 model Live2D aktif <!--id:fase0.perf_baseline--> *(belum dites: multi-Spirit Live2D bersamaan & device Android asli)*
- [x] Setup Sentry untuk auto-capture crash report <!--id:fase0.sentry-->

### Live Ops & Komunitas (paralel, tidak terikat fase manapun)

- [ ] Buat Discord server khusus Spirit Covenant <!--id:liveops.discord_server-->
- [ ] Struktur channel minimal: `#devlog`, `#general`, `#bug-report`, `#feedback-ideas` <!--id:liveops.discord_channels-->
- [ ] Mulai posting devlog rutin (1-2 post/minggu) <!--id:liveops.devlog-->
- [ ] Komunikasikan transparan bahwa ini solo dev project <!--id:liveops.transparency-->

### Output Fase 0

Satu scene yang bisa dimainkan end-to-end: tempatkan Spirit → musuh datang → Crystal bisa hancur atau survive. **✅ Selesai penuh.**

---

## FASE 1 — Playable Prototype (3–4 minggu) 🔄 SEDANG BERJALAN

> Game bisa dimainkan, belum harus bagus. Tujuan: 5 Spirit bisa deploy, 3 stage berbeda, menang/kalah jelas.

### Spirit System

- [x] Base struktur Spirit (`spirit.gd`: HP, ATK, range, attack_cd, block_count) via `init()` <!--id:fase1.spirit_base-->
- [x] 5 Spirit lengkap dengan stat dari blueprint di `SPIRIT_ROSTER` (Raookami, Kuma, Yoshiki, Ratora, Koyuuki) <!--id:fase1.spirit_roster_5--> *(semua sudah ada stat & attack pattern; visual Live2D baru Raookami, 4 lain masih placeholder PNG)*
- [x] Deploy cost system (Crystal/DP bar di UI) <!--id:fase1.deploy_cost-->
- [x] Retreat mechanic (klik kanan, cooldown 8 detik) <!--id:fase1.retreat-->
- [x] Direction-picker saat deploy (4 arah, DP dipotong setelah konfirmasi) <!--id:fase1.direction_picker-->

### Stage & Enemy

- [x] 3 enemy type pertama: Grunt, Brute, Sprinter (differensiasi stat/behavior) <!--id:fase1.enemy_types--> *(catatan: `enemy.gd` masih pakai flag debug `TESTING_TANKY_ENEMY` — matikan begitu differensiasi tipe mulai dikerjakan)*
- [x] Object pooling untuk enemy, projectile, damage number popup <!--id:fase1.object_pooling-->
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

## FASE 2 — Skill System (2–3 minggu)

> Implementasi mechanic "pilih 1 dari 3 skill" — core identity game

- [ ] `SkillData` sebagai Resource/Dictionary (nama, deskripsi, tipe, parameter) <!--id:fase2.skill_data-->
- [ ] `SkillSelector` UI sebelum battle <!--id:fase2.skill_selector_ui-->
- [ ] `SkillExecutor` component per Spirit <!--id:fase2.skill_executor-->
- [ ] Skill Raookami: Shadow Dash + Dark Howl + Pack Instinct <!--id:fase2.skill_raookami-->
- [ ] Skill Kuma: Memory Seal + Foresight Barrier + Glacier Wall <!--id:fase2.skill_kuma-->
- [ ] Skill Yoshiki: Camouflage + Tidal Strike + Frost Current <!--id:fase2.skill_yoshiki-->
- [ ] Skill Ratora: Thunder Crash + Blaze Rush + Berserker Soul <!--id:fase2.skill_ratora-->
- [ ] Skill Koyuuki: Dream Veil + Hypnotic Song + Ethereal Form <!--id:fase2.skill_koyuuki-->
- [ ] Covenant Link (Raku): boost 50% ATK 10 detik, cooldown 60 detik + visual <!--id:fase2.covenant_link-->

### Output Fase 2

Battle terasa strategic — pemain mulai mikir komposisi dan timing skill.

---

## FASE 3 — Live2D Integration (paralel dengan Fase 2–4)

> ⚠️ Paralel — tidak block gameplay. Toolchain GDCubism sudah beres, tinggal dipakai per karakter.

Per karakter (ulangi untuk Kuma, Yoshiki, Ratora, Koyuuki — Raookami idle sudah selesai):

- [ ] Kuma: layer separation CSP → rigging → idle/attack/hurt motion → export & integrasi <!--id:fase3.kuma_l2d-->
- [ ] Yoshiki: layer separation CSP → rigging → idle/attack/hurt motion → export & integrasi <!--id:fase3.yoshiki_l2d-->
- [ ] Ratora: layer separation CSP → rigging → idle/attack/hurt motion → export & integrasi <!--id:fase3.ratora_l2d-->
- [ ] Koyuuki: layer separation CSP → rigging → idle/attack/hurt motion → export & integrasi <!--id:fase3.koyuuki_l2d-->
- [ ] Raookami: animasi Attack + Hurt (idle sudah selesai) <!--id:fase3.raookami_attack_hurt-->

> 💡 Saat export dari Cubism Editor, selalu cek manual blok `"Motions"` di `model3.json` benar-benar menunjuk ke file `.motion3.json` yang benar (pernah hilang otomatis saat export).

### Output Fase 3

Minimal 1 karakter (Raookami) full Live2D in-game. Sisanya menyusul paralel.

---

## FASE 4 — Content Build (4–6 minggu)

> Tujuan: Chapter 1 (10 stage), 2 boss (Stage 5 & 10), progression system basic

### Stage Content

- [ ] 10 stage dengan layout & kombinasi enemy berbeda <!--id:fase4.10_stages-->
- [ ] Stage 1-5: tutorial implisit, satu tipe enemy dominan <!--id:fase4.stage1_5_tutorial-->
- [ ] Stage 6-10: dua tipe kombinasi, mulai butuh strategi <!--id:fase4.stage6_10_combo-->
- [ ] Setiap stage punya "momen aha" yang didesain <!--id:fase4.aha_moments-->
- [ ] 3-star rating system <!--id:fase4.star_rating-->

### Boss (Stage 5 & 10)

- [ ] Boss 2 fase (HP threshold trigger fase 2) <!--id:fase4.boss_2phase-->
- [ ] Boss pakai kombinasi mechanic enemy biasa <!--id:fase4.boss_combo_mechanic-->
- [ ] Special attack yang butuh respon pemain <!--id:fase4.boss_special_attack-->

### Progression System

- [ ] Spirit Level 1-20 (EXP dari battle) <!--id:fase4.spirit_level-->
- [ ] Stat naik linear (tidak ada power creep) <!--id:fase4.linear_stat-->
- [ ] Covenant Shards dari battle reward <!--id:fase4.currency_shards-->
- [ ] Bond system level 1-5 per Spirit (unlock dialog + ilustrasi) <!--id:fase4.bond_system-->

### Basic Story

- [ ] Dialog sebelum tiap stage (max 5 baris, tanpa voice) <!--id:fase4.basic_dialog-->
- [ ] Unlock lore fragment setelah stage selesai <!--id:fase4.lore_fragment-->

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

```
Sekarang
  │
  ├── Fase 0: Stabilisasi        1–2 minggu   ✅ Selesai
  ├── Fase 1: Playable Prototype  3–4 minggu   🔄 Berjalan
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

**Tidak boleh ditambah sebelum Fase 4 selesai:**

- Alter karakter (pasca-release)
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

- **Switch ke art mode** — kalau coding mandek, gambar karakter dulu. Progress tetap ada.
- **Mini milestone** — pecah fase besar jadi target 1 hari.
- **Show early** — kasih lihat ke orang lain seawal mungkin.
- **Vibe Coder** — pakai AI assist biar coding lebih cepat.

---

_Roadmap ini hidup — update seiring progress, tapi detail teknis harian hidup di Kanban & Git log, bukan di sini._
