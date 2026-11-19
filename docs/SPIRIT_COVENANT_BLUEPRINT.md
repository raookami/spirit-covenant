# SPIRIT COVENANT — GAME BLUEPRINT

**Version:** 2.1  
**Engine:** Godot 4.7 (GDScript)  
**Art Style:** Anime 2D Ilustrasi (CSP + Modular Chibi `Skeleton2D` Godot + Live2D Cubism untuk maskot/ilustrasi spesial)  
**Platform Target:** Windows (.exe) → Android (.apk)  
**Genre:** Tower Defense + Collector RPG  
**Developer:** Solo dev (Raooraku)

---

## 1. GAME OVERVIEW

### Tagline

> _"Five contracts. One crystal. One master who refuses to lose."_

### Elevator Pitch

Spirit Covenant adalah game **Tower Defense 2D bergaya anime** yang memadukan suasana hangat **Kantor Detektif (*Tantei Jimusho*)** dengan pertarungan taktis penuh kejutan. Pemain berperan sebagai **Raku**, seorang Master yang mengikat kontrak dengan **5 Spirit hewan** melalui kalung peninggalan keluarganya. Bersama-sama, mereka menangani kasus-kasus antara **Dunia Atas (Manusia)** dan **Dunia Bawah (Astral/Spirit)** sambil melindungi **Crystal of Covenant** — wujud jangkar energi kontrak mereka di medan pertempuran.

### Core Fantasy

Feeling yang ingin dicapai: _"Di permukaan tampak santai dan sederhana, tetapi penuh strategi cerdas, misteri yang saling terhubung, dan tim loyal yang selalu siap membalikkan keadaan di saat paling genting."_

---

## 2. LORE & WORLD

> Ringkasan visi lore. Detail pengembangan karakter & naskah cerita ada di `docs/Lore.md`, `docs/prolog chapter 1 raookami id.md`, dan `docs/prolog chapter 1 raookami jp.md`.

### Setting & Tone

- **Dunia:** Latar bernuansa modern/tradisional Jepang yang hangat, di mana **Kantor Detektif Spirit Covenant** menjadi jembatan penyelesaian masalah antara **Dunia Atas (Manusia)** dan **Dunia Bawah (Astral/Spirit)**.
- **Tone:** **Slice-of-life, Magic, Adventure** — kasus episodik yang ringan di permukaan, tetapi diam-diam menanam benih misteri yang saling terhubung menjadi *plot twist* besar di cerita lanjutan.

### Alur Cerita & Kalung Kontrak

- **Media Kontrak:** Sebuah **kalung peninggalan keluarga Raku** yang asal-usulnya sengaja dirahasiakan sebagai misteri utama.
- **Prolog (5 Stage Awal):** Raku **tidak** mendapatkan 5 Spirit sekaligus tanpa sebab. Melalui 5 stage awal (sekaligus tutorial gameplay), pemain mengikuti 5 insiden singkat bagaimana Raku mengontrak **Raookami, Kuma, Yoshiki, Ratora, dan Yuki** satu per satu.
- **Chapter 1 ke Atas:** Kantor detektif sudah berdiri penuh dengan kelima Spirit sebagai tim inti yang menyelesaikan berbagai kasus unik.

### Crystal of Covenant

- **Fisik:** Kristal ungu-biru melayang seukuran kepalan tangan yang memancarkan energi kontrak dari kalung Raku saat pertarungan berlangsung.
- **Fungsi Lore:** Jangkar ikatan Raku ↔ 5 Spirit selama menghadapi ancaman di medan kasus.
- **Fungsi Gameplay:** **Objective utama yang harus dilindungi** di setiap stage. HP kristal = nyawa stage.

---

## 3. KARAKTER

### RAKU (Master / Summoner)

| Atribut | Detail |
| --- | --- |
| Ras | Human |
| Usia | ~20 tahun |
| Role Gameplay | Passive summoner — tidak bertarung di tile, tetapi memicu **Covenant Link** saat situasi darurat |
| Kepribadian | Terlihat tenang, misterius, dan suka berdeduksi ("si sok tahu" receh). Di balik topeng *cool*, sebenarnya sering panik; baru benar-benar serius jika Spirit-nya terancam |
| Penampilan | Rambut hitam, mata biru, dominan outfit gelap, memakai kalung kontrak |
| Kemampuan Unik | **Covenant Link** — mekanik *Last Stand* otomatis 1x per battle saat musuh pertama lolos (lihat Section 4.2) |

---

### RINGKASAN ROSTER 5 SPIRIT (STAT BASE LEVEL 1)

