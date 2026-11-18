# AUDIT_REPORT.md — Laporan Audit Ketidakkonsistenan Repository *Spirit Covenant*

**Tanggal Audit:** 18 November 2026  
**Cakupan:** Seluruh file kode (`.gd`), scene/resource (`.tscn`, `.tres`), konfigurasi (`.godot`, `.json`, `.githooks`, `.ps1`, `.kanban`), dan dokumen desain (`docs/*.md`).  
**Status:** Read-only audit (belum ada file kode maupun dokumentasi yang diubah).

---

## Ringkasan Eksekutif

Repository mengalami drift/ketidaksinkronan antara **dokumen visi awal** (`SPIRIT_COVENANT_BLUEPRINT.md`), **dokumen desain lanjutan** (`SPIRIT_COVENANT_ECONOMY.md`, `Lore.md`, naskah prolog), **tracker/otomasi** (`SPIRIT_COVENANT_ROADMAP.md`, `kanban_tasks_data.kanban`, `.ps1`), dan **implementasi kode Godot aktual** (`scenes/*.gd`, `scripts/*.gd`, `data/**/*.tres`).

Temuan dikelompokkan ke dalam **5 kategori utama**:
1. Perbedaan Nama Variabel, Istilah, dan Penamaan
2. Alur Logika & Implementasi Teknis yang Bertabrakan
3. Aturan Desain, Ekonomi, & Lore yang Tidak Sinkron
4. Ketidakkonsistenan Dokumentasi, Roadmap, Kanban, & Script Otomasi
5. Path Rusak, Aset Hilang, & Potensi Dead Code

---

## 1. Perbedaan Nama Variabel, Istilah, dan Penamaan

### 1.1 Nama Panggilan Koyuuki (`"Uki"` vs `"Yuki"`)
- `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 203, 234–235): Nama panggilan Koyuuki ditetapkan sebagai **`"UKI"`** (`### KOYUUKI "UKI"`, `_Night Bloom Uki_`, `_Crimson Uki_`).
- `data/spirits/koyuuki/koyuuki_data.tres` (baris 8): `display_name` diisi **`"Yuki"`**, bukan `"Uki"`.

### 1.2 Nama Mata Uang Gacha & Upgrade
- `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 340, 393–395): Mendefinisikan 3 mata uang:
  - Premium: **`Covenant Crystal`**
  - Gacha ticket: **`Spirit Shard`**
  - Upgrade material: **`Ether Fragment`**
- `docs/SPIRIT_COVENANT_ECONOMY.md` (baris 25, 65–69, 111, 180): Tidak memakai nama di atas; justru mendefinisikan:
  - Mata uang pull gacha (150/pull): **`Covenant Shards`** (atau `Shards`)
  - Mata uang tukar duplikat (20 = 1 tiket): **`Covenant Fragment`**
  - Mata uang upgrade level: **`Covenant Gold`** + **`EXP material`**
- `docs/SPIRIT_COVENANT_ROADMAP.md` (baris 150): Mengikuti Economy (`Covenant Shards dari battle reward`), bertentangan dengan tabel Currency di Blueprint.

### 1.3 Istilah Sumber Daya Penempatan Spirit (`Cost` vs `DP`)
- `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 268–269, 436): Menggunakan istilah **`Cost`** dan **`Cost Bar`**.
- `scenes/battle.gd` (baris 43–45, 53–55, 292, 344), `scenes/stage_config.gd` (baris 40–47), `data/chapter/1/stage_01.tres` (baris 15–17), dan `docs/SPIRIT_COVENANT_ROADMAP.md` (baris 56, 58): Menggunakan istilah **`DP`** (Deployment Points). *(Catatan: `scripts/spirit_data.gd` baris 6 tetap menggunakan variabel `cost`)*.

