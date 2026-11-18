# SPIRIT COVENANT — GAME BLUEPRINT

**Version:** 2.0  
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

| Spirit | Main Class | Elemen (Warna) | Tipe DMG | CP | Block | HP | ATK | Attack Interval | Manifest / Phantasm DEF | Pola & Peran |
| --- | --- | --- | --- | :---: | :---: | :---: | :---: | :---: | :---: | --- |
| **Ratora** | **Seer** | **Flare** (Oranye-Emas) | **Phantasm** | 7 | 2 | 520 | 35 | 0.80 dtk | 15 / 10 | Melee **AoE** + **Penghasil `CP`** |
| **Raookami** | **Pursuer** | **Umbra** (Ungu Pekat/Merah Gelap) | **Manifest** | 9 | 1 | 800 | 50 | 0.55 dtk | 30 / 20 | Melee Single-Target cepat (Duelis) |
| **Yuki** | **Channeler** | **Veil** (Hijau Mint) | **Phantasm** | 10 | 1* | 500 | 28 | 0.60 dtk | 10 / 25 | Ranged Support / Healer / Disruptor cepat |
| **Kuma** | **Sentinel** | **Rime** (Putih Kristal/Silver) | **Manifest** | 12 | 3 | 1350 | 25 | 1.25 dtk | 60 / 40 | Melee Tank utama penahan jalur |
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

**Skills (pilih 1 dari 3 sebelum battle):**
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
| Tipe Damage | **Manifest DMG** (Melee Single-Target Tank, jangkauan area luas) |
| Kepribadian | Dewasa, kalem, berwibawa layaknya kakak tertua |
| Suka / Tidak Suka | Suka: Makanan manis dingin · Tidak suka: Makanan pedas |

**Skills (pilih 1 dari 3 sebelum battle):**
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

**Skills (pilih 1 dari 3 sebelum battle):**
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

**Skills (pilih 1 dari 3 sebelum battle):**
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

**Skills (pilih 1 dari 3 sebelum battle):**
1. **Dream Veil** — Menyelubungi musuh/area atau rekan dengan kabut mimpi untuk meredam ancaman serta memulihkan/melindungi Spirit terdekat.
2. **Hypnotic Song** — Gelombang suara hipnosis yang membuat target kuat terhenti menyerang atau melambat drastis sambil melemahkan fokusnya.
3. **Ethereal Form** — Memasuki wujud kabut malam; menyerang cepat sambil memulihkan HP Spirit terdekat berdasarkan persentase damage (*blood/veil drain*) atau memicu *disrupt* area.

**Spirit Form:** Kelelawar raksasa — terbang bebas mengabaikan rintangan map dan memulihkan seluruh Spirit sekaligus.

**Ide Alter (Pasca-Rilis):** _Night Bloom Yuki_, _Crimson Yuki_.

---

## 4. GAMEPLAY MECHANICS

### 4.1 Core Loop
Lobby (Interaktif) → Pilih Stage → Pilih Tim (dari 5 Spirit) →
Pilih Skill per Spirit (1 dari 3) → Battle →
Reward (EXP material, Covenant Gold, Covenant Shards) → Kembali ke Lobby

### 4.2 Battle System

**Map:**
- Grid-based (`PATH`, `GROUND`, `HIGH`, `BLOCKED`), musuh bergerak mengikuti jalur menuju Crystal of Covenant.
- Pemain menempatkan Spirit **Pursuer, Sentinel, Seer** di tile `GROUND`, dan **Lurker, Channeler** di tile `HIGH`.

> 🗺️ **PRINSIP STAGE DESIGN: MULTI-SOLUTION**
> Setiap stage harus dapat diselesaikan oleh pemain F2P dengan komposisi dasar (Bond 0). Kesulitan tidak dibuat untuk memaksa pemain punya Bond tinggi atau Alter.

