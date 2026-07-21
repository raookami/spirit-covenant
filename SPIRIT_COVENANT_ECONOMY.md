# SPIRIT COVENANT — F2P Economy & Monetisasi

> Dokumen pendamping Blueprint v1.4 & Roadmap. Dibuat Juli 2026 dari sesi diskusi economy design.
> Status: **Draft awal — semua angka adalah starting point, wajib di-playtest & disesuaikan sebelum final.**

---

## Filosofi

Selaras dengan prinsip di Blueprint (poin 14 & 16 di bagian "Catatan untuk AI Assistant"):

- **F2P first** — semua fitur inti bisa dinikmati tanpa spending
- **No streak punishment** — sistem harian tidak boleh menghukum pemain yang skip hari
- **Tidak terlalu mencekik, tidak terlalu memanjakan** — F2P rutin harus bisa dapat karakter rate-up per banner, tapi tetap butuh usaha
- **Roster kecil, tanpa sistem rarity berjenjang** — game ini hanya punya 5 Spirit (lihat Blueprint), tidak akan ditambah karakter baru untuk mengisi "rarity bawah". TIDAK ada sistem bintang 4★/5★/6★ ala gacha mainstream. Hanya 2 kategori: **Standard** (5 Spirit dasar, selalu di pool) dan **Featured/Limited** (Alter dari 5 Spirit, bergilir per banner). Ini konsisten dengan prinsip alter = horizontal progression (Blueprint poin 12) — tidak ada hierarki "makin tinggi rarity makin kuat"
- Semua angka di dokumen ini adalah **hipotesis kerja**, bukan keputusan final — akan berubah setelah playtest nyata

---

## 1. Siklus Banner

- **Durasi 1 banner: 3 bulan**, sinkron dengan major content patch
- **Minor patch**: tiap 3-4 minggu (bug fix, balance tweak, event kecil — tidak butuh konten baru)

---

## 2. Sumber Covenant Shards (Currency Gacha)

### 2.1 Daily Quest

- Quest harian sederhana → **80 Shards/hari** (flat, tidak berubah)

### 2.2 Login Bonus Progresif (10 tahap, TIDAK reset saat bolong)

> **Update (revisi balance):** dinaikkan dari 7 tahap ke 10 tahap. Total tetap 500 Shards/siklus — tidak dipotong, hanya dipecah lebih kecil-kecil supaya butuh lebih banyak hari kalender untuk selesai. Tujuannya mengurangi surplus pull per banner (lihat bagian 4).

Mekanisme:

- Ada 10 tahap bonus, total keseluruhan **500 Shards**
- Tiap login, pemain naik 1 tahap dan dapat bonus tahap itu (di luar 80 Shards daily quest)
- **Kalau bolong, progress tahap BERHENTI (tidak mundur, tidak reset)** — lanjut dari tahap terakhir begitu login lagi
- Setelah tahap 10 selesai, siklus mulai ulang dari tahap 1
- Ini murni soal _kecepatan_ menyelesaikan siklus, bukan hukuman — pemain rajin menyelesaikan lebih banyak siklus per bulan kalender, pemain santai tetap dapat 500 Shards penuh per siklus, hanya lebih lambat
- Dengan 10 tahap, pemain login harian butuh **~10 hari kalender per siklus** (vs ~7 hari di versi lama) → sekitar **~3 siklus/bulan** (vs ~4.3 siklus/bulan di versi lama)

Pembagian 10 tahap (revisi, belum final — masih starting point untuk playtest):
| Tahap | Shards |
|---|---|
| 1 | 20 |
| 2 | 30 |
| 3 | 40 |
| 4 | 45 |
| 5 | 50 |
| 6 | 55 |
| 7 | 60 |
| 8 | 65 |
| 9 | 65 |
| 10 | 70 |
| **Total** | **500** |

### 2.3 Duplicate → Bond → Covenant Fragment → Tiket