### 1.4 Nama Skill Ratora & Koyuuki Berbeda Total
- **Ratora:**
  - `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 190–192): `Thunder Claw`, `Flame Rush`, `Berserk Mode`.
  - `docs/SPIRIT_COVENANT_ROADMAP.md` (baris 98) & `kanban_tasks_data.kanban` (task UUID `3173bc20-b6e2-4710-a791-fbae94da88b8`): `Thunder Crash`, `Blaze Rush`, `Berserker Soul`.
- **Koyuuki:**
  - `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 226–228): `Hypnosis`, `Blood Drain`, `Ultrasound Pulse`.
  - `docs/SPIRIT_COVENANT_ROADMAP.md` (baris 99) & `kanban_tasks_data.kanban` (task UUID `8aa379ad-f896-471d-820f-20733eaf251e`): `Dream Veil`, `Hypnotic Song`, `Ethereal Form`.

### 1.5 Salah Kaprah Metrik `SPD (tile/detik)` vs `atk_spd` (Attack Cooldown)
- `docs/SPIRIT_COVENANT_ECONOMY.md` (bagian 5c, baris 218–230): Kolom stat ditulis **`SPD (tile/detik)`** dengan penjelasan untuk Koyuuki: `2.2 (terbang)` / `SPD tertinggi di roster (sesuai "sangat cepat, bisa terbang")` — jelas didefinisikan sebagai **kecepatan gerak (movement speed)**.
- `data/spirits/*/*.tres` & `scripts/spirit_data.gd` (baris 12) & `scenes/spirit.gd` (baris 88, 291, 302): Nilai `SPD` tersebut diinvers (`1 / SPD`) menjadi **`atk_spd`** (interval cooldown serangan dalam detik):
  - `raookami_data.tres` (baris 16): `atk_spd = 0.5` (`1 / 2.0`)
  - `kuma_data.tres` (baris 15): `atk_spd = 1.25` (`1 / 0.8`)
  - `yoshiki_data.tres` (baris 14): `atk_spd = 0.625` (`1 / 1.6`)
  - `ratora_data.tres` (baris 14): `atk_spd = 0.55` (`~1 / 1.8`)
  - `koyuuki_data.tres` (baris 15): `atk_spd = 0.45` (`~1 / 2.2`)
  - Karena dalam Tower Defense berbasis tile, Spirit yang sudah di-deploy tidak berjalan menyusuri tile, metrik `SPD (tile/detik)` di Economy bertabrakan makna dengan `atk_spd` (detik antar serangan) di kode.

### 1.6 Referensi Variabel Lama `SPIRIT_ROSTER`
- `docs/SPIRIT_COVENANT_ROADMAP.md` (baris 55): Menyebut konstanta `SPIRIT_ROSTER` (`5 Spirit lengkap dengan stat dari blueprint di SPIRIT_ROSTER`).
- `scenes/battle.gd` (baris 21): Sudah diganti menjadi `@export var spirit_roster: Array[SpiritData] = []` yang diisi melalui `scenes/battle.tscn` (baris 16) dari file `.tres`.

