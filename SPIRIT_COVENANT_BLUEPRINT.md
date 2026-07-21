# SPIRIT COVENANT — GAME BLUEPRINT

**Version:** 1.4  
**Engine:** Godot 4.7 (GDScript)  
**Art Style:** Anime 2D ilustrasi (CSP + Live2D Cubism)  
**Platform Target:** Windows (.exe) → Android (.apk)  
**Genre:** Tower Defense + Collector RPG  
**Developer:** Solo dev (Raooraku)

---

## 1. GAME OVERVIEW

### Tagline

> _"Five contracts. One crystal. One master who refuses to lose."_

### Elevator Pitch

Spirit Covenant adalah tower defense 2D pixel art di mana pemain berperan sebagai **Raku**, seorang Master yang memiliki kontrak dengan 5 Spirit hewan. Musuh datang dalam gelombang untuk menghancurkan **Crystal of Covenant** — kristal yang mengikat semua kontrak Raku dengan para Spirit. Pemain menempatkan Spirit di grid map, mengatur komposisi tim, dan menggunakan skill aktif di waktu yang tepat untuk bertahan.

### Core Fantasy

Feeling yang ingin dicapai: _"Aku punya tim yang loyal, dan bersama mereka aku tidak bisa kalah."_

---

## 2. LORE & WORLD

### Setting

Dunia **Vaelthorn** — dunia fantasy medieval dengan hutan liar, kastil kuno, dan alam spirit yang overlap dengan dunia manusia di tempat-tempat tertentu. Spirit lahir dari elemen alam dan bisa membuat kontrak dengan manusia yang "dipilih."

### Backstory

Raku adalah seorang Master muda yang secara tidak sengaja membuat kontrak dengan kelima spirit sekaligus — sesuatu yang dianggap mustahil. Kontrak itu tersegel dalam **Crystal of Covenant**, sebuah artefak langka yang kini jadi incaran berbagai pihak: kultus yang ingin menguasai spirit, kerajaan yang takut kekuatan Raku, dan entitas dari alam spirit yang merasa kontraknya "melanggar aturan."

### Crystal of Covenant

- Fisik: kristal ungu-biru, melayang, ukuran kepalan tangan
- Fungsi lore: jangkar ikatan Raku ↔ 5 Spirit. Kalau hancur, semua spirit kembali ke alam mereka
- Fungsi gameplay: **objective yang harus dilindungi** di setiap stage. HP kristal = nyawa stage

---

## 3. KARAKTER

### RAKU (Master / Summoner)

| Atribut        | Detail                                                                                       |
| -------------- | -------------------------------------------------------------------------------------------- |
| Ras            | Human                                                                                        |
| Usia           | ~20 tahun                                                                                    |
| Tinggi         | —                                                                                            |
| Elemen         | — (akses ke semua elemen via Spirit)                                                         |
| Role Gameplay  | Passive summoner — tidak bertarung langsung, tapi bisa aktifkan skill Spirit dari jarak jauh |
| Kepribadian    | Tenang, misterius, perhatian tapi ansos. Senyum sambil mikir. Kretek jari.                   |
| Penampilan     | Rambut hitam, mata biru, dominan outfit hitam                                                |
| Kemampuan Unik | **Covenant Link** — bisa boost satu Spirit pilihan untuk durasi tertentu (cooldown panjang)  |

---

### RAOOKAMI "RAOO" 🐺

| Atribut     | Detail                                                   |
| ----------- | -------------------------------------------------------- |
| Ras         | Spirit Serigala (Husky)                                  |
| Tinggi      | 145 cm                                                   |
| Elemen      | Kegelapan                                                |
| Role        | **Frontliner / Vanguard**                                |
| Kepribadian | Ceria, usil, sangat lengket ke Raku. Tidak suka Koyuuki. |
| Suka        | Daging, salju, Raku                                      |
| Tidak Suka  | Koyuuki                                                  |

**Stats:**

- HP: ⭐⭐⭐⭐ (tinggi)
- ATK: ⭐⭐⭐ (sedang)
- DEF: ⭐⭐⭐ (sedang)
- SPD: ⭐⭐⭐⭐⭐ (sangat cepat)
- Range: Melee

**Skills (pilih 1 dari 3 sebelum battle):**

1. **Shadow Dash** — Dash ke target terdekat, deal damage + stun singkat
2. **Dark Howl** — AoE kegelapan di sekitar dirinya, slow semua musuh dalam radius
3. **Pack Instinct** _(Passive)_ — Setiap kali Raku aktifkan Covenant Link ke Raoo, ATK naik 50% selama 10 detik

**Spirit Form:** Berubah jadi serigala besar — stat semua naik, range sedikit bertambah, aktif via Ultimate