| Spirit | Main Class | Elemen (Warna) | Tipe DMG | CP | Block | HP | ATK | Attack Interval | Manifest / Phantasm DEF | Pola Range & Peran |
| --- | --- | --- | --- | :---: | :---: | :---: | :---: | :---: | :---: | --- |
| **Ratora** | **Seer** | **Flare** (Oranye-Emas) | **Phantasm** | 7 | 2 | 520 | 35 | 0.80 dtk | 15 / 10 | Melee **AoE** (tile diri + 3 tile depan) + **Penghasil `CP`** |
| **Raookami** | **Pursuer** | **Umbra** (Ungu Pekat/Merah Gelap) | **Manifest** | 9 | 1 | 800 | 50 | 0.55 dtk | 30 / 20 | Melee Single-Target cepat (1-1: tile diri + 1 tile depan) |
| **Yuki** | **Channeler** | **Veil** (Hijau Mint) | **Phantasm** | 10 | 1* | 500 | 28 | 0.60 dtk | 10 / 25 | Ranged Support / Healer / Disruptor cepat |
| **Kuma** | **Sentinel** | **Rime** (Putih Kristal/Silver) | **Manifest** | 12 | 3 | 1350 | 25 | 1.25 dtk | 60 / 40 | Melee Tank utama penahan jalur (1-1: tile diri + 1 tile depan) |
| **Yoshiki** | **Lurker** | **Tide** (Biru Laut Tua) | **Manifest** | 12 | 1* | 360 | 85 | 0.70 dtk | 10 / 15 | Ranged Single-Target Burst tertinggi |

> _*Catatan Block pada Unit Ranged (`Yuki` & `Yoshiki`): Secara stat memiliki `Block: 1`, namun selama berdiri di tile tinggi (`HIGH`) tidak memblokir musuh jalur darat. Nilai `Block: 1` berguna untuk konsistensi UI, stage khusus, atau interaksi dengan musuh udara di masa depan._

---

### RAOOKAMI "RAOO" 🐺

| Atribut | Detail |
| --- | --- |
| Ras | Spirit Serigala (Husky) |
| Tinggi | 145 cm |
| Main Class | **Pursuer** |
| Elemen | **Umbra** |
| Tipe Damage | **Manifest DMG** (Melee Single-Target) |
| Kepribadian | Ceria, usil, sangat lengket ke Raku. Kurang akur dengan Yuki |
| Suka / Tidak Suka | Suka: Daging, salju, Raku · Tidak suka: Yuki |

**Skills (pilih 1 dari 3 di kartu bawah sebelum deploy):**
1. **Shadow Dash** — Dash ke target terdekat, deal damage + stun singkat.
2. **Dark Howl** — AoE kegelapan di sekitar dirinya, slow semua musuh dalam radius.
3. **Pack Instinct** _(Passive)_ — Meningkatkan ATK/performa saat efek **Covenant Link** atau buff Master aktif.

**Spirit Form:** Berubah menjadi serigala besar — stat meningkat dan jangkauan serangan bertambah.

**Ide Alter (Pasca-Rilis):** _Winter Raoo_, _Shadow Raoo_ (gimmick/archetype baru).

---

### KUMA 🐻‍❄️

| Atribut | Detail |
| --- | --- |
| Ras | Spirit Beruang Putih |
| Tinggi | 150 cm |
| Main Class | **Sentinel** |
| Elemen | **Rime** |
| Tipe Damage | **Manifest DMG** (Melee Single-Target Tank) |
| Kepribadian | Dewasa, kalem, berwibawa layaknya kakak tertua |
| Suka / Tidak Suka | Suka: Makanan manis dingin · Tidak suka: Makanan pedas |

**Skills (pilih 1 dari 3 di kartu bawah sebelum deploy):**
1. **Memory Seal** — Menarget satu musuh, musuh terhenti sejenak karena manipulasi memori (*disoriented*).
2. **Foresight Barrier** — Memprediksi serangan berikutnya, menaikkan DEF semua Spirit di sekitar untuk menahan hantaman berat.
3. **Glacier Wall** _(Passive)_ — Secara berkala memunculkan kristal es di depannya yang memperlambat musuh yang lewat.

**Spirit Form:** Beruang raksasa — menjadi tank tak tergoyahkan, DEF sangat tinggi, otomatis *taunt* musuh dalam jangkauan.

**Ide Alter (Pasca-Rilis):** _Dream Kuma_, _Ancient Kuma_.

---

### YOSHIKI "SHIKI" 🦈

| Atribut | Detail |
| --- | --- |
| Ras | Spirit Hiu |
| Tinggi | 150 cm |
| Main Class | **Lurker** |
| Elemen | **Tide** |
| Tipe Damage | **Manifest DMG** (Ranged Single-Target Burst) |
| Kepribadian | Pendiam, *cool*, tenang ala assassin |
| Suka / Tidak Suka | Suka: Makanan laut, hujan · Tidak suka: Makanan pahit |

**Skills (pilih 1 dari 3 di kartu bawah sebelum deploy):**
1. **Camouflage** — Menghilang dari target musuh selama beberapa detik; serangan pertama setelah keluar dari mode ini menghasilkan *critical* besar.
2. **Tidal Strike** — Tembakan proyektil arus deras yang menembus beberapa musuh sekaligus (*pierce*).
3. **Frost Current** _(Passive)_ — Setiap serangan memiliki peluang membekukan target sejenak.

**Spirit Form:** Hiu raksasa semi-transparan — melayang dan mampu menembus seluruh musuh dalam satu jalur lurus.

**Ide Alter (Pasca-Rilis):** _Storm Shiki_, _Phantom Shiki_.

---

### RATORA "TORA" 🐯

| Atribut | Detail |
| --- | --- |
| Ras | Spirit Harimau |
| Tinggi | 145 cm |
| Main Class | **Seer** |
| Elemen | **Flare** |
| Tipe Damage | **Phantasm DMG** (Melee **AoE** + **Penghasil `CP`**) |
| Kepribadian | Tsundere, hiperaktif, penuh semangat |
| Suka / Tidak Suka | Suka: Daging, salju, Raku · Tidak suka: Sayuran |