> **Update (revisi 2):** sistem tiket duplikat lama (syarat generik + cap 5 tiket/bulan) diganti sistem 3 tahap di bawah — terinspirasi HSR Eidolon, dengan tambahan fleksibilitas pilih tiket.

Sistem duplikat 3 tahap:

**Tahap 1 — Mengisi Bond Level**

- Setiap Spirit punya Bond level 1-5 (sesuai sistem Bond yang sudah ada di Blueprint Fase 4)
- Duplikat ke-1 sampai ke-5 dari Spirit yang sama → otomatis menaikkan Bond level 1→5 (max) — duplikat awal tidak pernah sia-sia, langsung membuka progres Bond (dialog + ilustrasi sesuai Blueprint)

**Tahap 2 — Duplikat Setelah Bond Max → Covenant Fragment**

- Duplikat ke-6 dst (setelah Bond max tercapai) → convert jadi **4 Covenant Fragment** per duplikat
- Covenant Fragment adalah currency terpisah dari Shards, khusus untuk exchange tiket

**Tahap 3 — Tukar Fragment jadi Tiket Pilihan**

- **20 Covenant Fragment = 1 tiket gacha** (setara 5 duplikat kelebihan setelah Bond max)
- Pemain **memilih sendiri** tiket ini untuk banner **Standard** atau **Limited/Featured** — beda dari sistem currency universal ala HSR, di sini pemain punya kontrol eksplisit
- Tidak ada cap bulanan (berbeda dari draft sebelumnya) — murni terbatas oleh seberapa banyak duplikat yang didapat pemain secara alami dari pull

**Catatan:** rasio 20 Fragment / 4 per duplikat = 5 duplikat per tiket ini starting point, perlu playtest — terutama karena Featured (rate lebih rendah) secara alami akan butuh jauh lebih lama untuk numpuk 5 duplikat dibanding Standard.

### 2.4 Sumber Lain (perlu didetailkan nanti)

- **Starter Shards (new player)** — sekitar 300-450 Shards (setara ~2-3 pull gratis) diberikan di sesi pertama, supaya pemain baru bisa langsung mencoba sistem gacha tanpa harus grinding dulu. Angka starting point, perlu playtest
- Achievement satu-kali sepanjang game
- Event/Covenant Run reward (Fase 5)
- 3-star rating reward per stage

---

## 3. Estimasi Shards per Bulan (Pemain Rajin, Starting Point)

> **Update (revisi balance):** angka login bonus di bawah sudah pakai siklus 10 tahap (lihat 2.2), bukan 7 tahap versi awal.

| Sumber                                  | Per bulan         |
| --------------------------------------- | ----------------- |
| Daily quest (80 × 30 hari)              | 2.400             |
| Login bonus progresif (500 × ~3 siklus) | ~1.500            |
| **Total per bulan**                     | **~3.900 Shards** |

**Per banner (3 bulan):** ~11.700 Shards + bonus achievement/event (~1.500 estimasi) = **~13.200 Shards**

Pemain yang tidak login tiap hari akan dapat lebih sedikit secara proporsional (daily quest hanya cair saat login; siklus 10-tahap butuh lebih banyak hari kalender untuk selesai) — ini WAI (working as intended), bukan bug desain.

---

## 4. Gacha Pricing (Starting Point)

- **1 pull = 150 Shards** (asumsi kerja, belum final)
- **Harga 1 pull kalau beli langsung = Rp 12.000** (asumsi kerja — dipilih di kisaran bawah standar industri Rp 15.000-25.000 karena game masih baru/indie, prioritas konversi awal dibanding margin tinggi)
- **Hard pity: 70 pull** (revisi dari 65 — dinaikkan sedikit untuk mengurangi surplus pull per banner. Masih lebih murah hati dibanding standar industri 80-90)

### Hasil Perhitungan (Revisi)