### 1.7 Nama File Prolog & Struktur Folder Aset
- `docs/Lore.md` (baris 3, 42): Merujuk ke file **`prolog_chapter_1_raookami.md`** (pakai underscore, tanpa kode bahasa).
- Struktur folder aktual: File bernama `docs/prolog chapter 1 raookami id.md` dan `docs/prolog chapter 1 raookami jp.md` (pakai spasi dan akhiran `id`/`jp`).
- `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 560–575): Mencantumkan struktur folder `assets/enemies/`, padahal di repo dan kode (`scenes/enemy.gd` baris 6, `data/enemies/**/*.tres`) folder berada di `assets/spirites/enemies/` (dengan typo `spirites`).

---

## 2. Alur Logika & Implementasi Teknis yang Bertabrakan

### 2.1 Format `waves` di `StageConfig` (Integer vs String ID)
- `scenes/stage_config.gd` (baris 31–33): Komentar dokumentasi menentukan format integer:
  `Format: [{"type": 0, "count": 3}]` (`type: 0=Grunt, 1=Brute, 2=Sprinter`).
- `data/chapter/1/stage_01.tres` (baris 18) & `scenes/battle.gd` (baris 141, 155–157, 450): Menggunakan **String ID** yang dicocokkan ke `EnemyData.id` (`"grunt"`, `"sprinter"`, `"brute"`).

### 2.2 `max_enemies` dan `enemies_spawned` Tidak Sinkron dengan Sistem Wave
- `data/chapter/1/stage_01.tres` (baris 14 vs baris 18): `max_enemies = 8`, sedangkan total musuh di `waves` adalah `3 + 4 + 2 = 9`.
- `scenes/battle.gd` (baris 41, 60, 137, 149): `max_enemies` dan `enemies_spawned` dideklarasikan dan dimuat dari `StageConfig`, tetapi **tidak pernah dipakai** dalam `_process()` maupun `_spawn_enemy()`.

### 2.3 `EnemyData.texture_path` dan `SpiritData.texture_path` Diabaikan oleh Entity Scene
- `scripts/enemy_data.gd` (baris 10) & `data/enemies/**/*.tres`: Mendefinisikan `texture_path = "res://assets/spirites/enemies/enemy1.png"`.
- `scenes/enemy.gd` (baris 6, 107): Mengabaikan `data.texture_path` dan melakukan `preload` statis `ENEMY_TEXTURE` untuk semua musuh (`grunt`, `sprinter`, `brute`).
- `scripts/spirit_data.gd` (baris 13) & `data/spirits/*/*.tres`: Mendefinisikan `texture_path` (yang hanya dibaca oleh `battle.gd` baris 271 & 384 untuk card UI dan drag sprite).
- `scenes/spirit.gd` (baris 108–143): Mengabaikan `data.texture_path` dan hanya mencari `%s_idle.model3.json` atau `%s_idle_%04d.png`, sehingga jika keduanya tidak ada, unit di arena jatuh ke `ColorRect` polos meskipun `texture_path` valid (atau sebaliknya, unit dengan `texture_path` tidak ada asetnya tetap tampil kotak warna).

### 2.4 Cacat Logika pada Object Pooling Musuh & Tidak Adanya Pooling Projectile
- `scenes/battle.gd` (baris 457–470) & `scenes/enemy.gd` (baris 33–58, 150–181):
  - **Double-death / duplikasi entry di pool:** `enemy.gd::take_damage()` (baris 169–181) tidak mengecek `if hp <= 0 or not visible: return` di awal fungsi. Jika 2 Spirit menyerang musuh yang sama pada frame yang sama dan HP turun `<= 0` dua kali, signal `enemy_died` ter-emit dua kali dan `battle.gd::_on_enemy_died` memasukkan node `enemy` yang sama ke `enemy_pool` **dua kali**.
  - **State tidak di-reset di `enemy.gd::setup()`:** `block_attack_timer` (baris 18), `sprite.scale.x` (di-flip di baris 81–84), `modulate` (di-`await` di baris 155 & 174), dan `blocked_by` saat mati (baris 177–181 tidak me-reset `blocked_by = null`) tidak dibersihkan saat musuh diambil ulang dari `enemy_pool`.
- `scenes/spirit.gd` (baris 349–361): `_spawn_projectile()` masih membuat `ColorRect.new()` setiap serangan dan menghancurkannya dengan `proj.queue_free()`, bertentangan dengan status `[x]` *Object pooling untuk enemy, projectile, damage number popup* di Roadmap (baris 63).

### 2.5 Kalkulasi Defense (`phys_def` & `magic_def`) & Tipe Serangan
- `docs/SPIRIT_COVENANT_ECONOMY.md` (bagian 5c, baris 168–173): Menetapkan sistem **Physical DMG vs Magic DMG** terpisah (Physical DEF menahan Physical DMG, Magic DEF menahan Magic DMG).
- `scenes/spirit.gd` (baris 189–191): `take_damage()` justru mengambil **rata-rata** kedua defense: `var def_avg := (phys_def + magic_def) / 2.0`.
- `scripts/enemy_data.gd` & `scenes/enemy.gd`: Belum memiliki `damage_type`, `phys_def`, `magic_def`, maupun `element`, sedangkan `scripts/spirit_data.gd` belum memiliki `element` maupun `damage_type`.

### 2.6 Semua Spirit Melee Menyerang AoE & Menembakkan Projectile
- `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 81, 116, 186): Hanya **Ratora** yang punya serangan melee AoE (`Range: Melee (tapi AoE kecil)`), sedangkan Raookami dan Kuma bertipe Melee standar.
- `scenes/spirit.gd` (baris 290–301): `_process_melee()` menyerang **semua** musuh di `attack_patterns` sekaligus (`for enemy in targets: _attack_enemy(enemy)`) — membuat semua unit melee bersifat AoE penuh — dan `_attack_enemy()` (baris 342) memanggil `_spawn_projectile()` baik untuk unit `ranged` maupun `melee`.

### 2.7 Pemilihan Arah Hadap (`set_facing`) Tidak Mengubah Visual Spirit
- `scenes/battle.gd` (baris 449–463): Meminta pemain memilih arah hadap 4 arah (`▲`, `▼`, `◀`, `▶`), lalu memanggil `spirit.set_facing(dir)`.
- `scenes/spirit.gd` (baris 98–105): `set_facing()` memanggil `_apply_facing_visual()`, namun `_apply_facing_visual()` hanya berisi `pass`. Orientasi visual Spirit hanya berubah saat menyerang target (`_attack_enemy()` baris 332–340).

### 2.8 Overflow Tinggi UI Bottom Panel Terhadap Viewport
- `project.godot` (baris 26–27): `viewport_width = 1280`, `viewport_height = 720`.
- `scenes/battle.gd` (baris 11, 35, 233–236): `grid_rows = 5`, `TILE_SIZE = 128` -> `panel_y = 640`. Tinggi `bg` bottom panel adalah `100` (`640 + 100 = 740px`), sehingga **20px terbawah panel terpotong keluar viewport** `720px`.

### 2.9 Kebocoran Input Saat Memilih Arah Deploy & Konversi Koordinat Negatif
- `scenes/battle.gd` (baris 401–409 & `spirit.gd` baris 68–73): Saat `choosing_direction == true`, `battle.gd::_input()` tidak memanggil `get_viewport().set_input_as_handled()`, sehingga klik pada tombol arah juga diteruskan ke `spirit.gd::_input()` dan men-toggle indikator range Spirit di dekat posisi klik.
- `scenes/battle.gd` (`_drop_spirit()` & `_try_retreat()`) & `scenes/spirit.gd` (baris 311–315): Konversi posisi ke tile memakai `int(pos.x / tile_size)` alih-alih `floori()`, sehingga koordinat negatif kecil (mis. `-10px`) membulat ke `0` (tile `0`), bukan `-1`.

### 2.10 Threshold Warna HP Crystal Di-Hardcode untuk Max HP = 10
- `scenes/battle.gd` (baris 360–369): `_update_crystal_hud()` mengecek `crystal_hp <= 3` dan `crystal_hp <= 6` secara absolut (mengasumsikan `crystal_max_hp == 10`), tidak proporsional jika stage lain mengubah `crystal_max_hp`.

### 2.11 UI Wave Counter Melompat Sebelum Wave Dimulai & Softlock Jika ID Musuh Salah
- `scenes/battle.gd` (baris 396–399, 453–456, 471–475):
  - Setelah musuh terakhir Wave 1 di-spawn, `current_wave_index` langsung naik ke `1` dan `wave_timer = -5.0`, sehingga HUD langsung menampilkan `Wave: 2 / 3` selama jeda 8 detik sebelum musuh Wave 2 pertama muncul.
  - Jika `enemy_data == null` (baris 453–456), `_spawn_enemy()` melakukan `return` tanpa menaikkan counter atau menghentikan wave, sehingga stage tidak akan pernah mencapai kondisi menang.

### 2.12 Indikator `type_lbl` & `skill_bar` Tidak Konsisten di `spirit.gd`
- `scenes/spirit.gd` (baris 250–257 vs baris 108–143): Label `"M"` / `"R"` (`type_lbl`) hanya dibuat di `_build_live2d_visual()`, tidak dibuat pada fallback `AnimatedSprite2D` atau placeholder `ColorRect`.
- `scenes/spirit.gd` (baris 168–179): `skill_bar_bg` dan `skill_bar_fill` selalu dirender di bawah HP bar setiap Spirit, tetapi `skill_bar_fill` tidak pernah di-update nilainya di mana pun (selalu `0px`).

---

## 3. Aturan Desain, Ekonomi, & Lore yang Tidak Sinkron

### 3.1 Kontradiksi Internal pada `docs/SPIRIT_COVENANT_BLUEPRINT.md`
- **Versi Dokumen:** Header baris 3 menulis **`Version: 1.4`**, sedangkan footer baris 689 menulis **`v1.5`**. (`SPIRIT_COVENANT_ROADMAP.md` baris 3 merujuk `v1.5`; `SPIRIT_COVENANT_ECONOMY.md` baris 3 merujuk `v1.4`).
- **Art Style:** Baris 5 menyebut `Anime 2D ilustrasi (CSP + Live2D Cubism)` dan baris 670 menegaskan `Bukan pixel art, bukan Rive.`, tetapi Elevator Pitch di baris 20 masih berbunyi: **`Spirit Covenant adalah tower defense 2D pixel art`**.
- **Penomoran Sub-bab:** Bagian `4.6 Daily & Weekly System` (baris 352) langsung melompat ke `4.8 Leveling System` (baris 374); sub-bab `4.7` hilang.
- **Blok Terduplikasi & Salah Rujuk Section:**
  - Bagian 6.1 Art Pipeline (baris 459–467) memiliki blok `Live2D Cubism 5.0 → Rigging → Animasi → Export` yang **terduplikasi dua kali berturut-turut**.
  - Baris 477 merujuk catatan compile GDCubism di **`section 9`**, padahal catatan compile berada di **`section 8`** (baris 588), sedangkan `section 9` adalah `ENEMY DESIGN` (baris 592).

### 3.2 Kontradiksi Sistem Elemen & Alter (`Blueprint` vs `Economy` vs `Lore.md`)
- **Jumlah Elemen per Spirit:**
  - `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 104, 139, 174, 209): Memberi 2 elemen pada 4 Spirit (`Es / Psikik`, `Air / Es`, `Petir + Api`, `Angin / Darah`).
  - `docs/SPIRIT_COVENANT_ECONOMY.md` (baris 191–201): Membatalkan elemen kedua Blueprint; menetapkan **1 elemen mutlak** dari 5 elemen (`Kegelapan, Es, Air, Petir, Angin`).
- **Mekanik Elemen pada Alter (contoh: *Winter Raoo*):**
  - `docs/SPIRIT_COVENANT_BLUEPRINT.md` (baris 93): `_Winter Raoo_ — outfit salju, elemen es`.
  - `docs/SPIRIT_COVENANT_ECONOMY.md` (baris 203): Menyatakan `Alter = swap elemen... Alter "Winter Raoo" = Air sepenuhnya` (**Air**, bukan **Es**).
  - `docs/Lore.md` (baris 52–53): Menyatakan nama alter seperti `"Storm"`, `"Inferno"`, `"Winter"` **hanya flavour/branding**, bukan mekanik mengganti/menggabungkan elemen (`bukan dari mengganti-ganti elemen combat`, baris 55). Ini bertabrakan dengan Blueprint dan Economy yang menyebut Alter mengganti elemen.

### 3.3 Kontradiksi Aturan Gacha, Bond, & Progression (`Blueprint` vs `Economy` vs `Roadmap`)
- **Hard Pity & Soft Pity:**
  - Blueprint (baris 399–401): Base rate `3%`, soft pity `60`, **hard pity `80`**.
  - Economy (baris 111, 128–137): **Hard pity `70`** (direvisi dari 65), tanpa spesifikasi soft pity / base rate.
- **Isi Pool Gacha:**
  - Blueprint (baris 315, 399): Gacha hanya untuk summon **Alter**; pemain F2P diasumsikan sudah memiliki 5 Spirit base (baris 290).
  - Economy (baris 13, 58–68): Gacha memiliki pool **Standard** (berisi 5 Spirit dasar) dan **Featured/Limited** (Alter), di mana duplikat Spirit dari gacha digunakan untuk menaikkan Bond dan menghasilkan Fragment tiket.
- **Cara Menaikkan Bond Level (1–5):**
  - Blueprint (baris 380): Lewat **interaksi di Lobby** (tap karakter, beri hadiah).
  - Economy (baris 58–60): Otomatis naik dari **duplikat gacha ke-1 sampai ke-5**.
- **Daily Login & Daily Quest vs Scope Freeze:**
  - Blueprint (baris 407): `Daily login 7 hari: ~10 Spirit Shard`.
  - Economy (baris 27–49, 98–103): `Login bonus progresif 10 tahap: 500 Shards` (~3 siklus/bulan = ~1.500 Shards) + `Daily quest: 80 Shards/hari` (= 2.400/bulan).
  - Roadmap (baris 224–230): Memasukkan **`Daily quest system`** ke dalam **Scope Freeze Rules** (*"Tidak boleh ditambah sebelum Fase 4 selesai"*), sementara Economy menjadikannya tulang punggung ekonomi awal.
- **Skill Leveling:**
  - Blueprint (baris 379): Ada `Skill Level` memakai material dari stage tertentu.
  - Economy (baris 144–146): Menegaskan progression karakter cukup **2 lapis** (Level 1–20 + Bond 1–5), tanpa menyebutkan Skill Leveling.
- **Salah Rujuk Poin Blueprint di `Economy`:**
  - `docs/SPIRIT_COVENANT_ECONOMY.md` (baris 153): Merujuk `Blueprint poin 15` untuk aturan anti-stamina. Di Blueprint bagian 12, poin 15 (baris 683) adalah **Roguelite mode (Covenant Run)**; poin 16 adalah **No streak punishment** (anti-stamina ada di bagian 4.6 baris 370 dan bagian 10 baris 637).

### 3.4 Kontradiksi Ukuran Tim & Mekanik Retreat
- **Ukuran Tim:** Blueprint (baris 244, 436) menetapkan `Pilih Tim (max 4 Spirit)`, sedangkan Roadmap Fase 5 (baris 168) menetapkan `Pilih 3 Spirit dari roster` (untuk Covenant Run, tanpa penjelasan apakah batas tim global berubah menjadi 3).
- **Retreat Mechanic:** Blueprint (baris 270) menyebut retreat dilakukan *"dengan mengorbankan sebagian HP mereka"*. Implementasi di `scenes/battle.gd` (`_try_retreat()`, baris 12 & sekitar baris 525–548) hanya menghapus unit dan memberi cooldown tetap `8.0` detik (sama persis dengan penalti saat mati di `_on_spirit_died()`), tanpa ada konsep pengorbanan HP.

### 3.5 Kontradiksi Lore, Tone, & Premis Cerita
Terdapat **3 versi premis yang saling bertabrakan** di 4 file:
1. **Versi `SPIRIT_COVENANT_BLUEPRINT.md` (baris 30–42):**
   - Setting: Dunia fantasy **medieval** bernama **Vaelthorn** (kastil kuno, kerajaan yang takut kekuatan Raku, kultus).
   - Asal kontrak: Raku **secara tidak sengaja membuat kontrak dengan kelima spirit sekaligus**, tersegel di **Crystal of Covenant**.
2. **Versi `docs/Lore.md` (baris 8–10, 28–31, 38–45):**
   - Setting/Tone: Petualangan santai **slice-of-life**, bukan misi menyelamatkan dunia.
   - Asal kontrak: Raku **tidak** mendapat 5 Spirit sekaligus; kontrak didapat **satu per satu** lewat **5 Chapter Prolog**, dimulai dari Chapter 1 (pertemuan dengan Raookami).
   - Media kontrak: **Kalung peninggalan keluarga milik Raku**, bukan Crystal of Covenant.
3. **Versi `docs/prolog chapter 1 raookami id.md` (baris 1–13) & `jp.md` (baris 1–13):**
   - Setting: **Kantor Detektif (Tantei Jimusho)** bernuansa **Jepang tradisional** (meja rendah, lampu kertas, pintu geser / *hikido*), dengan gaya kasus episodik ala *Detective Conan* (baris 198 di `id.md`).
   - Status Tim: Meskipun nama filenya `prolog chapter 1 raookami...`, isinya berjudul `CHAPTER 1 (KANTOR DETEKTIF ARC)` dan baris 6 `id.md` menegaskan **kantor sudah berdiri dan kelima Spirit sudah bergabung sebelumnya** (bertentangan dengan `Lore.md` yang menyatakan Chapter 1 adalah prolog pertemuan & pembentukan kepercayaan pertama dengan Raookami).
   - Media kontrak: Menggunakan **kalung** (Scene 5: Momen Kalung), konsisten dengan `Lore.md` tetapi bertentangan dengan Crystal of Covenant di Blueprint.

---

## 4. Ketidakkonsistenan Dokumentasi, Roadmap, Kanban, & Script Otomasi

### 4.1 Status Checklist Roadmap (`[x]`) Tidak Sesuai Kondisi Kode
- `docs/SPIRIT_COVENANT_ROADMAP.md` (baris 62, `fase1.enemy_types` `[x]`): Memiliki catatan bahwa `enemy.gd` masih memakai flag debug `TESTING_TANKY_ENEMY`, padahal flag tersebut **sudah tidak ada** di `scenes/enemy.gd`; selain itu diferensiasi antar tipe musuh baru sebatas angka stat (belum ada diferensiasi visual/behavior).
- `docs/SPIRIT_COVENANT_ROADMAP.md` (baris 63, `fase1.object_pooling` `[x]`): Mencantumkan pooling untuk **enemy, projectile, dan damage number popup**. Faktanya di kode:
  - Hanya **enemy** yang di-pool (`battle.gd` baris 62, 458).
  - **Projectile** di `spirit.gd` (baris 354–361) masih di-`queue_free()`.
  - **Damage number popup** belum diimplementasikan sama sekali (bahkan masih berstatus `[ ]` di Roadmap baris 72, `fase1.damage_popup`).
- `docs/SPIRIT_COVENANT_ROADMAP.md` (baris 37, `fase0.stage_config` `[x]`): Menyebut path `data/stage_01.tres`, padahal lokasi aktualnya adalah `data/chapter/1/stage_01.tres`.

### 4.2 Ketidaksinkronan Script Otomasi (`sync_docs.ps1` vs `update_state.ps1` vs `WORKFLOW.md`)
- **`sync_docs.ps1` vs `update_state.ps1`:** Ada 2 script berbeda yang sama-sama menulis `docs/CURRENT_STATE.md` dengan format header dan struktur section yang bertolak belakang (`sync_docs.ps1` baris 174–189 memakai `[LOG] GIT TERAKHIR`, `[NEXT] TASK AKTIF`, `[SYNC] HASIL`; `update_state.ps1` baris 42–53 memakai `[LOG] BARU SAJA DIKERJAKAN`, `[NEXT] 3 TASKS BERIKUTNYA`, `[INFO] CATATAN PENTING`).
- **`sync_docs.ps1` mengabaikan ID tag yang dibuatnya sendiri:** `Sync-RoadmapToKanban` (baris 81) menyisipkan `(ID: $($item.Id))` ke deskripsi task Kanban, tetapi `Get-SafeMatch` (baris 95–113) tidak membaca ID tersebut dan hanya mengandalkan kemiripan token (`score >= 2`), yang rentan salah cocok jika ada dua task dengan kata kunci mirip.
- **`sync_docs.ps1` filter `unplanned` terlalu longgar:** Baris 154 (`$roadmapText -notmatch [regex]::Escape($task.title)`) mengecek seluruh teks dokumen Roadmap, bukan hanya daftar item/unplanned.
- **`docs/WORKFLOW.md` terpotong:** Berakhir mendadak di baris 17 pada heading `## Alur Otomasi (Dua Arah)` tanpa isi lanjutan.
- **Konflik Hook Git (`.githooks/post-commit.ps1`):** Menjalankan `sync_docs.ps1` **setelah** commit selesai, yang otomatis memodifikasi file ter-track (`docs/CURRENT_STATE.md`, `docs/SPIRIT_COVENANT_ROADMAP.md`, `kanban_tasks_data.kanban`) sehingga working tree langsung berstatus dirty setelah setiap commit.
- **`docs/CURRENT_STATE.md`:** Baris 5 masih menyimpan pesan commit percobaan (`- feat: setup full automation & auto-populate kanban - test error gara gara claude - test hook otomatis`).

### 4.3 Ketidakkonsistenan Data di `kanban_tasks_data.kanban`
- **Orphan Task:** Task dengan UUID `7869ef97-e2f2-40fa-bcee-b9680509d2ca` berjudul `"New task"` (baris 106–111) ada di array `"tasks"`, tetapi UUID-nya **tidak terdaftar** di stage mana pun (`Todo`, `Doing`, maupun `Done`).
- **Task Done Tidak Sesuai Implementasi:** Task `f224db1b-80ec-45df-a93a-c7f72b73088b` (`Object Pooling (Enemy & Projectile)`) ada di kolom `Done` dan deskripsinya meminta pembuatan script `object_pool.gd` + pooling musuh/projectile, padahal `object_pool.gd` tidak ada dan projectile belum di-pool. Task `fc205c68-4f69-4b42-905c-6a3428c9ed31` (`Enemy Type Differentiation`) mendeskripsikan penggunaan `match` statement di `enemy.gd`, sedangkan implementasi aktual beralih ke `EnemyData` `.tres`.

---

## 5. Path Rusak, Aset Hilang, & Potensi Dead Code

### 5.1 Referensi Path Scene / File yang Rusak atau Tidak Ada
- `tests/sentry_test.tscn` (baris 3): Merujuk `path="res://scenes/sentry_test.gd"`, padahal script berada di **`res://tests/sentry_test.gd`** (dan `tests/sentry_test.gd.uid` memiliki `uid://vwhc0dmawcvv`, berbeda dengan `uid://mynvl7igwo4e` di `.tscn`).
- `data/spirits/*/*.tres` merujuk file PNG yang **tidak ada di repository**:
  - `data/spirits/koyuuki/koyuuki_data.tres` (baris 16): `res://assets/spirites/characters/koyuuki/koyuuki.png` (folder `koyuuki/` tidak ada).
  - `data/spirits/kuma/kuma_data.tres` (baris 16): `res://assets/spirites/characters/kuma/kuma.png` (folder `kuma/` tidak ada).
  - `data/spirits/ratora/ratora_data.tres` (baris 15): `res://assets/spirites/characters/ratora/ratora.png` (folder `ratora/` tidak ada).
  - `data/spirits/yoshiki/yoshiki_data.tres` (baris 15): `res://assets/spirites/characters/yoshiki/yoshiki.png` (folder `yoshiki/` tidak ada).