**Skills (pilih 1 dari 3 di kartu bawah sebelum deploy):**
1. **Thunder Crash** — Ledakan energi petir AoE di sekitarnya, memberi damage dan *stun* singkat + tambahan `CP`.
2. **Blaze Rush** — Menerjang ke depan melewati jalur musuh dan meninggalkan jejak bara api (*damage over time*).
3. **Berserker Soul** _(Toggle)_ — ATK dan kecepatan serangan naik drastis dengan konsekuensi DEF turun dan HP berkurang perlahan; matikan toggle untuk berhenti.

**Spirit Form:** Harimau raksasa berselimut petir & bara — serangan AoE jauh lebih luas dan intens.

**Ide Alter (Pasca-Rilis):** _Inferno Tora_, _Thunder King Tora_.

---

### KOYUUKI "YUKI" 🦇

| Atribut | Detail |
| --- | --- |
| Ras | Spirit Kelelawar Vampir |
| Tinggi | 148 cm |
| Main Class | **Channeler** |
| Elemen | **Veil** |
| Tipe Damage | **Phantasm DMG** (Ranged Support / Healer / Disruptor) |
| Kepribadian | Usil, fleksibel, agak misterius |
| Suka / Tidak Suka | Suka: Buah-buahan, malam · Tidak suka: Makanan pahit |
| Catatan | Kurang akur dengan Raookami |

**Skills (pilih 1 dari 3 di kartu bawah sebelum deploy):**
1. **Dream Veil** — Menyelubungi musuh/area atau rekan dengan kabut mimpi untuk meredam ancaman serta memulihkan/melindungi Spirit terdekat.
2. **Hypnotic Song** — Gelombang suara hipnosis yang membuat target kuat terhenti menyerang atau melambat drastis sambil melemahkan fokusnya.
3. **Ethereal Form** — Memasuki wujud kabut malam; menyerang cepat sambil memulihkan HP Spirit terdekat berdasarkan persentase damage (*blood/veil drain*) atau memicu *disrupt* area.

**Spirit Form:** Kelelawar raksasa — terbang bebas mengabaikan rintangan map dan memulihkan seluruh Spirit sekaligus.

**Ide Alter (Pasca-Rilis):** _Night Bloom Yuki_, _Crimson Yuki_.

---

## 4. GAMEPLAY MECHANICS

### 4.1 Core Loop
Lobby (Interaktif) → Pilih Stage → Pilih Tim (dari 5 Spirit) →
Battle (atur Skill S1/S2/S3 di kartu bawah, deploy, taktik real-time) →
Reward (EXP material, Covenant Gold, Covenant Shards) → Kembali ke Lobby

### 4.2 Battle System

**Map:**
- Grid-based (`PATH`, `GROUND`, `HIGH`, `BLOCKED`), musuh bergerak mengikuti jalur menuju Crystal of Covenant.
- Pemain menempatkan Spirit **Pursuer, Sentinel, Seer** di tile `GROUND`, dan **Lurker, Channeler** di tile `HIGH`.

> 🗺️ **PRINSIP STAGE DESIGN: MULTI-SOLUTION**
> Setiap stage harus dapat diselesaikan oleh pemain F2P dengan komposisi dasar (Bond 0). Kesulitan tidak dibuat untuk memaksa pemain punya Bond tinggi atau Alter.

**Penempatan Spirit (`CP` / Covenant Point) & Kontrol Swipe + Kamera:**
- Setiap Spirit membutuhkan **`CP` (Covenant Point)** untuk di-deploy. `CP` bertambah otomatis seiring waktu (dan dipercepat oleh **Ratora** sebagai *Seer*).
- **Kecepatan & Slow-Motion Otomatis:**
  - Tersedia tombol **`1x` / `2x`** di HUD kanan atas.
  - Waktu arena otomatis melambat (**Slow-Motion ~`0.15x`**) pada 2 momen krusial: saat sedang **deploy/swipe arah** dan saat **hendak mengaktifkan skill Spirit** di arena.
- **Alur Deploy & Swipe Arah (*Swipe-to-Face* + Zoom Kamera):**
  1. Tarik kartu Spirit dari panel bawah dan jatuhkan ke tile valid → karakter **langsung berdiri di tile tersebut** (range belum ditampilkan) dan kamera **zoom-in halus** ke karakter sambil waktu melambat.
  2. Klik & **swipe (geser)** dari tengah tubuh karakter ke 4 arah (`▲`, `▼`, `◀`, `▶`) → range jangkauan langsung **muncul dan berputar** mengikuti arah tarikan secara real-time.
  3. **Lepas mouse/jari** → arah langsung terkunci, `CP` dipotong, range menghilang, kamera **zoom-out kembali normal**, dan kecepatan arena kembali normal.
- **Klik Spirit di Lapangan & Aturan Pause Taktis:**
  - Mengklik Spirit yang sudah berdiri di arena membuat kamera **zoom-in**, menampilkan jangkauan serangnya, serta tombol **`↩ RETREAT`** (ramah sentuhan Android maupun PC; klik kanan cepat di PC tetap berfungsi sebagai pintasan Retreat). Spirit masuk **cooldown 8 detik** tanpa penalti HP.
  - **Aturan Pause:** Saat game di-Pause (`⏸`), pemain tetap bisa mengganti skill di kartu bawah dan **men-deploy Spirit baru** dari deck bawah, tetapi Spirit di lapangan **terkunci dari klik baru**. Untuk menarik Spirit saat Pause, pemain harus **mengklik Spirit-nya lebih dulu sebelum menekan Pause**, sehingga tombol `↩ RETREAT`-nya masih bisa ditekan selama Pause.