- Shards per banner (~13.200) ÷ 150 = **~88 pull dari Shards murni**
- Ditambah tiket dari Covenant Fragment (lihat 2.3) — jumlahnya kini tidak dibatasi cap bulanan, murni tergantung berapa banyak duplikat yang didapat pemain secara alami. Untuk pemain yang belum Bond max di semua Spirit (awal-awal permainan), kontribusi tiket ini kemungkinan kecil/nol; baru signifikan setelah roster Bond max, jadi lebih relevan di fase pertengahan-akhir game dibanding early game
- **Estimasi awal (early-mid game): ~88-95 pull per banner** dari Shards + Fragment minimal, vs kebutuhan hard pity 70
- **Surplus: ~18-25 pull** di atas hard pity pada fase ini — perlu playtest ulang untuk fase late-game ketika kontribusi Fragment mulai signifikan

→ Pemain F2P rajin tetap **pasti** dapat karakter rate-up per banner (surplus positif di atas pity), tapi surplus tidak lagi berlebihan seperti versi awal. Ini masih F2P-friendly, konsisten dengan filosofi dokumen (developer tidak terlalu butuh revenue besar — target minimal ~$1/hari), tapi lebih ketat dibanding starting point pertama yang surplusnya lebih dari setengah hard pity.

**Perubahan dari versi awal:**
| | Versi awal | Versi revisi |
|---|---|---|
| Login bonus tahap | 7 tahap | 10 tahap (total tetap 500) |
| Siklus/bulan (pemain rajin) | ~4.3 | ~3 |
| Shards/banner | ~15.150 | ~13.200 |
| Hard pity | 65 | 70 |
| Pull/banner | ~101-110 | ~88-95 |
| Surplus vs pity | +36-45 | +18-25 |

Catatan: kedua angka (jumlah tahap & hard pity) masih **starting point** — tetap wajib di-playtest, bisa berubah lagi kalau setelah build jalan ternyata masih terlalu longgar atau malah kekencangan.

---

## 5. Anti-Exploit: Replay Stage

- Replay stage yang sudah clear **tidak boleh memberi Shards/EXP/currency upgrade tanpa batas** — akan jadi exploit farming kalau flat/unlimited
- **Keputusan eksplisit: TIDAK pakai sistem energi/stamina.** Ini akan bertentangan dengan Blueprint poin 15 dan bagian Anti-Frustrasi Design ("tidak ada stamina habis yang paksa berhenti main"). Solusi yang dipakai tetap **cap harian** — pemain bebas main sebanyak apapun, tapi reward (Shards/EXP/currency) dari stage yang sama dibatasi jumlah klaim penuh per hari, baru berkurang/nol setelah cap tercapai
- Shards utama datang dari daily quest + login bonus (lihat bagian 2), bukan dari grinding stage berulang
- Replay stage tetap berguna untuk hal lain (EXP karakter, 3-star rating, currency upgrade — lihat bagian 5b) — dengan cap harian yang sama prinsipnya

---

## 5b. Character Progression (Level & Upgrade)

> **Keputusan: TIDAK pakai sistem Elite Phase ala Arknights (E0/E1/E2).** Progression karakter cukup 2 lapis — Level (combat power) dan Bond (dari duplikat, lihat 2.3) — supaya tetap ringan diatur untuk roster kecil (5 Spirit).

### Struktur

- **Level 1-20** (sesuai Blueprint Fase 4), linear, tidak ada jenjang promosi/fase terpisah
- Naik level butuh **EXP material** dan **currency upgrade** (uang in-game, terpisah dari Covenant Shards)

### Sumber EXP Material & Currency Upgrade

| Sumber                                     | Jumlah per unit     |
| ------------------------------------------ | ------------------- |
| Farm stage (capped harian, lihat bagian 5) | 2-5 per stage clear |
| Gacha (tiap pull)                          | 8 per pull          |