**Alter Ideas:**

- _Winter Raoo_ — outfit salju, elemen es, palette putih-biru
- _Shadow Raoo_ — outfit gelap penuh, elemen kegelapan murni, mata merah menyala

---

### KUMA 🐻‍❄️

| Atribut     | Detail                            |
| ----------- | --------------------------------- |
| Ras         | Spirit Beruang Putih              |
| Tinggi      | 150 cm                            |
| Elemen      | Es / Psikik                       |
| Role        | **Defender / Support**            |
| Kepribadian | Dewasa, kalem, vibes kakak tertua |
| Suka        | Makanan manis dingin              |
| Tidak Suka  | Makanan pedas                     |

**Stats:**

- HP: ⭐⭐⭐⭐⭐ (paling tinggi)
- ATK: ⭐⭐ (rendah)
- DEF: ⭐⭐⭐⭐⭐ (paling tinggi)
- SPD: ⭐⭐ (lambat)
- Range: Melee (tapi luas)

**Skills (pilih 1 dari 3):**

1. **Memory Seal** — Targeted satu musuh, musuh berhenti sejenak (memory manipulation, disoriented)
2. **Foresight Barrier** — Prediksi serangan berikutnya, DEF semua Spirit dalam radius naik untuk 1 hit
3. **Glacier Wall** _(Passive)_ — Setiap 30 detik, spawn es kecil di depannya yang memperlambat musuh lewat

**Spirit Form:** Beruang raksasa — jadi immovable tank, DEF sangat tinggi, otomatis taunt semua musuh dalam range

**Alter Ideas:**

- _Dream Kuma_ — elemen psikik murni, palette ungu-pink, mata berpendar
- _Ancient Kuma_ — armor es kuno, vibe bijak, palette biru tua

---

### YOSHIKI "SHIKI" 🦈

| Atribut     | Detail                        |
| ----------- | ----------------------------- |
| Ras         | Spirit Hiu                    |
| Tinggi      | 150 cm                        |
| Elemen      | Air / Es                      |
| Role        | **Assassin / Ranged DPS**     |
| Kepribadian | Pendiam, cool, vibes assassin |
| Suka        | Makanan laut, hujan           |
| Tidak Suka  | Makanan pahit                 |

**Stats:**

- HP: ⭐⭐ (rendah)
- ATK: ⭐⭐⭐⭐⭐ (paling tinggi)
- DEF: ⭐ (sangat rendah)
- SPD: ⭐⭐⭐⭐ (cepat)
- Range: Medium-Long (bisa target musuh yang jauh)

**Skills (pilih 1 dari 3):**

1. **Camouflage** — Invisible selama 5 detik, ATK pertama setelah invisible = critical
2. **Tidal Strike** — Projectile air yang menembus beberapa musuh sekaligus (pierce)
3. **Frost Current** _(Passive)_ — Setiap serangan punya 20% chance freeze target singkat

**Spirit Form:** Hiu raksasa semi-transparan — melayang, bisa menembus semua musuh dalam satu jalur (AoE linear)

**Alter Ideas:**

- _Storm Shiki_ — elemen petir + air, palette kuning-biru gelap
- _Phantom Shiki_ — full camouflage vibes, palette abu-abu transparan

---

### RATORA "TORA" 🐯

| Atribut     | Detail                   |
| ----------- | ------------------------ |
| Ras         | Spirit Harimau           |
| Tinggi      | 145 cm                   |
| Elemen      | Petir + Api              |
| Role        | **Main DPS / Berserker** |
| Kepribadian | Tsundere, hiperaktif     |
| Suka        | Daging, salju, Raku      |
| Tidak Suka  | Sayuran                  |

**Stats:**

- HP: ⭐⭐⭐ (sedang)
- ATK: ⭐⭐⭐⭐⭐ (sangat tinggi)
- DEF: ⭐⭐ (rendah)
- SPD: ⭐⭐⭐⭐ (cepat)
- Range: Melee (tapi AoE kecil)

**Skills (pilih 1 dari 3):**

1. **Thunder Claw** — Serangan petir AoE di sekitarnya, stun semua musuh terkena
2. **Flame Rush** — Dash panjang melewati garis musuh, meninggalkan jejak api (damage over time)
3. **Berserk Mode** _(Toggle)_ — ATK naik drastis tapi DEF turun, HP terus berkurang perlahan. Toggle off untuk berhenti

**Spirit Form:** Harimau raksasa berlistrik — kombinasi api + petir, serangan AOE sangat besar

**Alter Ideas:**

- _Inferno Tora_ — full api, palette merah-oranye, lebih agresif
- _Thunder King Tora_ — full petir, palette kuning-putih, lebih elegan

---