**Pola Jangkauan (*Range*), Aturan Block, & Tipe Damage:**
- **Range Gaya *Arknights*:** Pola serangan di `.tres` mengikuti arah hadap depan yang dipilih (misal `1-1` untuk Raookami/Kuma: tile sendiri + 1 tile di depan; Ratora: tile sendiri + 3 tile di depan).
- **Aturan Serang Musuh Terblokir:** Spirit melee yang sedang memblokir musuh tetap dapat menyerang musuh yang diblokirnya meskipun musuh tersebut berada di belakang arah hadap visual Spirit.
- **Manifest DMG vs Phantasm DMG:**
  - **Manifest DMG:** Serangan fisik nyata (ditahan oleh `Manifest DEF`).
  - **Phantasm DMG:** Serangan energi astral/roh (ditahan oleh `Phantasm DEF`).
  - **Aturan Penting:** Semua Spirit tetap bisa melukai semua musuh (tidak ada imun total 0 damage), hanya berbeda pengurangan damage sesuai defense target.

**Sistem 5 Elemen & Siklus Advantage:**
- Setiap Spirit memiliki **1 elemen tetap** (tanpa sistem 10 reaksi elemen yang rumit):
  - **Segitiga Utama:** `Veil > Tide > Rime > Veil` *(Veil mengalahkan Tide, Tide mengalahkan Rime, Rime mengalahkan Veil)*.
  - **Pasangan Berlawanan:** `Umbra ⇄ Flare` *(keduanya saling memberikan bonus damage ekstra satu sama lain)*.
- Modifier elemen dijaga **ringan** (sekitar **+20% saat unggul / -15% saat lemah**).

**Mekanik Khas: `Covenant Link` (Last Stand Raku):**
- **Pemicu:** Aktif otomatis **1 kali per battle** tepat saat **musuh pertama kali berhasil menembus garis akhir menuju Crystal**.
- **Efek Langsung:**
  1. Musuh yang menerobos **tertahan sebelum mengurangi HP Crystal** dan **terpental mundur** di jalurnya (**3 tile** untuk musuh biasa/elite, **5 tile** untuk Boss).
  2. Layar memunculkan **efek Border Glow halus di 4 sisi tepi layar + aura tipis** beserta banner status (tidak menutupi tengah arena dengan blok warna pekat).
  3. Seluruh Spirit yang sedang mati / dalam masa *cooldown* langsung **reset** dan siap di-deploy kembali.
  4. Seluruh Spirit yang masih hidup di arena langsung **full HP**.
  5. Seluruh Spirit di arena mendapatkan **shield khusus kebal mati** + **omnibuff** (peningkatan HP, DEF, ATK SPD, dll.) selama **10 detik**.
- **Trade-off / Harga Kontrak:**
  1. Selama **10 detik** efek aktif, regenerasi **`CP` membeku** (tidak bertambah sama sekali).
  2. Setelah **10 detik** berakhir, shield dan seluruh buff dicabut:
     - Spirit yang sudah hidup di arena sebelum *Covenant Link* → HP-nya kembali ke kondisi awal sebelum terpicu, lalu **dikurangi 25%** dari HP awal tersebut.
     - Spirit yang baru bangkit dari status mati/cooldown → HP-nya langsung diset menjadi **50% dari Max HP**.
- **Star Rating:** Karena Crystal belum terkena damage saat musuh ditahan, pemain **tetap berpeluang meraih 3-Star** jika berhasil menjaga HP Crystal tetap utuh sampai akhir stage!

**Musuh & Prinsip Anti-Inflasi:**
- Musuh bergerak di jalur; memiliki tipe beragam (keroco cepat, elite tebal, terbang, berpelindung/armored, healer, hingga Boss berfase).
- **Anti-Powercreep / Tanpa HP Inflasi:** Kesulitan stage naik lewat **kombinasi tipe musuh, gimmick unik, dan tata letak jalur** — bukan menaikkan HP musuh x10 secara sewenang-wenang.

**Kondisi Menang / Kalah:**
- **Menang:** Semua gelombang musuh berhasil dikalahkan.
- **Kalah:** HP Crystal of Covenant mencapai 0.

### 4.3 Sistem Skill & In-Battle Skill Switcher

- **Pilih Skill di Kartu Bawah Saat Battle (Pengganti Menu Pra-Battle):**
  - Saat sudah masuk ke battle, pemain bisa memilih 1 dari 3 skill untuk tiap Spirit langsung dari kartu panel bawah: **Klik Kanan** (untuk PC) atau **Ketuk Singkat 1x tanpa menyeret** (untuk Android/layar sentuh).
  - **Aturan Anti-Curang:** Penggantian skill **hanya boleh dilakukan sebelum Spirit di-deploy** (atau setelah di-Retreat/mati dan cooldown selesai). Begitu Spirit turun ke arena, skill-nya **terkunci**. Kartu bawah menampilkan indikator **`S1` / `S2` / `S3`** yang aktif.
  - Skill 1 terbuka sejak awal, Skill 2 terbuka di Level 10, Skill 3 terbuka di Level 20.