- Farm dan gacha **sama-sama jadi sumber**, bukan exclusive salah satu — farm untuk progress pasti tapi lambat (dan capped harian), gacha untuk progress lebih cepat tapi terikat budget Shards
- **EXP material bersifat general** — bisa dipakai ke Spirit manapun, bukan spesifik per karakter. Alasan: roster cuma 5 Spirit, spesifik-per-karakter akan menambah kompleksitas desain (butuh 5 jenis material terpisah) yang tidak sepadan untuk solo dev; juga memberi pemain kebebasan memilih fokus Spirit favorit atau meratakan semua secara bertahap
- Ini juga jadi jawaban desain untuk kekhawatiran "roster kecil (5 Spirit) bikin gacha cepat habis/end-game": karena **collect karakter** (lewat gacha) dan **power progression** (lewat EXP/currency upgrade) sengaja dipisah — pemain bisa saja sudah punya & Bond max semua Spirit, tapi tetap butuh banyak EXP/currency untuk level mereka semua sampai maksimal, jadi gacha & farm tetap relevan sepanjang game, bukan cuma di awal

### Kurva EXP Level 1-20 (Template Awal — Referensi Pacing Arknights)

> Status: **kurva kasar/template, bukan final.** Dibuat dari rumus umum `EXP_dibutuhkan(level) = 50 × level^1.5`, meniru filosofi pacing Arknights (landai di awal, makin nanjak di akhir, tapi tidak terjal) — bukan angka Arknights yang dicontek mentah, karena Arknights punya Elite Phase yang mengubah struktur rentang level. Wajib direvisi begitu ada gameplay nyata untuk diukur (durasi rata-rata 1 battle, seberapa sering pemain battle per sesi, dll).

| Rentang Level | EXP Dibutuhkan | Kumulatif   |
| ------------- | -------------- | ----------- |
| 1→2           | 70             | 70          |
| 2→3           | 130            | 200         |
| 3→4           | 200            | 400         |
| 4→5           | 280            | 680         |
| 5→6           | 360            | 1.040       |
| 6→8           | 900            | 1.940       |
| 8→10          | 1.200          | 3.140       |
| 10→13         | 2.400          | 5.540       |
| 13→16         | 3.300          | 8.840       |
| 16→20         | 6.000          | **~14.840** |

**Total EXP Level 1→20: ~14.800-15.000** (dibulatkan, per Spirit)

### Kurva Currency Upgrade "Covenant Gold" Level 1-20 (Template Awal)

> Status: **template kasar, bukan final.** Gold adalah currency terpisah dari Shards dan EXP — dibutuhkan bersamaan dengan EXP tiap kali level-up (pola umum di gacha: Gold sering jadi bottleneck lebih dominan dibanding EXP di level tinggi). Rasio dipakai **1:2 terhadap EXP** (Gold butuh 2x lipat EXP).

| Rentang Level | Gold Dibutuhkan | Kumulatif   |
| ------------- | --------------- | ----------- |
| 1→5           | 1.360           | 1.360       |
| 5→10          | 4.280           | 5.640       |
| 10→16         | 15.480          | 21.120      |
| 16→20         | 12.000          | **~33.120** |

**Total Gold Level 1→20: ~33.000** (per Spirit, dibulatkan)

- **Sumber Gold:** sama seperti EXP — dari farm stage (capped harian) dan gacha (tiap pull), general (bukan spesifik per Spirit), konsisten dengan keputusan EXP

### Yang Belum Ditentukan

- Berapa banyak stage per hari yang dapat cap penuh EXP/Gold dari farm
- Validasi kurva EXP & Gold di atas begitu ada build yang bisa diukur durasi battle-nya

---

## 5c. Stat Karakter — Angka Konkret (Base Level 1)

> Status: **starting point untuk implementasi kode, bukan final.** Blueprint hanya mencantumkan rating bintang (⭐), bukan angka mentah yang bisa langsung dipakai di `spirit.gd`. Angka di bawah dikonversi dari rating bintang blueprint, disusun agar proporsional antar Spirit — wajib disesuaikan setelah playtest gameplay nyata (terutama keseimbangan TTK/time-to-kill dan DPS di battle).

### Sistem Damage Type: Physical vs Magic