### KOYUUKI "UKI" 🦇

| Atribut     | Detail                           |
| ----------- | -------------------------------- |
| Ras         | Spirit Kelelawar Vampir          |
| Tinggi      | 148 cm                           |
| Elemen      | Angin / Darah                    |
| Role        | **Support / Healer / Disruptor** |
| Kepribadian | Usil, fleksibel, agak mysterious |
| Suka        | Buah-buahan, malam               |
| Tidak Suka  | Makanan pahit                    |
| Catatan     | Kurang akur dengan Raookami      |

**Stats:**

- HP: ⭐⭐⭐ (sedang)
- ATK: ⭐⭐⭐ (sedang)
- DEF: ⭐⭐ (rendah)
- SPD: ⭐⭐⭐⭐⭐ (sangat cepat, bisa terbang)
- Range: Medium (terbang = bisa skip obstacle)

**Skills (pilih 1 dari 3):**

1. **Hypnosis** — Target satu musuh kuat, musuh berhenti menyerang selama durasi
2. **Blood Drain** — Serang musuh dan heal Spirit terdekat sebesar % damage yang diberikan
3. **Ultrasound Pulse** — AoE suara yang disrupt semua musuh dalam radius besar (damage kecil, tapi semua musuh slow + confused)

**Spirit Form:** Kelelawar raksasa — terbang bebas di seluruh map, bisa heal semua Spirit sekaligus

**Alter Ideas:**

- _Night Bloom Uki_ — elemen bunga malam + racun, palette ungu gelap-hijau
- _Crimson Uki_ — full blood manipulation, palette merah gelap, lebih dark

---

## 4. GAMEPLAY MECHANICS

### 4.1 Core Loop

```
Lobby → Pilih Stage → Pilih Tim (max 4 Spirit) →
Pilih Skill per Spirit → Battle →
Reward (XP, mata uang, item) → Kembali ke Lobby
```

### 4.2 Battle System

**Map:**

- Grid-based, musuh jalan di jalur yang sudah ditentukan (seperti Arknights)
- Pemain menempatkan Spirit di tile kosong (bukan di jalur musuh)
- Crystal of Covenant ada di ujung jalur

> 🗺️ **PRINSIP STAGE DESIGN: MULTI-SOLUTION**
> Setiap stage harus bisa di-clear dengan **minimal 2 komposisi tim berbeda**.
> Tidak ada stage yang hanya bisa di-clear dengan karakter spesifik.
> Contoh desain stage yang benar:
>
> - Stage dengan musuh swarm (banyak, lemah) → bisa pakai Ratora AoE ATAU Yoshiki pierce ATAU Koyuuki Ultrasound
> - Stage dengan musuh tanky (sedikit, kuat) → bisa pakai Yoshiki single target ATAU Raookami Spirit Form ATAU Kuma freeze stall
> - Stage dengan musuh flying → Koyuuki jelas strong, tapi Yoshiki ranged juga bisa — pemain yang tidak punya Koyuuki tidak terhukum

**Penempatan Spirit:**

- Setiap Spirit punya "cost" untuk ditempatkan
- Cost regenerate otomatis seiring waktu
- Spirit bisa ditarik kembali (retreat) dengan mengorbankan sebagian HP mereka

**Combat:**

- Spirit otomatis menyerang musuh dalam range-nya
- Pemain bisa aktifkan skill aktif manual dengan tap/klik
- Ultimate (Spirit Form) punya gauge yang terisi dari damage diterima/diberikan

**Musuh:**

- Bergerak mengikuti jalur menuju Crystal
- Ada berbagai tipe: cepat, tanky, flying, armored, dll
- Boss muncul tiap 5 stage

> ⚠️ **PRINSIP SCALING MUSUH (F2P COVENANT)**
>
> - HP musuh **flat per stage** — tidak pernah naik secara arbitrary hanya karena pemain sudah lama main
> - Kesulitan naik dari **variasi dan kombinasi tipe musuh**, bukan dari inflasi stat
> - Stage lanjutan lebih sulit karena **mekanik baru** (musuh kebal elemen tertentu, jalur bercabang, dll) — bukan karena HP musuh x10
> - Alter baru **tidak membuat stage lama terasa mudah secara tidak wajar** — balance dijaga dari sisi enemy design, bukan dari sisi power creep karakter
> - F2P dengan Spirit base level max **selalu bisa clear semua story stage** — alter hanya memberi cara berbeda, bukan syarat wajib

**Kondisi Menang/Kalah:**

- Menang: semua gelombang musuh dikalahkan
- Kalah: Crystal of Covenant HP = 0

### 4.3 Sistem Skill

Sebelum battle, tiap Spirit bisa equip **1 dari 3 skill** yang tersedia:

- Skill 1: selalu tersedia dari awal (starter skill)
- Skill 2: unlock di level Spirit 10
- Skill 3: unlock di level Spirit 20

### 4.4 Sistem Alter

> 🎯 **Filosofi Alter: Horizontal, Bukan Vertikal**
> Alter **tidak boleh lebih kuat** dari base version. Alter adalah **cara berbeda bermain** karakter yang sama.
> Pemain yang punya base Raookami saja tetap setara kekuatannya dengan pemain yang punya semua alter Raookami.

- Alter = versi alternatif Spirit dengan elemen/outfit/role berbeda tiap season
- Alter punya **skill set unik** yang berbeda total dari base — bukan upgrade, tapi toolkit alternatif
- Secara gameplay, alter adalah "karakter terpisah" tapi berbagi lore yang sama
- **Alter tidak boleh jadi solusi wajib** untuk stage manapun — selalu ada path clear tanpa alter
- Cara dapat alter: gacha (in-game currency, no real money untuk MVP)
- Setiap alter season hadir dengan **story pendek eksklusif** — bukan cuma reskin

**Contoh Prinsip Alter yang Benar:**
| Spirit | Base Role | Alter Role | Yang Berubah |
|---|---|---|---|
| Raookami | Frontliner/Vanguard | Support/Buffer | Dari damage ke buff tim |
| Kuma | Defender | DPS Slow | Dari tank diam ke freezer agresif |
| Yoshiki | Assassin | Crowd Control | Dari single target ke disruptor |
| Ratora | Berserker | Sniper | Dari melee AoE ke long-range burst |
| Koyuuki | Healer | Debuffer | Dari sustain ke offensive support |

### 4.5 Roguelite Mode — "Covenant Run"

Mode sampingan yang bisa dimainkan kapan saja, tanpa stamina, tanpa tekanan.

**Konsep:**

- Pemain mulai dari awal dengan Spirit level 1
- Tiap stage clear, dapat **random buff** pilih 1 dari 3 (mirip HSR Simulated Universe)
- Run berakhir kalau Crystal hancur atau semua stage selesai
- Setiap run **berbeda** karena buff pool dan urutan stage diacak

**Reward:**

- Ether Fragment dan Spirit Shard dari tiap run
- Milestone reward untuk run yang selesai sampai akhir
- **Tidak ada punishment** kalau run gagal — reward tetap dihitung sampai stage terakhir yang berhasil

**Kenapa ini penting untuk retensi:**

- Pemain yang sudah clear semua story stage masih punya konten untuk dimainkan
- Bisa main 10 menit atau 1 jam — fleksibel
- Setiap run terasa segar karena kombinasi buff berbeda

---

### 4.6 Daily & Weekly System

> 🗓️ **Filosofi: Main karena mau, bukan karena takut rugi.**

**Daily Quest (pilih 3 dari 5 tersedia):**

- Clear 2 stage apapun
- Aktifkan skill 10 kali dalam battle
- Selesaikan 1 Covenant Run
- Interaksi bond dengan Spirit manapun
- Clear 1 stage dengan full HP Crystal

**Aturan penting:**

- ✅ Tidak ada streak punishment — skip sehari tidak kehilangan apapun krusial
- ✅ Daily reset jam 5 pagi (atau bisa diatur di settings)
- ✅ Quest mingguan lebih generous dari daily — sekali clear banyak reward
- ❌ Tidak ada "login 30 hari berturut-turut atau bonus hilang"
- ❌ Tidak ada stamina/energy yang bikin pemain harus buka app setiap beberapa jam

---

### 4.8 Leveling System

| Item         | Cara Level Up                                  |
| ------------ | ---------------------------------------------- |
| Spirit Level | XP dari battle                                 |
| Skill Level  | Material dari stage tertentu                   |
| Bond Level   | Interaksi di Lobby (tap karakter, beri hadiah) |

**Bond Level** membuka: dialog eksklusif, artwork baru, bonus stat kecil

---

### 4.9 F2P Economy System

> 💎 **Filosofi: Pemain harus merasa kaya, bukan kekurangan.**

**Currency:**
| Currency | Nama | Cara Dapat |
|---|---|---|
| Premium | Covenant Crystal | Clear stage baru, event, login, achievement |
| Gacha ticket | Spirit Shard | Daily quest, weekly mission, story clear |
| Upgrade material | Ether Fragment | Battle drop, stage reward |

**Gacha Rate:**

- Base rate alter: **3%** (lebih tinggi dari rata-rata gacha)
- **Soft pity** mulai di pull ke-60 (rate naik bertahap)
- **Hard pity** di pull ke-80 (dijamin dapat alter)
- **Rate-up**: alter season aktif punya 50/50 dengan alter lain di pool
- Tidak ada sistem "featured banner tanpa pity carry-over" — pity selalu terbawa ke banner berikutnya