- `main.tscn`: Masih ada di root sebagai scene legacy (`raookami.png`) sementara `project.godot` (baris 14) menjalankan `uid://cwdgv27ajdfgw` (`scenes/battle.tscn`).

### 5.2 Node Sisa / Tidak Terpakai di Scene & Potensi Dead Code
- `scenes/battle.tscn` (baris 20–35): Terdapat node `GDCubismUserModel` statis di luar layar (`position = Vector2(747.14966, 1467.0776)`), yang tidak dipakai oleh sistem deploy `battle.gd` / `spirit.gd` (dan bertentangan dengan klaim baseline performa `1 model Live2D aktif` di Roadmap baris 39).
- **Variabel / kode tidak terpakai (berisiko memicu blokir `.githooks/pre-commit.ps1` via `check_deadcode.ps1`):**
  - `scenes/battle.gd` (baris 41 & 60): `max_enemies` dan `enemies_spawned` tidak pernah dipakai untuk logika spawn/gameplay.
  - `scenes/battle.gd` (baris 21–22): `@export var spirit_roster` dan `enemy_roster` diletakkan di bawah blok komentar `# 2. CONSTANTS`, bukan `# 3. EXPORTED VARIABLES`.
  - `scenes/enemy.gd` (baris 23 & 27): `_initialized` di-set `true` di `_ready()`, tetapi tidak pernah dibaca di mana pun.
  - `scenes/spirit.gd` (baris 44–45, 168–179): `skill_bar_bg` dan `skill_bar_fill` dibuat tetapi tidak pernah di-update.