**Penempatan Spirit (`CP` / Covenant Point):**
- Setiap Spirit membutuhkan **`CP` (Covenant Point)** untuk di-deploy.
- `CP` bertambah otomatis seiring waktu (dan bisa dipercepat oleh **Ratora** sebagai *Seer*).
- Saat meletakkan Spirit, pemain memilih **4 arah hadap** (`▲`, `▼`, `◀`, `▶`) untuk mengarahkan pola serangannya; `CP` dipotong setelah arah dikonfirmasi.
- Spirit dapat ditarik kembali (**Retreat**, klik kanan) dan masuk masa **cooldown 8 detik** sebelum bisa di-deploy ulang (tanpa penalti HP).

**Tipe Damage (`Manifest` vs `Phantasm`) & Defense:**
- **Manifest DMG:** Serangan fisik nyata (cakar, hantaman, proyektil padat). Efektif melawan musuh ber-`Manifest DEF` rendah.
- **Phantasm DMG:** Serangan energi astral/roh (kilat energi, gelombang suara, sihir). Efektif melawan musuh ber-`Phantasm DEF` rendah.
- **Aturan Penting:** Semua Spirit tetap bisa melukai semua jenis musuh (tidak ada imun total 0 damage) — perbedaan `Manifest DEF` dan `Phantasm DEF` musuh hanya mengurangi besaran damage agar pemain terdorong memadukan tim secara taktis.

**Sistem 5 Elemen & Siklus Advantage:**
- Setiap Spirit memiliki **1 elemen tetap** (tanpa sistem 10 reaksi elemen yang rumit):
  - **Segitiga Utama:** `Veil > Tide > Rime > Veil` *(Veil mengalahkan Tide, Tide mengalahkan Rime, Rime mengalahkan Veil)*.
  - **Pasangan Berlawanan:** `Umbra ⇄ Flare` *(keduanya saling memberikan bonus damage ekstra satu sama lain)*.
- Modifier elemen dijaga **ringan** (sekitar **+20% saat unggul / -15% saat lemah**) agar tetap ramah bagi strategi *multi-solution* dan tidak menghukum pemain secara berlebihan.

**Mekanik Khas: `Covenant Link` (Last Stand Raku):**
Mekanik penyelamatan darurat yang menjadi ciri khas *Spirit Covenant*:
- **Pemicu:** Aktif otomatis **1 kali per battle** tepat saat **musuh pertama kali berhasil menembus garis akhir menuju Crystal**.
- **Efek Langsung:**
  1. Musuh yang menerobos **tertahan sebelum mengurangi HP Crystal** dan **terpental mundur** di jalurnya (**3 tile** untuk musuh biasa/elite, **5 tile** untuk Boss).
  2. Layar memunculkan efek visual khusus (vignette energi kalung & momen serius Raku).
  3. Seluruh Spirit yang sedang mati / dalam masa *cooldown* langsung **reset** dan siap di-deploy kembali.
  4. Seluruh Spirit yang masih hidup di arena langsung **full HP**.
  5. Seluruh Spirit di arena mendapatkan **shield khusus kebal mati** + **omnibuff** (peningkatan HP, DEF, ATK SPD, dll.) selama **10 detik**.
- **Trade-off / Harga Kontrak:**
  1. Selama **10 detik** efek aktif, regenerasi **`CP` membeku** (tidak bertambah sama sekali).
  2. Setelah **10 detik** berakhir, shield dan seluruh buff dicabut:
     - Spirit yang sudah hidup di arena sebelum *Covenant Link* → HP-nya kembali ke kondisi awal sebelum terpicu, lalu **dikurangi 25%** dari HP awal tersebut.
     - Spirit yang baru bangkit dari status mati/cooldown → HP-nya langsung diset menjadi **50% dari Max HP**.
- **Star Rating:** Karena Crystal belum terkena damage saat musuh ditahan, pemain **tetap berpeluang meraih 3-Star** jika berhasil bertahan dari efek samping dan menjaga HP Crystal tetap utuh sampai akhir stage!