**Free Currency Income (estimasi per minggu):**

- Daily login 7 hari: ~10 Spirit Shard
- Weekly mission clear: ~20 Spirit Shard
- Story stage clear (first time): ~30 Covenant Crystal per stage baru
- Event participation: ~40-60 Spirit Shard per event

> Target: F2P bisa gacha **1x per 2 minggu** tanpa grinding berat. Pemain aktif bisa dapat **1 alter per 1-2 bulan** secara gratis.

---

## 5. UI/UX STRUCTURE

### 5.1 Layar Utama

```
[HOME SCREEN]
├── Battle (pilih stage)
├── Spirit (manajemen karakter)
├── Gacha (summon alter)
├── Shop (beli currency/item)
└── Settings
```

### 5.2 Battle UI

```
[ATAS]   HP Crystal of Covenant | Gelombang ke-X/Y | Timer

[TENGAH] Map Grid + Spirit + Musuh

[BAWAH]  Cost Bar | [Portrait Spirit 1][2][3][4] + skill button
         [Ultimate Button jika gauge penuh]
```

### 5.3 Spirit Menu

- Portrait besar karakter
- Stat panel
- Skill selector (pilih 1 dari 3)
- Bond level + dialog
- Equip/upgrade

---

## 6. ART DIRECTION

### 6.1 Art Pipeline

```
Clip Studio Paint (CSP)
    → Ilustrasi + layer separation
    → Export PNG per part (PSD)
        ↓
Live2D Cubism 5.0
    → Rigging (mesh + deformer)
    → Animasi (idle, attack, skill, dll)
    → Export .moc3 + .model3.json
        ↓
Live2D Cubism 5.0
    → Rigging (mesh + deformer)
    → Animasi (idle, attack, skill, dll)
    → Export .moc3 + .model3.json
        ↓
Godot 4.7
    → Import via GDCubism (GDExtension, compile manual dari source)
    → Integrate ke battle scene & UI
```

**Kenapa Live2D + Godot?**

- Live2D = standar industri anime game (Arknights, Blue Archive, dll) — kualitas animasi jauh lebih ekspresif
- Godot tidak punya plugin Live2D resmi — dukungan datang lewat **GDCubism**, plugin GDExtension tidak resmi yang harus di-compile manual dari source (sudah berhasil dilakukan, lihat catatan compile di section 9)
- Godot ringan, open-source, tidak ada biaya royalti — cocok untuk solo dev jangka panjang
- Asset Live2D (.moc3, .model3.json, .motion3.json) portable lintas engine — tidak terikat ke satu engine tertentu
- Rive tidak bisa dicapai karena keterbatasan akses tools

---

### 6.2 Spec Aset per Kategori

| Elemen                   | Format                    | Resolusi          | Catatan                                      |
| ------------------------ | ------------------------- | ----------------- | -------------------------------------------- |
| Karakter battle (Live2D) | .moc3 + .model3.json      | —                 | Rigged di Cubism 5.0, import via SDK         |
| Karakter portrait (UI)   | PNG                       | 512x512 px        | Ilustrasi full dari CSP, static              |
| Karakter chibi/icon      | PNG                       | 128x128 px        | Versi mini untuk roster/tim                  |
| Tile map (background)    | PNG                       | 64x64 px per tile | Digambar di CSP                              |
| Enemy sprite             | PNG / .moc3               | 128x128 px        | Simple L2D rig atau frame-by-frame PNG       |
| Boss sprite              | PNG / .moc3               | 256x256 px        | Minimal idle + attack animation via L2D      |
| Crystal of Covenant      | PNG sequence / Godot anim | 128x128 px        | Animasi berpendar via AnimationPlayer/shader |
| UI elements              | PNG                       | Fleksibel         | Button, frame, icon                          |

---

### 6.3 Layer Separation Guide (CSP → Live2D)

Untuk tiap karakter, pisahkan layer minimal:

```
📁 [Nama Spirit]
├── 👁 hair_front        ← rambut depan (nutupin muka)
├── 👁 head              ← kepala + muka
├── 👁 hair_back         ← rambut belakang
├── 👁 ear / tail        ← telinga/ekor kalau ada
├── 👁 body              ← badan + baju
├── 👁 arm_right         ← lengan kanan
├── 👁 arm_left          ← lengan kiri
├── 👁 hand_right        ← tangan kanan (opsional terpisah)
├── 👁 hand_left         ← tangan kiri (opsional terpisah)
├── 👁 leg / lower_body  ← kaki / bagian bawah
└── 👁 accessory         ← item tambahan (senjata, ornamen)
```