- **5 Tipe Aktivasi & Durasi Skill (`SkillData`):**
  1. **`Passive`:** Selalu aktif tanpa bar/klik.
  2. **`Auto`:** Bar mengisi lalu otomatis aktif dan reset.
  3. **`Manual`:** Bar mengisi penuh lalu menunggu pemain klik untuk aktif (dengan *slow-mo* saat menarget/konfirmasi).
  4. **`Toggle`:** Bisa dinyalakan dan dimatikan kapan saja (*contoh: Berserker Soul Ratora*).
  5. **`Unlimited Duration`:** Sekali aktif (atau setelah terisi dan dipicu manual), bertahan **permanen** selama Spirit masih di arena sampai mati atau di-Retreat (*ala Skill 3 Thorns Arknights*).
  - _Aturan Desain:_ Skill 2 dan Skill 3 wajib tidak otomatis (`Manual / Toggle / Unlimited`), dan harus ada Spirit yang ketiga skill-nya **full manual** agar gameplay selalu membutuhkan kontrol aktif pemain.

### 4.4 Sistem Alter (Pasca-Rilis)

> 🎯 **Filosofi Alter: Horizontal, Bukan Vertikal**
> Alter **tidak boleh lebih kuat secara mentah** daripada bentuk dasar. Alter hadir sebagai **variasi cara bermain & gimmick tim baru** (misalnya archetype *DoT/Racun*, *Extra Action/Follow-up*, *Charge/Dynamo*, *Pursuit*, dll.) tanpa membuat versi dasar menjadi usang.

- **Jadwal Rilis:** Alter baru mulai dirilis **setelah game rilis dan seluruh banner karakter dasar selesai masuk ke Standard pool** — dirilis bertahap satu per satu, tidak sekaligus.
- Setiap Alter tetap memakai **1 elemen**, hadir dengan **skill set baru** serta **kisah singkat musiman** di kantor detektif.

### 4.5 Roguelite Mode — "Covenant Run"

Mode sampingan *endgame* tanpa stamina yang bisa dimainkan kapan saja:
- Pemain memilih tim (3 Spirit) dan melewati **5 stage acak** dari pool.
- Setiap stage selesai, pemain memilih **1 dari 3 Covenant Blessing (buff acak)**.
- Tidak ada hukuman jika gagal — pemain tetap mendapat reward sesuai jumlah stage yang berhasil dilalui.

### 4.6 Daily, Weekly, & Event System *(Scope Freeze: Setelah Fase 4)*

> 🗓️ **Filosofi: Main karena mau, bukan karena takut rugi.**

- **Daily Quest & Login Bonus Progresif:** Pemasukan *Covenant Shards* rutin tanpa stamina dan **tanpa streak punishment** (jika bolong, tahap login berhenti menunggu, tidak reset).
- **Event Permanen (Reset Mingguan) (`data/events/weekly/`):** Tantangan rutin yang selalu ada dan di-reset setiap minggu agar pemain santai tetap bisa mengejar reward di akhir pekan.
- **Event Patch / Musiman (`data/events/patch/`):** Konten cerita/stage khusus tiap update besar atau Alter season (pasca-rilis).

### 4.7 Leveling & Bond System

Progression karakter sengaja dibuat **2 lapis yang ramping** (tanpa *Elite Phase* dan tanpa *Skill Leveling* terpisah):

| Lapis | Cara Naik | Fungsi |
| --- | --- | --- |
| **Spirit Level (1–20)** | Pakai **EXP material** + **Covenant Gold** dari stage/gacha | Menaikkan stat dasar secara linear & membuka Skill 2 (Lv 10) serta Skill 3 (Lv 20) |
| **Bond Level (1–5)** | **= Sistem Portray (*Reverse: 1999*) / Eidolon (*HSR*)** dari duplikat Gacha banner | Memberikan bonus kenyamanan/mekanik (misal -1 CP, cooldown lebih cepat, tambahan target/durasi) + membuka dialog & ilustrasi spesial. **Bond 0 sudah cukup untuk menamatkan seluruh konten!** |

### 4.8 F2P Economy & Gacha System

> 💎 **Filosofi: F2P First & Tetap Punya Alasan Menarik untuk Pull**

- **Unit Awal Gratis:** Melalui **5 Stage Prolog**, semua pemain otomatis mendapatkan **ke-5 Spirit dasar di Bond 0**.
- **Tujuan Gacha:** Banner *Rate-Up* & *Standard* digunakan untuk menaikkan **Bond 1–5 (Portray/Eidolon)** Spirit favorit dan (pasca-rilis) mendapatkan **Alter** dengan gimmick tim baru. Karakter awal setelah selesai banner rate-up-nya langsung masuk ke pool **Standard**.
- **Mata Uang Resmi:** **Covenant Shards** (`150 Shards = 1 pull`, **Hard Pity 70**), **Covenant Fragment** (`4/duplikat` setelah Bond 5 penuh, `20 Fragment = 1 tiket pilihan`), **Covenant Gold**, & **EXP Material**. Detail angka ada di `docs/SPIRIT_COVENANT_ECONOMY.md`.

---