**Musuh & Prinsip Anti-Inflasi:**
- Musuh bergerak di jalur; memiliki tipe beragam (keroco cepat, elite tebal, terbang, berpelindung/armored, healer, hingga Boss berfase).
- **Anti-Powercreep / Tanpa HP Inflasi:** Kesulitan stage naik lewat **kombinasi tipe musuh, gimmick unik, dan tata letak jalur** — bukan menaikkan HP musuh x10 secara sewenang-wenang.

**Kondisi Menang / Kalah:**
- **Menang:** Semua gelombang musuh berhasil dikalahkan.
- **Kalah:** HP Crystal of Covenant mencapai 0.

### 4.3 Sistem Skill

Sebelum battle, tiap Spirit memilih **1 dari 3 skill**:
- Skill 1: Terbuka sejak awal (Starter).
- Skill 2: Terbuka di Spirit Level 10.
- Skill 3: Terbuka di Spirit Level 20.

### 4.4 Sistem Alter (Pasca-Rilis)

> 🎯 **Filosofi Alter: Horizontal, Bukan Vertikal**
> Alter **tidak boleh lebih kuat secara mentah** daripada bentuk dasar. Alter hadir sebagai **variasi cara bermain & gimmick tim baru** (misalnya archetype *DoT/Racun*, *Extra Action/Follow-up*, *Charge/Dynamo*, dll.) tanpa membuat versi dasar menjadi usang.

- **Jadwal Rilis:** Alter baru mulai dirilis **setelah game rilis dan seluruh banner karakter dasar selesai masuk ke Standard pool** — dirilis bertahap satu per satu, tidak sekaligus.
- Setiap Alter tetap memakai **1 elemen** (tidak ada reaksi silang rumit), hadir dengan **skill set baru** serta **kisah singkat musiman** di kantor detektif.

### 4.5 Roguelite Mode — "Covenant Run"

Mode sampingan tanpa stamina yang bisa dimainkan kapan saja:
- Pemain memilih tim (3 Spirit) dan melewati **5 stage acak** dari pool.
- Setiap stage selesai, pemain memilih **1 dari 3 Covenant Blessing (buff acak)**.
- Tidak ada hukuman jika gagal — pemain tetap mendapat reward sesuai jumlah stage yang berhasil dilalui.

### 4.6 Daily & Weekly System *(Scope Freeze: Setelah Fase 4)*

> 🗓️ **Filosofi: Main karena mau, bukan karena takut rugi.**

- **Daily Quest & Login Bonus Progresif:** Membantu pemasukan *Covenant Shards* rutin tanpa sistem stamina/energi dan **tanpa streak punishment** (jika bolong sehari, tahap login hanya berhenti menunggu, tidak pernah reset ke nol).
- Sesuai **Scope Freeze Rules** di Roadmap, sistem Daily Quest baru diimplementasikan setelah Fase 4 selesai.

### 4.7 Leveling & Bond System

Progression karakter sengaja dibuat **2 lapis yang ramping** (tanpa sistem *Elite Phase* dan tanpa *Skill Leveling* terpisah):

| Lapis | Cara Naik | Fungsi |
| --- | --- | --- |
| **Spirit Level (1–20)** | Pakai **EXP material** + **Covenant Gold** dari stage/gacha | Menaikkan stat dasar secara linear & membuka Skill 2 (Lv 10) serta Skill 3 (Lv 20) |
| **Bond Level (1–5)** | **= Sistem Portray (*Reverse: 1999*) / Eidolon (*HSR*)** dari duplikat Gacha banner | Memberikan bonus kenyamanan/mekanik (misal -1 CP, cooldown lebih cepat, tambahan target/durasi) + membuka dialog & ilustrasi spesial. **Bond 0 sudah cukup untuk menamatkan seluruh konten!** |

### 4.8 F2P Economy & Gacha System

> 💎 **Filosofi: F2P First & Tetap Punya Alasan Menarik untuk Pull**