> 💡 **Tips CSP:** Tidak harus sempurna — area yang tertutup layer lain tidak perlu digambar lengkap. Cukup area yang terlihat saat bergerak.

---

### 6.4 Animasi Per Karakter (minimum via Live2D Cubism)

| Animasi        | Durasi     | Keterangan                                                                |
| -------------- | ---------- | ------------------------------------------------------------------------- |
| idle           | loop       | Napas pelan, sedikit goyang — motion di Cubism                            |
| idle_combat    | loop       | Stance siap tempur                                                        |
| attack         | ~0.5 detik | Gerakan serang, kembali ke idle                                           |
| skill_activate | ~0.8 detik | Efek skill muncul — bisa dikombinasikan dengan efek partikel/shader Godot |
| hit            | ~0.3 detik | Reaksi kena serangan                                                      |
| retreat        | ~0.5 detik | Animasi ditarik keluar map                                                |
| spirit_form    | ~1 detik   | Transform ke Spirit Form                                                  |

> 💡 **Workflow L2D → Godot:** Setiap animasi dibuat sebagai motion terpisah di Cubism (.motion3.json), lalu direferensikan lewat blok `"Motions"` di `model3.json` (perhatikan: kadang hilang saat export dari Cubism Editor, cek manual kalau motion tidak terbaca). Motion dikontrol via node `GDCubismUserModel` di GDScript — pakai `start_motion_loop()` untuk animasi yang perlu loop mulus tanpa jeda (idle, idle_combat), dan `start_motion()` untuk animasi sekali jalan (attack, hit, skill_activate).

---

### 6.5 Palette Arah

- **UI:** Dark navy + gold accent (elegan, fantasy)
- **Raookami:** Hitam, abu, aksen merah/ungu gelap
- **Kuma:** Putih, biru muda, aksen silver
- **Yoshiki:** Biru teal, abu-abu gelap, aksen cyan
- **Ratora:** Oranye, kuning, aksen merah petir
- **Koyuuki:** Ungu gelap, hitam, aksen pink/teal

---

## 7. AUDIO DIRECTION

- BGM: Fantasy orchestral + synthwave ringan (vibe HSR/Arknights)
- SFX: Setiap elemen punya sound karakter (petir = crack tajam, air = splash lembut, dll)
- Voice: Opsional di versi awal — bisa pakai text + sound cue dulu

---

## 8. DEVELOPMENT ROADMAP

### FASE 0 — Setup & Belajar (Minggu 1-2)

- [x] Install Godot 4.7 + setup project 2D
- [x] Setup toolchain compile GDCubism (MSVC Build Tools, SCons, Cubism SDK for Native) — **selesai, GDCubism ter-compile dari source dan aktif**
- [ ] Ikuti tutorial Godot basic (Node, Scene, GDScript dasar) — sebagian besar sudah dikuasai dari implementasi battle.gd/enemy.gd/spirit.gd yang sudah ada
- [ ] Ikuti tutorial Live2D Cubism basic (mesh, deformer, rigging sederhana)
- [ ] Di CSP: gambar Raookami dengan layer separation (ikuti panduan section 6.3)
- [ ] Import PNG parts ke Cubism 5.0, buat animasi idle pertama sebagai latihan
- [x] Import model L2D ke Godot via GDCubism — **Raookami idle motion sudah berjalan loop mulus di battle scene**

### FASE 1 — Prototype Gameplay (Minggu 3-6)

- [x] Buat map grid sederhana di Godot (TileMap)
- [x] Spawn musuh basic yang berjalan lewat waypoint (enemy.gd)
- [x] Tempatkan Spirit di grid (spirit.gd, deploy dari roster)
- [x] Spirit otomatis serang musuh dalam range (block mechanic melee + ranged sudah jalan)
- [x] Crystal HP yang berkurang kalau musuh sampai ujung jalur
- [ ] Kondisi menang/kalah — cek apakah sudah lengkap atau masih perlu di-polish

> ⚠️ Tujuan Fase 1: **game bisa dimainkan**, belum harus bagus. Live2D untuk Raookami sudah lebih maju dari rencana awal (biasanya diintegrasikan di Fase 2) — boleh lanjut karakter lain kalau momentum masih ada, atau fokus dulu ke gameplay loop sisanya.

### FASE 2 — Content & Polish (Minggu 7-12)

- [ ] Tambah semua 5 Spirit dengan stat berbeda
- [ ] Sistem skill (pilih 1 dari 3)
- [ ] 5 stage pertama dengan layout jalur berbeda
- [ ] 1 Boss enemy
- [ ] Basic UI (HP crystal, wave counter, cost bar)
- [ ] Semua 5 karakter: layer separation di CSP selesai
- [ ] Semua 5 karakter: animasi idle + attack di Live2D Cubism 5.0 selesai
- [x] GDCubism terintegrasi di Godot — Raookami model sudah berjalan in-game, tinggal 4 karakter lagi
- [ ] BGM + SFX basic