- DEF dipecah jadi **Physical DEF** dan **Magic DEF** (bukan 1 DEF flat)
- **Physical DMG** efektif melawan musuh dengan **Magic DEF tinggi**
- **Magic DMG** efektif melawan musuh dengan **Physical DEF tinggi**
- Musuh yang tinggi di **kedua** DEF (biasanya miniboss/boss) perlu didekati lewat **Elemental Reaction** (lihat di bawah) — bukan lewat Physical/Magic biasa

| Spirit       | HP    | ATK | Physical DEF | Magic DEF | SPD (tile/detik) | Range                           |
| ------------ | ----- | --- | ------------ | --------- | ---------------- | ------------------------------- |
| **Raookami** | 800   | 45  | 30           | 20        | 2.0              | Melee                           |
| **Kuma**     | 1.200 | 25  | 60           | 40        | 0.8              | Melee (luas)                    |
| **Yoshiki**  | 350   | 70  | 10           | 15        | 1.6              | Medium-Long                     |
| **Ratora**   | 550   | 75  | 15           | 10        | 1.8              | Melee (AoE kecil)               |
| **Koyuuki**  | 550   | 45  | 10           | 20        | 2.2 (terbang)    | Medium (terbang, skip obstacle) |

Catatan konversi per Spirit:

- **Raookami** (HP★4 ATK★3 DEF★3 SPD★5) — tank-ish frontliner seimbang, SPD tertinggi kedua
- **Kuma** (HP★5 ATK★2 DEF★5 SPD★2) — HP & DEF tertinggi di roster, ATK & SPD terendah, sesuai role Defender murni
- **Yoshiki** (HP★2 ATK★5 DEF★1 SPD★4) — glass cannon ekstrem, ATK tertinggi tapi HP/DEF terendah
- **Ratora** (HP★3 ATK★5 DEF★2 SPD★4) — ATK setara Yoshiki tapi HP/DEF sedikit lebih baik, ditebus lewat AoE kecil (bukan pure single-target)
- **Koyuuki** (HP★3 ATK★3 DEF★2 SPD★5) — SPD tertinggi di roster (sesuai "sangat cepat, bisa terbang"), stat combat medium karena role utamanya Support/Disruptor bukan damage dealer

### Sistem Elemen (5 Elemen, Disederhanakan dari Blueprint)

> Keputusan: tiap Spirit (base maupun Alter) hanya punya **1 elemen dominan**, bukan 2 seperti tercantum di Blueprint asli. Elemen kedua di Blueprint (Psikik, Es-nya Yoshiki, Api, Darah) tidak dipakai untuk sistem reaction base form.

| Spirit   | Elemen Dominan |
| -------- | -------------- |
| Raookami | Kegelapan      |
| Kuma     | Es             |
| Yoshiki  | Air            |
| Ratora   | Petir          |
| Koyuuki  | Angin          |

**5 Elemen final: Kegelapan, Es, Air, Petir, Angin**

**Alter = swap elemen, bukan tambah elemen.** Alter tidak menggabungkan elemen base + elemen baru — Alter sepenuhnya berganti ke elemen lain (misal Raookami base = Kegelapan, Alter "Winter Raoo" = Air sepenuhnya). Ini menjaga alter tetap 1 elemen per versi karakter, dan konsisten dengan prinsip alter = horizontal progression (variasi strategi/counter, bukan tambahan kekuatan).

### Elemental Reaction Table (10 Kombinasi Dasar)

> Status: starting point nama & konsep efek. Angka pasti (persentase reduksi DEF, durasi stun/freeze, dll) belum ditentukan — perlu playtest combat nyata. Trigger: 2 Spirit beda elemen menyerang musuh yang sama dalam rentang waktu tertentu (durasi rentang waktu belum ditentukan).