- **Unit Awal Gratis:** Melalui **5 Stage Prolog**, semua pemain otomatis mendapatkan **ke-5 Spirit dasar di Bond 0**.
- **Tujuan Gacha:** Banner *Rate-Up* & *Standard* digunakan untuk menaikkan **Bond 1–5 (Portray/Eidolon)** Spirit favorit dan (pasca-rilis) mendapatkan **Alter** dengan gimmick tim baru. Setelah banner rate-up berakhir, karakter dasar masuk ke banner Standard.
- **Mata Uang Resmi:**
  - **Covenant Shards:** Currency pull gacha (`150 Shards = 1 pull`, **Hard Pity 70**, *pity carry-over* antar banner).
  - **Covenant Fragment:** Didapat dari duplikat berlebih setelah Bond 5 penuh (**4 Fragment per duplikat**, **20 Fragment = 1 tiket gacha pilihan Standard atau Featured**).
  - **Covenant Gold & EXP Material:** Resource upgrade Level 1–20 dari farm stage (dengan cap harian pengganti stamina) dan tiap pull gacha.
- Detail kalkulasi angka dan kurva ada di `docs/SPIRIT_COVENANT_ECONOMY.md`.

---

## 5. UI/UX STRUCTURE

### 5.1 Layar Utama (Lobby Interaktif)
[HOME / LOBBY SCREEN]
├── Showcase Spirit Favorit (bergerak/bernapas di lobby + tap untuk dialog)
├── Battle (Prolog / Chapter / Covenant Run)
├── Spirit (Kelola Level, Bond, & Pilih 1 dari 3 Skill)
├── Gacha (Rate-Up & Standard)
├── Shop (Exchange Fragment / Top-Up)
└── Settings

### 5.2 Battle UI
[ATAS] HP Crystal of Covenant | Gelombang ke-X/Y | Timer / Pause
[TENGAH] Map Grid + Spirit + Musuh (+ Efek Layar Covenant Link saat aktif)
[BAWAH] CP Bar | [Kartu Spirit 1–5]

### 5.3 Palet Warna UI & Elemen

- **UI Utama:** Dark Navy + Gold Accent.
- **5 Elemen:**
  - **Umbra:** Ungu Pekat + Aksen Hitam / Merah Gelap *(Raookami)*
  - **Flare:** Oranye-Kuning Emas Terang *(Ratora)*
  - **Tide:** Biru Laut Tua *(Yoshiki)*
  - **Rime:** Putih Kristal + Silver *(Kuma)*
  - **Veil:** Hijau Mint *(Yuki)*

---

## 6. ART DIRECTION & PIPELINE (RAMAH SOLO DEV)

### 6.1 Prinsip Produksi Aset

Untuk menjaga konsistensi visual layaknya *Arknights* tanpa membebani solo dev mengerjakan rig berat dari nol untuk tiap karakter:
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

## 8. FILE STRUCTURE (Godot Project)
spirit-covenant/
├── assets/
│ └── spirites/
│ ├── characters/
│ │ └── raookami/ ← aset PNG + Live2D idle (.moc3, .model3.json, .motion3.json)
│ └── enemies/
│ └── enemy1.png
├── addons/
│ ├── gd_cubism/ ← plugin GDExtension Live2D (compile manual)
│ └── kanban_tasks/ ← tracker task internal di editor Godot
├── data/
│ ├── chapter/1/stage_01.tres ← StageConfig resource
│ ├── enemies/ ← EnemyData .tres (keroco & elite)
│ └── spirits/ ← SpiritData .tres (5 Spirit)
├── docs/ ← Blueprint, Economy, Lore, Prolog, Roadmap, Audit, Workflow
├── scenes/
│ ├── battle.tscn / battle.gd
│ ├── spirit.gd
│ ├── enemy.gd
│ └── stage_config.gd
├── scripts/
│ ├── spirit_data.gd
│ └── enemy_data.gd
├── tests/
│ └── sentry_test.tscn / .gd
└── project.godot