## 5. UI/UX STRUCTURE

### 5.1 Layar Utama (Lobby Interaktif)
[HOME / LOBBY SCREEN]
├── Showcase Spirit Favorit (bergerak/bernapas di lobby + tap untuk dialog)
├── Battle (Prolog / Chapter / Event Patch & Weekly / Covenant Run)
├── Spirit (Kelola Level & Bond)
├── Gacha (Rate-Up & Standard)
├── Shop (Exchange Fragment / Top-Up)
└── Settings

### 5.2 Battle UI
[ATAS] HP Crystal of Covenant | Gelombang ke-X/Y | Tombol Speed [1x/2x] | Pause [⏸]
[TENGAH] Map Grid + Spirit (Camera Zoom-In saat deploy/klik) + Border Glow Covenant Link
[BAWAH] CP Bar | [Kartu Spirit 1–5 + badge S1/S2/S3 (klik kanan/tap pilih skill)]

### 5.3 Palet Warna UI & Elemen

- **UI Utama:** Dark Navy + Gold Accent.
- **5 Elemen:** **Umbra** *(Ungu Pekat + Hitam/Merah Gelap)* · **Flare** *(Oranye-Kuning Emas)* · **Tide** *(Biru Laut Tua)* · **Rime** *(Putih Kristal + Silver)* · **Veil** *(Hijau Mint)*.

---

## 6. ART DIRECTION & PIPELINE (RAMAH SOLO DEV)

### 6.1 Prinsip Produksi Aset
Clip Studio Paint (CSP)
→ Gambar 1 Manekin/Proporsi Chibi Dasar + variasi rambut, baju, ekor/sayap, senjata (~7–9 bagian)
↓
Godot 4.7 (Skeleton2D + Bone2D)
→ Pasang tulang & animasi 1x di Template Scene (Idle, Deploy, Attack, Hurt, Die)
→ Karakter baru cukup duplikat template & tukar file PNG slot bagian tubuhnya
↓
Live2D Cubism 5.0 (Opsional / Spesial)
→ Dipakai untuk Raookami Chibi (sudah berjalan via GDCubism)
→ Di masa depan khusus untuk ilustrasi/skin spesial Lobby yang memang menjual karya seni

### 6.2 Spec & Trik Hemat Aset

| Kategori | Pendekatan Teknis | Catatan |
| --- | --- | --- |
| **Chibi Battle (5 Spirit)** | **Template Modular `Skeleton2D` (~7–9 bagian)** *(plus Live2D Raookami yang sudah berjalan)* | Pisah simpel: Kepala, Mata (2 gambar buka/tutup untuk kedip), Rambut Belakang, Badan+Baju, Tangan Kanan+Senjata, Tangan Kiri, Kaki Kiri/Kanan, Ekor/Sayap |
| **Arah Hadap Chibi** | **1 set Tampak Serong Depan** (+ *flip* Kiri/Kanan) | Kanan, Kiri (*flip*), dan Bawah memakai 1 set yang sama. Tampak belakang saat menghadap Atas (`▲`) disimpan sebagai *polish* opsional setelah 5 Spirit selesai |
| **Efek Hit, Tebasan, & Proyektil** | **1 set bentuk Putih Polos + Particle/Tween Godot** | Godot otomatis mewarnai bentuk putih polos (*slash*, percikan, proyektil) sesuai warna elemen masing-masing Spirit |
| **Lobby Interaktif** | **Portrait/Chibi + Animasi Kode Godot** *(tahap awal)* | Dibuat mulus dengan gerak napas, ekspresi, dan dialog tap; tidak wajib Live2D full-body berat di fase awal |
| **Latar Cerita / Dialog** | **Panel UI Minimalis / Gradien Suasana** | Tidak wajib menggambar background ruangan/pemandangan rumit |
| **Enemy & Boss** | **PNG / Modular Simpel** | Keroco/Elite ~128px, Boss ~256px |

> Catatan teknis compile GDCubism di mesin baru tetap didokumentasikan di **Section 8**.

---

## 7. AUDIO DIRECTION

- **BGM:** Fantasy orchestral + synthwave ringan (vibe santai detektif untuk kantor/lobby, ritme tegang untuk battle & momen *Covenant Link*).
- **SFX:** Setiap elemen dan tipe serangan punya karakter suara khas (*petir/flare, tebasan, percikan air, es retak, gelombang suara*) serta sinyal audio saat Crystal terkena hit atau *Covenant Link* terpicu.
- **Voice:** Teks + sound cue terlebih dahulu; dubbing TTS/RVC Jepang (naskah tersedia di `prolog chapter 1 raookami jp.md`) menyusul sebagai nilai tambah.

---

## 8. FILE STRUCTURE (Godot Project — Arsitektur Modular Final)

> Prinsip: **"1 File = 1 Fitur"** dan **Data-Driven**. Seluruh kerangka folder sampai game rilis telah disiapkan agar pengembangan bisa melompat antar fitur dengan rapi.