| Kombinasi         | Efek Reaction                                                                       |
| ----------------- | ----------------------------------------------------------------------------------- |
| Kegelapan + Es    | Curse + Frostbite — damage over time bertambah seiring waktu                        |
| Kegelapan + Air   | Corrosion — kurangi Magic DEF musuh sementara                                       |
| Kegelapan + Petir | Dread Shock — stun tambahan (durasi lebih lama dari stun biasa)                     |
| Kegelapan + Angin | Haunting Gale — musuh disorientasi, sedikit chance salah target/miss serangan balik |
| Es + Air          | Freeze — musuh benar-benar berhenti bergerak singkat (lebih kuat dari sekadar slow) |
| Es + Petir        | Shatter — kurangi Physical DEF musuh sementara                                      |
| Es + Angin        | Frostbite Gale — slow tambahan lebih besar + sedikit damage over time               |
| Air + Petir       | Conductive Surge — kurangi Physical DEF musuh sementara                             |
| Air + Angin       | Tempest — AoE knockback kecil / dorong musuh mundur sedikit di jalur                |
| Petir + Angin     | Static Storm — chain damage kecil ke musuh terdekat di sekitar target               |

**Catatan:** Shatter (Es+Petir) dan Conductive Surge (Air+Petir) sama-sama mengurangi Physical DEF — perlu dipastikan saat balance supaya tidak bisa stack/dipakai bersamaan hingga jadi overpower (misal lewat cooldown reaction).

### Yang Belum Ditentukan

- Growth stat per level (berapa % kenaikan tiap Spirit naik 1 level) — biasanya tidak linear flat, tapi bertahap
- Base damage skill aktif tiap Spirit (baru ada deskripsi efek di Blueprint, belum ada angka damage/durasi/cooldown pasti)
- Angka pasti tiap reaction (persentase reduksi DEF, durasi efek, dll)
- Rentang waktu trigger reaction (berapa detik antar serangan beda elemen supaya masih dianggap reaksi bersamaan)
- Elemen musuh/resistensi — enemy.gd saat ini belum punya atribut elemen sama sekali, perlu didesain paralel dengan sistem ini
- Apakah musuh biasa (non-boss) juga punya Physical/Magic DEF split, atau sistem ini baru relevan mulai dari musuh yang lebih tanky

---

---

## 6. Model Distribusi & Pembayaran

### Rencana Distribusi

- **itch.io**: game di-publish **gratis** — murni sebagai etalase/distribusi, memanfaatkan traffic itch.io tanpa perlu budget ads
- **Website resmi game** (akan dibangun terpisah): jadi hub utama untuk in-app purchase (top-up Shards)
- Model ini umum dipakai game F2P indie: distribusi gratis di satu tempat, transaksi lewat sistem sendiri

### Kenapa Bukan Lewat itch.io Langsung

- itch.io hanya mendukung payout ke **PayPal atau Payoneer** — tidak ada opsi payment gateway custom
- PayPal developer **sudah diblokir/dinonaktifkan** (bukan soal nama satu kata — itu punya solusi standar seperti duplikasi nama di kolom first/last name, tapi masalah utamanya adalah akun sudah kena restriksi)
- Payoneer jadi alternatif yang belum dicoba — worth dicek sebagai opsi cadangan

### Payment Gateway untuk Website: iPaymu

- Berizin resmi Bank Indonesia, bisa daftar cuma pakai KTP (tanpa NPWP di awal)
- Payout ke rekening bank Indonesia langsung, **T+1 sampai T+2** (T = tanggal transaksi; artinya dana bisa dicairkan 1-2 hari kerja setelah transaksi)
- Punya fitur **Cross-Border Transaction** — bisa terima kartu VISA/Mastercard dari pembeli luar negeri (kredit maupun debit), minimal transaksi Rp 100.000 untuk kategori ini
- Biaya per transaksi bervariasi tergantung metode pembayaran — perlu dicek ulang detail pricing resmi sebelum implementasi
- Alternatif sejenis yang belum dieksplorasi: Xendit, Midtrans, DOKU (semua mendukung kartu kredit internasional)

### Arsitektur yang Dibutuhkan (belum digarap, untuk fase mendekati rilis)