### FASE 3 — Sistem Lengkap (Bulan 4-6)

- [ ] Sistem leveling Spirit
- [ ] Sistem Bond
- [ ] Gacha (in-game currency)
- [ ] 3 Alter pertama
- [ ] **Chapter 1: 10 stage** (revisi dari "15 stage" — struktur dipecah per-chapter, lihat Roadmap Fase 4. Chapter 2+ menyusul di update berikutnya, bukan sekaligus di rilis pertama)
- [ ] Spirit Form / Ultimate
- [ ] Story mode basic (dialog sederhana antar stage)

### FASE 4 — Android & Release (Bulan 7+)

- [ ] Setup export preset Android di Godot (Android Build Template + Export)
- [ ] UI responsif untuk layar HP (Godot Control node anchor/container)
- [ ] Testing di device
- [ ] Polish & bug fix
- [ ] Soft release (itch.io / teman-teman dulu)

---

## 9. FILE STRUCTURE (Godot Project)

```
spirit-covenant/
├── assets/
│   ├── spirites/
│   │   └── characters/
│   │       ├── raookami/
│   │       │   ├── raookami_idle.moc3
│   │       │   ├── raookami_idle.model3.json
│   │       │   ├── raookami_idle.motion3.json
│   │       │   ├── raookami_idle.cdi3.json
│   │       │   └── raookami_idle.2048/     ← texture atlas
│   │       ├── kuma/
│   │       ├── yoshiki/
│   │       ├── ratora/
│   │       └── koyuuki/
│   ├── enemies/
│   ├── audio/
│   │   ├── bgm/
│   │   └── sfx/
│   ├── fonts/
│   └── tiles/
├── addons/
│   └── gd_cubism/                ← plugin GDExtension, hasil compile manual
├── scenes/
│   ├── battle.tscn
│   ├── battle.gd
│   ├── enemy.gd
│   ├── spirit.gd
│   └── ui/
├── data/                          ← resource/JSON: stage config, spirit roster, skill data
└── project.godot
```

> Catatan: GDCubism bukan plugin siap-pakai dari Asset Library — di-compile manual dari source (`github.com/MizunagiKB/gd_cubism`) memakai SCons + MSVC Build Tools + Cubism SDK for Native (R4_1, bukan versi terbaru — versi terbaru sempat gagal link karena SDK belum menyediakan lib untuk toolset MSVC terbaru). Kalau perlu compile ulang di mesin lain, proses ini butuh diulang dari nol.

---

## 10. ENEMY DESIGN

### Tipe Musuh & Counter

| Tipe     | Karakteristik           | Counter Spirit                            | Catatan                           |
| -------- | ----------------------- | ----------------------------------------- | --------------------------------- |
| Grunt    | HP rendah, banyak       | Ratora (AoE), Yoshiki (pierce)            | Cannon fodder, stage awal         |
| Brute    | HP tinggi, lambat       | Kuma (taunt+freeze), Raookami (stun)      | Bikin pemain belajar positioning  |
| Sprinter | HP rendah, sangat cepat | Koyuuki (slow/hypnosis), Raookami (dash)  | Ancaman karena speed, bukan stat  |
| Flyer    | Terbang, skip obstacle  | Koyuuki (range terbang), Yoshiki (ranged) | Tidak bisa diblock melee biasa    |
| Armored  | DEF sangat tinggi       | Yoshiki (armor break), Ratora (petir)     | Butuh penetrasi, bukan raw damage |
| Healer   | Heal teman sekitar      | Prioritas target, Yoshiki/Ratora burst    | Kalau tidak di-kill cepat, sulit  |
| Boss     | Kombinasi semua tipe    | Situasional                               | Muncul tiap 5 stage, punya fase   |

### Prinsip Enemy Scaling (Pengulangan untuk penekanan)

- Stage 1-10: Satu tipe dominan, mudah dipelajari
- Stage 11-20: Dua tipe kombinasi, mulai butuh strategi
- Stage 21+: Kombinasi kompleks + kondisi stage khusus (misalnya tile terbatas)
- **HP tidak pernah naik lebih dari 20% per 10 stage** — kesulitan dari variasi, bukan inflasi

---

## 11. RETENSI & PLAYER EXPERIENCE

### Loop yang Membuat Pemain Betah

```
Hari 1-7    : Pemain belajar karakter, excited sama lore
Minggu 2-4  : Mulai eksperimen komposisi tim, nemu "main strategy" sendiri
Bulan 2+    : Roguelite run jadi ritual, tunggu alter season baru
Long-term   : Bond level naik, dialog baru terbuka, invested sama karakter
```