```text
spirit-covenant/
├── assets/
│   ├── audio/
│   │   ├── bgm/
│   │   ├── sfx/
│   │   └── voice/
│   ├── fonts/
│   └── spirites/
│       ├── characters/             ← raookami (ada), kuma, yoshiki, ratora, koyuuki
│       ├── enemies/                ← sprite musuh
│       ├── tiles/                  ← aset tile map
│       ├── ui/                     ← ikon elemen, ikon class, frame kartu, crystal
│       └── vfx/                    ← bentuk putih polos (slash, spark, proyektil)
├── addons/
│   ├── gd_cubism/                  ← plugin GDExtension Live2D (compile manual)
│   └── kanban_tasks/               ← tracker task internal di editor Godot
├── autoload/                       ← global script nanti (GameManager, AudioManager, Save, Analytics)
├── data/
│   ├── chapter/
│   │   ├── prolog/                 ← 5 stage Prolog (kontrak 1-per-1 + tutorial)
│   │   └── 1/stage_01.tres         ← stage Chapter 1 Kantor Detektif
│   ├── dialogs/                    ← data dialog cerita & lore fragment
│   ├── enemies/
│   │   ├── keroco/                 ← EnemyData keroco (KG-01, HY-01)
│   │   ├── elite/                  ← EnemyData elite (KK-SH)
│   │   └── boss/                   ← Boss Stage 5 & 10
│   ├── events/
│   │   ├── patch/                  ← Event Patch / Musiman
│   │   └── weekly/                 ← Event Permanen Reset Mingguan
│   ├── roguelite/                  ← pool stage & BlessingData Covenant Run
│   ├── skills/                     ← SkillData .tres (3 skill per Spirit)
│   └── spirits/                    ← SpiritData .tres (5 Spirit)
├── docs/                           ← Blueprint, Economy, Lore, Prolog, Roadmap, Audit, Workflow
├── scenes/
│   ├── battle/                     ← Inti Arena Battle (1 file = 1 fitur)
│   │   ├── battle.tscn
│   │   ├── battle.gd               ← wasit utama: grid, CP, Crystal HP, Speed/SlowMo/Pause, kamera
│   │   ├── battle_hud.gd           ← HUD (Crystal, CP, Wave, 1x/2x, Pause, kartu bawah, Retreat btn)
│   │   ├── deploy_controller.gd    ← drag & drop, swipe-to-face, klik unit & aturan kunci pause
│   │   ├── wave_spawner.gd         ← timer wave, spawn musuh, enemy_pool
│   │   ├── covenant_link_controller.gd ← mekanik Covenant Link + border glow 4 sisi layar
│   │   └── vfx_pool.gd             ← object pooling proyektil & VFX
│   ├── entities/                   ← Unit di arena
│   │   ├── spirit.gd               ← otak tempur Spirit (HP/DEF, block, target, attack, link)
│   │   ├── spirit_visual.gd        ← visual Spirit (Live2D / Skeleton2D / PNG / badge / bar)
│   │   └── enemy.gd                ← gerak jalur, attack blocker, Manifest/Phantasm, knockback
│   ├── events/                     ← scene menu Event Patch & Weekly
│   ├── menus/                      ← layar penuh (Lobby, StageSelect, SpiritMenu, CovenantRun, Gacha)
│   └── ui/                         ← widget reusable (PauseOverlay, DamagePopup, DialogBox, SkillPopup)
├── scripts/
│   ├── resources/                  ← cetakan Resource (.gd) tetap tipis meski ribuan data .tres
│   │   ├── spirit_data.gd
│   │   ├── enemy_data.gd
│   │   └── stage_config.gd
│   └── utils/                      ← helper umum
└── tests/
    └── sentry_test.tscn / .gd
Catatan Compile GDCubism: GDCubism (github.com/MizunagiKB/gd_cubism) di-compile manual memakai SCons + MSVC Build Tools + Cubism SDK for Native R4_1 (bukan versi terbaru karena isu linking toolset MSVC). Untuk Live2D motion loop, gunakan start_motion_loop() pada node GDCubismUserModel.
9. ENEMY DESIGN
Tipe Musuh & Counter
Tipe	Karakteristik	Counter Spirit	Catatan
Grunt	HP rendah, jumlah banyak	Ratora (Melee AoE + CP), Yoshiki (Pierce)	Keroco pembuka gelombang
Brute	HP tinggi, lambat	Kuma (Sentinel Block 3), Raookami (Pursuer burst)	Melatih penempatan tank & tipe DMG
Sprinter	HP rendah, sangat cepat	Yuki (Slow/Hypnosis), Raookami (cegat cepat)	Menguji reaksi cepat & Covenant Link
Flyer	Terbang, melewati rintangan	Yuki (Channeler), Yoshiki (Lurker)	Tidak terblokir melee darat biasa
Armored	Salah satu DEF (Manifest atau Phantasm) sangat tinggi	Serang dengan tipe DMG lawannya (tetap bisa dipukul semua Spirit)	Mengajarkan komposisi Manifest + Phantasm
Healer	Memulihkan musuh sekitar	Prioritas burst Yoshiki / Ratora	Harus segera disingkirkan
Boss	Punya elemen, 2 fase, kombinasi gimmick	Situasional + timing Skill & Covenant Link	Muncul di akhir arc/stage kunci (Stage 5 & 10)
Prinsip Scaling Musuh
Stage awal (Prolog 1–5): Musuh mayoritas Netral (tanpa elemen) untuk pengenalan mekanik dasar.
Stage menengah–akhir: Mulai memadukan Manifest/Phantasm DEF, elemen musuh (Umbra, Flare, Tide, Rime, Veil), jalur bercabang, dan gimmick khusus — HP musuh tidak pernah mengalami inflasi ekstrem.
10. RETENSI & PLAYER EXPERIENCE
Hari 1–7: Kenalan dengan 5 Spirit lewat Prolog 5 Stage, nikmati karakter favorit di Lobby, rasakan taktisnya kontrol Swipe + Slow-Mo dan tegangnya Covenant Link.
Minggu 2–4: Eksperimen ganti-ganti skill S1/S2/S3 di tengah battle lewat Retreat/Redeploy, elemen, serta Manifest vs Phantasm.
Bulan 2+: Replay Covenant Run (roguelite), kejar Event Mingguan tanpa tekanan streak, kumpulkan Bond 1–5 (dialog/ilustrasi), dan tunggu update cerita/kasus kantor detektif serta Alter pasca-rilis.
Anti-Frustrasi: Tidak ada stamina, kalah langsung retry gratis, tetap dapat reward di Covenant Run walau gagal, dan tidak ada hukuman streak harian.
11. REFERENSI GAME
Game	Yang Diambil	Yang Dihindari
Arknights	Grid TD, notasi range depan, speed 1x/2x + slow-mo deploy, kontrol pause taktis, skill Unlimited Duration, proporsi chibi modular seragam	Cerita terlalu suram di awal, ketergantungan karakter rarity tertinggi, skill terkunci permanen sejak sebelum battle
Reverse: 1999	Sistem dua tipe damage abstrak (Manifest/Phantasm), siklus elemen + pasangan berlawanan, Bond = Portray, gimmick tim unik pada karakter baru	Rigging Live2D full-body berat untuk semua karakter di awal
Mobile Legends	Feel gestur swipe arah targeting & respons kamera halus	—
Honkai: Star Rail	Eidolon/Bond berfokus kenyamanan mekanik, vibe karakter hidup, mode roguelite buff	Inflasi HP musuh & power creep
Detective Conan / Kemono Jihen	Kasus episodik detektif supranatural yang santai tapi menanam benih misteri yang saling terhubung	—
Hades	Loop roguelite Covenant Run yang selalu segar	—
12. CATATAN PENTING UNTUK AI ASSISTANT
Jika kamu (AI lain) membaca dokumen ini untuk membantu developer:
Engine & Arsitektur: Godot 4.7, GDScript, arsitektur modular "1 File = 1 Fitur" (scenes/battle/, scenes/entities/, scripts/resources/). Hindari menumpuk kode kembali ke satu file raksasa.
Prioritas & Realitas Solo Dev: Gameplay loop & rasa senang coding lebih utama daripada beban gambar berat. Jangan sarankan Live2D full-body wajib untuk semua karakter atau background ilustrasi rumit.
Istilah Resmi: Gunakan CP (Covenant Point) (bukan DP/Cost), Yuki (bukan Uki), Manifest DMG / Phantasm DMG (bukan Physical/Magic), serta 5 Main Class Pursuer, Sentinel, Lurker, Channeler, Seer.
Kontrol & Battle UX: Speed 1x/2x, slow-mo saat deploy/swipe arah & saat aktifkan skill, aturan Pause taktis (boleh deploy dari bawah, unit arena terkunci dari klik baru kecuali diklik sebelum Pause), serta pilih skill S1/S2/S3 langsung di kartu bawah sebelum deploy/setelah Retreat.
Sistem Elemen: 5 Elemen tetap (Umbra, Flare, Tide, Rime, Veil) dengan siklus Veil > Tide > Rime > Veil dan Umbra ⇄ Flare (modifier ringan ±15–20%). Jangan sarankan sistem 10 Elemental Reaction.
Mekanik Khas: Covenant Link aktif otomatis 1x saat musuh pertama lolos (tahan Crystal + knockback 3/5 tile + border glow 4 tepi layar + reset CD + shield kebal mati & omnibuff 10 detik + CP beku 10 detik + recoil HP -25% awal / 50% Max HP setelah selesai + tetap sah 3-Star jika Crystal utuh).
Melee & Range Rule: Range mengikuti pola depan gaya Arknights; Spirit melee yang sedang memblokir musuh tetap bisa menyerang musuh yang terblokir meski di belakangnya. Hanya Ratora (Seer) yang melee AoE (+ cetak CP); Raookami & Kuma single-target; serangan melee tidak menembakkan proyektil ranged.
5 Spirit Dasar Gratis (Bond 0): Didapat dari 5 Stage Prolog. Bond 1–5 = Portray/Eidolon dari gacha; Alter & Event hanya untuk pasca-rilis (patuhi Scope Freeze sebelum Fase 4 selesai).
Blueprint ini adalah dokumen visi — HANYA berisi tujuan, lore, dan desain inti. Progress, checklist, dan status pengerjaan ada di SPIRIT_COVENANT_ROADMAP.md dan CURRENT_STATE.md, bukan di sini.
Last updated: 20 Nov 2026 — v2.1 (Update kontrol battle ala Arknights×ML [Swipe-to-Face, Zoom Kamera, Slow-Mo Deploy & Skill, Speed 1x/2x, Pause Taktis], In-Battle Skill Switcher + 5 tipe aktivasi termasuk Unlimited Duration, serangan melee ke unit terblokir, Event Patch & Weekly, serta Arsitektur Folder Modular Final).