- Website dengan halaman "Top Up" terintegrasi iPaymu
- Sistem akun pemain (login) yang menghubungkan pembelian web ke progress in-game
- Backend server kecil untuk menyimpan data pemain & menerima webhook konfirmasi pembayaran dari iPaymu
- Godot perlu bisa fetch data pemain/currency terbaru dari backend ini
- **Estimasi timing:** paralel dengan Fase 4-5 di roadmap, tidak perlu selesai sebelum gameplay core jadi

### Google Play (Jalur Alternatif/Tambahan)

- Payout **langsung ke rekening bank Indonesia** via wire transfer, tidak tergantung PayPal
- Biaya registrasi developer: **US$25 sekali bayar**
- Minimum payout: **US$100**
- Dibayar dalam USD, dikonversi ke Rupiah oleh bank penerima
- Potongan Google Play Billing: **15-30%** dari transaksi — perlu diperhitungkan dalam margin
- Relevan juga untuk **AdMob** (lihat bagian 7) karena satu ekosistem akun Google yang sama

---

## 7. Rewarded Ads (Android Only)

- Terinspirasi dari game sejenis (contoh yang disebut: Pal Go TD) — pemain bisa nonton iklan singkat untuk dapat reward gratis (opsional, bukan wajib)
- **Penting: AdMob hanya tersedia untuk Android/iOS, TIDAK ada versi Windows/PC desktop** — semua plugin Godot yang ditemukan (termasuk Poing Studios AdMob untuk Godot 4.7) khusus mobile
- Implikasi: fitur ini baru relevan di **Fase 6 (Android Port)**, bukan di versi Windows
- Plugin yang paling lengkap ditemukan: AdMob Plugin oleh Poing Studios — support rewarded, rewarded interstitial, ada mode testing langsung di Editor Godot
- Alur uang: AdMob → Google AdSense → payout mirip Google Play (wire transfer ke bank, minimum payout terpisah dari Play Store, perlu dicek angkanya)
- Kalau akun Google Play Developer sudah ada, AdMob bisa dihubungkan ke akun yang sama — tidak perlu setup identitas dari nol

---

## 8. Yang Masih Perlu Diputuskan / Didetailkan

- [x] Syarat duplicate-to-ticket — diputuskan: Bond level (5 duplikat pertama) → 4 Fragment/duplikat setelahnya → 20 Fragment = 1 tiket pilihan (lihat 2.3)
- [x] Sistem Elite Phase — diputuskan: TIDAK dipakai, cukup Level 1-20 + Bond (lihat 5b)
- [x] Sistem energi/stamina — diputuskan: TIDAK dipakai, tetap cap harian sesuai prinsip Blueprint (lihat 5)
- [x] Kurva EXP kasar untuk Level 1→20 — dibuat sebagai template awal (lihat 5b), wajib divalidasi ulang saat ada build nyata
- [x] Kurva Gold (currency upgrade) untuk Level 1→20 — template awal, rasio 1:2 terhadap EXP (lihat 5b)
- [x] Stat karakter angka konkret (HP/ATK/Physical DEF/Magic DEF/SPD/Range) — dikonversi dari rating bintang Blueprint, starting point untuk kode (lihat 5c)
- [x] Sistem damage type (Physical vs Magic) & 5 elemen final + reaction table 10 kombinasi — lihat 5c
- [ ] Jumlah stage/hari yang dapat cap penuh EXP/Gold dari farm (lihat 5b)
- [ ] Growth stat per level, base damage skill aktif, angka pasti tiap reaction, atribut elemen musuh (lihat 5c)
- [ ] Sumber Shards tambahan dari achievement & event (angka belum ada)
- [ ] Reward non-Shards dari replay stage: 3-star rating (EXP & currency upgrade sudah diputuskan, lihat 5b)
- [ ] Playtest angka-angka di bagian 3 & 4 begitu ada build yang bisa dicoba
- [ ] Cek Payoneer sebagai alternatif payout itch.io
- [ ] Cek detail pricing lengkap iPaymu untuk kategori produk digital
- [ ] Tentukan apakah butuh Payoneer/iPaymu keduanya, atau cukup salah satu

---

_Dokumen ini hidup — update seiring keputusan desain baru dan hasil playtest._