### Momen "Aha!" yang Harus Ada di Setiap Stage

Setiap stage harus punya **satu momen** di mana pemain merasa cerdas:

- Penempatan Spirit yang tepat di titik choke
- Skill aktif di timing yang pas berbalik keadaan
- Komposisi yang tidak lazim tapi ternyata work

### Anti-Frustrasi Design

- Kalah di stage → langsung bisa retry tanpa penalty
- Tidak ada "stamina habis" yang paksa berhenti main
- Setiap run gagal tetap dapat reward kecil
- Stage sulit selalu ada hint komposisi (bisa di-toggle off untuk pemain veteran)

### Konten yang Tidak Pernah "Habis"

| Konten       | Tipe                           | Replayable?             |
| ------------ | ------------------------------ | ----------------------- |
| Story Stage  | One-time + replay untuk 3-star | Ya (grinding star)      |
| Covenant Run | Roguelite                      | Ya (tiap run beda)      |
| Daily Quest  | Reset harian                   | Ya                      |
| Bond System  | Progresif                      | Sampai max level        |
| Season Event | Tiap bulan baru                | Konten baru tiap season |

---

## 12. REFERENSI GAME

| Game             | Yang diambil                                                | Yang DIHINDARI                                          |
| ---------------- | ----------------------------------------------------------- | ------------------------------------------------------- |
| Arknights        | Tower defense grid, sistem operator, pilih skill            | Power creep alter, update lambat, pity tidak carry-over |
| Honkai Star Rail | Vibe karakter, art direction cute-epic                      | HP inflasi musuh, power creep karakter baru             |
| Konosuba         | Energi bright adventurous, humor                            | —                                                       |
| Nu Carnival      | Intimacy sistem (bond), alter season, cast kecil tapi dalam | —                                                       |
| Hades            | Roguelite loop yang adiktif, run berbeda tiap kali          | —                                                       |

---

## 13. CATATAN PENTING UNTUK AI ASSISTANT

Kalau kamu (AI lain) membaca dokumen ini untuk membantu developer:

1. **Engine:** Godot 4.7 (bukan Unity, bukan Unreal) — gunakan **GDScript**
2. **Art pipeline:** CSP (ilustrasi + layer separation) → **Live2D Cubism 5.0** (rigging + animasi) → Godot (via **GDCubism**, plugin GDExtension tidak resmi yang di-compile manual dari source — bukan tersedia siap-pakai di Asset Library). **Bukan pixel art, bukan Rive.**
3. **Bahasa kode:** GDScript, ikuti konvensi Godot (Node, Scene, Resource, dll)
4. **Prioritas:** Gameplay loop dulu, estetik belakangan
5. **Developer:** Solo dev, sudah ada implementasi battle.gd/enemy.gd/spirit.gd yang jalan (grid, block mechanic melee/ranged, wave/enemy pathfinding), background Python (SORA project), baru saja berhasil compile & integrasikan GDCubism dari nol
6. **Platform:** Windows dulu, Android belakangan via Godot Export Templates (Android)
7. **Jangan** sarankan plugin kompleks yang tidak kompatibel dengan GDCubism — hindari konflik GDExtension
8. **L2D animation dipanggil via GDScript** — gunakan `start_motion_loop()` pada node `GDCubismUserModel` untuk motion yang loop mulus tanpa jeda (bukan `start_motion()` biasa, yang tidak native-loop meskipun motion3.json-nya sudah `"Loop": true`)
9. **Crystal of Covenant** = objective/nyawa stage, jangan diganti konsepnya
10. **5 Spirit** = Raookami, Kuma, Yoshiki, Ratora, Koyuuki — karakter original developer, jangan diubah
11. Setiap Spirit punya **3 skill, pilih 1** sebelum battle — ini core mechanic yang tidak boleh dihilangkan
12. **Alter = horizontal progression** — jangan pernah sarankan alter yang lebih kuat dari base secara stat mentah
13. **Enemy HP flat scaling** — jangan sarankan sistem yang inflate HP musuh per chapter/season
14. **F2P first** — setiap fitur yang disarankan harus bisa dinikmati tanpa spending real money
15. **Roguelite mode (Covenant Run)** = konten replayable tanpa stamina, jangan dihilangkan dari scope
16. **No streak punishment** — daily system tidak boleh menghukum pemain yang skip sehari

---

_Blueprint ini adalah living document — update seiring development berlanjut._  
_Last updated: Juli 2026 — v1.4 (Engine & Pipeline Migration: Unity + Live2D Cubism 5.0 → Godot 4 + GDCubism)_
