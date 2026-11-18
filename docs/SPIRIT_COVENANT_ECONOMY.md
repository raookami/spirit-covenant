# SPIRIT COVENANT — F2P Economy, Stat, & Monetisasi

> Dokumen pendamping Blueprint v2.0 & Roadmap. Dibuat Juli 2026 · **Update 18 Nov 2026** (sinkronisasi 5 Spirit gratis Prolog, Bond = Portray, 5 Main Class, Manifest/Phantasm DMG, 5 Elemen unik, & stat rebalance).
> Status: **Draft kerja — angka ekonomi & stat adalah starting point yang wajib di-playtest saat build berjalan.**

---

## Filosofi

Selaras dengan prinsip di Blueprint v2.0:

- **F2P first** — semua stage inti bisa diselesaikan tanpa spending dan tanpa keharusan punya Bond tinggi.
- **5 Spirit dasar gratis (Bond 0)** — seluruh pemain mendapatkan Raookami, Kuma, Yoshiki, Ratora, dan Yuki lewat **5 Stage Prolog**.
- **No streak punishment & no stamina** — sistem harian tidak menghukum pemain yang bolong sehari, dan tidak ada energi yang memaksa pemain berhenti bermain.
- **Roster kecil, tanpa rarity berjenjang** — tidak ada bintang 4★/5★/6★ ala gacha mainstream. Banner dibagi menjadi:
  - **Banner Rate-Up / Standard:** Berisi 5 Spirit dasar untuk menaikkan **Bond 1–5 (= Portray / Eidolon)**. Karakter awal yang banner rate-up-nya selesai langsung masuk ke pool **Standard**.
  - **Banner Alter (Pasca-Rilis):** Baru mulai dirilis satu per satu **setelah game berjalan & seluruh banner karakter dasar masuk Standard**, membawa *gimmick/archetype* tim baru tanpa *power creep* stat mentah.

---

## 1. Siklus Banner

- **Durasi 1 banner:** ~3 bulan (sinkron dengan update konten/arc besar).
- **Minor patch:** tiap 3–4 minggu (bug fix, balance tweak, event kecil).
- **Urutan rilis jangka panjang:** Banner karakter dasar terlebih dahulu → masuk Standard → baru mulai rilis Alter bertahap pasca-rilis (tidak sekaligus).

---

## 2. Sumber Covenant Shards (Currency Gacha)

> _Catatan Scope Freeze: Sistem Daily Quest & Gacha penuh baru diimplementasikan ke kode setelah Fase 4 selesai._

### 2.1 Daily Quest

- Quest harian sederhana → **80 Shards/hari** (flat, tidak berubah).

### 2.2 Login Bonus Progresif (10 tahap, TIDAK reset saat bolong)

- Ada 10 tahap bonus, total keseluruhan **500 Shards** per siklus.
- Tiap login, pemain naik 1 tahap dan mendapat bonus tahap itu (di luar 80 Shards daily quest).
- **Kalau bolong, progress tahap BERHENTI (tidak mundur, tidak reset)** — lanjut dari tahap terakhir saat login lagi.
- Setelah tahap 10 selesai, siklus mulai ulang dari tahap 1 (~10 hari per siklus = **~3 siklus/bulan** untuk pemain harian).

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

### 2.3 Duplicate → Bond (= Portray / Eidolon) → Covenant Fragment → Tiket

Sistem duplikat 3 tahap:

**Tahap 1 — Mengisi Bond Level (1–5)**
- Setiap Spirit memiliki **Bond Level 1–5** yang berfungsi seperti **Portray (*Reverse: 1999*) / Eidolon (*HSR*)**.
- Pemain memulai dari **Bond 0** (didapat gratis dari Prolog).
- Duplikat ke-1 sampai ke-5 dari Spirit yang sama → otomatis menaikkan **Bond Level 1→5** (max).
- **Prinsip Anti-Powercreep:** Bonus Bond difokuskan pada **kenyamanan & twist mekanik** (misal `-1 CP`, cooldown skill lebih singkat, tambahan target/durasi) + **membuka dialog & ilustrasi spesial**, BUKAN syarat wajib untuk menamatkan stage.

**Tahap 2 — Duplikat Setelah Bond Max → Covenant Fragment**
- Duplikat ke-6 dst (setelah Bond 5 penuh) → otomatis terkonversi menjadi **4 Covenant Fragment** per duplikat.

**Tahap 3 — Tukar Fragment Jadi Tiket Pilihan**
- **20 Covenant Fragment = 1 tiket gacha** (setara 5 duplikat kelebihan).
- Pemain **memilih sendiri** tiket ini untuk banner **Standard** atau **Featured/Rate-Up**.
- Tidak ada cap bulanan.

### 2.4 Sumber Lain

- **Starter Shards (new player):** ~300–450 Shards (~2–3 pull awal) di sesi pertama agar pemain baru bisa langsung mencoba fitur gacha.
- Achievement satu-kali sepanjang game, reward **Covenant Run** (Fase 5), serta reward **3-Star rating** per stage.

---

## 3. Estimasi Shards per Bulan (Pemain Rajin, Starting Point)

| Sumber | Per bulan |
| --- | --- |
| Daily quest (80 × 30 hari) | 2.400 |
| Login bonus progresif (500 × ~3 siklus) | ~1.500 |
| **Total per bulan** | **~3.900 Shards** |

**Per banner (3 bulan):** ~11.700 Shards + bonus achievement/event (~1.500 estimasi) = **~13.200 Shards**

---

## 4. Gacha Pricing (Starting Point)

- **1 pull = 150 Covenant Shards**
- **Harga 1 pull kalau beli langsung = Rp 12.000** (kisaran ramah indie untuk konversi awal)
- **Hard pity: 70 pull** (dengan *pity carry-over* antar banner)
- **Estimasi pull F2P awal-menengah:** ~88–95 pull per banner (surplus ~18–25 pull di atas hard pity, tetap ramah F2P tanpa berlebih).

---

## 5. Anti-Exploit: Replay Stage

- Replay stage yang sudah clear **tidak boleh memberi Shards/EXP/Gold tanpa batas**.
- **Keputusan eksplisit: TIDAK pakai sistem energi/stamina** (konsisten dengan Blueprint bagian 4.6 & 10 tentang Anti-Frustrasi Design).
- Solusi yang dipakai adalah **cap klaim harian** — pemain bebas bermain kapan saja dan mengulang stage sesuka hati, tetapi reward penuh (EXP material / Covenant Gold) dari farming dibatasi jumlah klaimnya per hari.

---

## 5b. Character Progression (Level & Bond)

> **Keputusan:** Progression karakter sengaja diringkas menjadi **2 lapis saja** — **Spirit Level (1–20)** dan **Bond (1–5)**. Tidak ada Elite Phase (E0/E1/E2) dan tidak ada Skill Leveling terpisah.

### Struktur Naik Level (1–20)

- Naik level bersifat linear, membutuhkan **EXP material** (general untuk semua Spirit) + **Covenant Gold** (general).
- Sumber EXP material & Covenant Gold: **Farm stage** (2–5 unit per clear, dengan cap harian) dan **bonus setiap pull Gacha** (8 unit per pull).
- Pemisahan ini memastikan gacha & farm tetap relevan untuk jangka panjang meski roster inti hanya 5 Spirit.

### Kurva EXP & Covenant Gold Level 1–20 (Template Awal)

> Rumus kasar awal: `EXP(level) = 50 × level^1.5`, dan rasio **Covenant Gold = 2× EXP**. Wajib divalidasi ulang saat playtest durasi battle.

| Rentang Level | EXP Dibutuhkan | Kumulatif EXP | Gold Dibutuhkan | Kumulatif Gold |
| --- | --- | --- | --- | --- |
| 1 → 5 | 680 | 680 | 1.360 | 1.360 |
| 5 → 10 | 2.460 | 3.140 | 4.920 | 6.280 |
| 10 → 16 | 5.700 | 8.840 | 11.400 | 17.680 |
| 16 → 20 | 6.000 | **~14.840** | 12.000 | **~29.680 – 33.000** |

---

## 5c. Stat Karakter, Tipe Damage, & Sistem 5 Elemen (Base Level 1)

> Status: **hasil penyeimbangan ulang (rebalance) untuk implementasi ke `.tres` dan kode battle**.

### 1) Sistem Tipe Damage: `Manifest DMG` vs `Phantasm DMG`

- **`Manifest DMG`:** Serangan fisik nyata (ditahan oleh **`Manifest DEF`**).
- **`Phantasm DMG`:** Serangan energi astral/roh (ditahan oleh **`Phantasm DEF`**).
- **Aturan Penting:** **Semua Spirit tetap bisa menyerang dan melukai semua musuh** (tidak ada imun 0 damage). Perbedaan *Manifest DEF* dan *Phantasm DEF* pada musuh hanya membuat tipe serangan lawannya terasa jauh lebih efektif.

### 2) Tabel Stat Rebalance 5 Spirit (Level 1)

*(Catatan: Kolom **Attack Interval** adalah jeda antar serangan dalam detik sesuai field `atk_spd` di `SpiritData`, bukan kecepatan jalan — angka lebih kecil = serang lebih cepat).*

| Spirit | Main Class | Elemen | Tipe DMG | CP | Block | HP | ATK | Manifest DEF | Phantasm DEF | Attack Interval | Perkiraan DPS & Peran |
| --- | --- | --- | --- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | --- |
| **Ratora** | **Seer** | **Flare** | **Phantasm** | 7 | 2 | 520 | 35 | 15 | 10 | 0.80 dtk | **~44 DPS (Melee AoE)** + **Penghasil `CP`** |
| **Raookami** | **Pursuer** | **Umbra** | **Manifest** | 9 | 1 | 800 | 50 | 30 | 20 | 0.55 dtk | **~91 DPS (1 target)** — Duelis/Frontliner cepat |
| **Yuki** | **Channeler** | **Veil** | **Phantasm** | 10 | 1* | 500 | 28 | 10 | 25 | 0.60 dtk | **~47 DPS (1 target)** — Ranged cepat, Support/Healer/Disruptor |
| **Kuma** | **Sentinel** | **Rime** | **Manifest** | 12 | 3 | 1350 | 25 | 60 | 40 | 1.25 dtk | **~20 DPS (1 target)** — Tank utama penahan jalur |
| **Yoshiki** | **Lurker** | **Tide** | **Manifest** | 12 | 1* | 360 | 85 | 10 | 15 | 0.70 dtk | **~121 DPS (1 target)** — *Glass cannon*, Ranged burst tertinggi |

> _*Unit Ranged (`Yuki` & `Yoshiki`) memiliki nilai stat `Block: 1`, tetapi saat ditempatkan di tile tinggi (`HIGH`) tidak memblokir musuh jalur darat._

### 3) Sistem 5 Elemen & Siklus Advantage

Setiap Spirit hanya memiliki **1 elemen tetap** (tidak ada sistem 10 Elemental Reaction yang rumit):

| Elemen | Warna Resmi UI | Spirit Dasar |
| --- | --- | --- |
| **Umbra** | Ungu Pekat + Aksen Hitam / Merah Gelap | **Raookami** |
| **Flare** | Oranye-Kuning Emas Terang | **Ratora** |
| **Tide** | Biru Laut Tua | **Yoshiki** |
| **Rime** | Putih Kristal + Silver | **Kuma** |
| **Veil** | Hijau Mint | **Yuki** |

**Aturan Saling Mengalahkan (Siklus Ringan):**
- **Segitiga Utama:** **`Veil > Tide > Rime > Veil`**
  - `Veil` unggul atas `Tide` · `Tide` unggul atas `Rime` · `Rime` unggul atas `Veil`
- **Pasangan Berlawanan:** **`Umbra ⇄ Flare`**
  - Keduanya saling memberikan damage bonus ekstra satu sama lain.
- **Modifier Ringan:** Sekitar **+20% damage** saat unggul elemen dan **-15% damage** saat kalah elemen (musuh tahap awal/Prolog dapat berstatus **Netral** tanpa elemen).

### 4) Variasi Jangka Panjang: Gimmick Tim (Pasca-Rilis)

Untuk menjaga variasi strategi tanpa inflasi HP atau Elemental Reaction rumit, variasi baru dihadirkan melalui **musuh bergimmick** (butuh multi-hit, perisai, terbang, *Manifest/Phantasm DEF* tinggi) dan **Alter pasca-rilis** yang membawa *archetype/gimmick* tim baru (seperti *DoT/Racun*, *Extra Action/Follow-up*, dll.).

### Yang Belum Ditentukan

- Growth stat per level (Lv 1 → Lv 20)
- Angka base damage/durasi/cooldown pasti tiap skill aktif 5 Spirit (Fase 2)
- Detail angka cap harian farm EXP/Gold & persentase tepat buff *Covenant Link*

---

## 6. Model Distribusi & Pembayaran

### Rencana Distribusi

- **itch.io:** Game di-publish **gratis** sebagai etalase/distribusi awal tanpa budget ads.
- **Website resmi game (terpisah):** Hub utama untuk in-app purchase (top-up Shards) dengan payment gateway lokal.

### Kenapa Bukan Lewat itch.io Langsung

- itch.io hanya mendukung payout ke **PayPal atau Payoneer** (akun PayPal developer saat ini kena restriksi; Payoneer opsi cadangan yang belum dicoba).

### Payment Gateway Website: iPaymu

- Berizin Bank Indonesia, bisa daftar dengan KTP, payout langsung ke rekening bank Indonesia (**T+1 sampai T+2**).
- Mendukung **Cross-Border Transaction** (VISA/Mastercard luar negeri, minimal transaksi Rp 100.000).
- Alternatif sejenis untuk dicek ulang: Xendit, Midtrans, DOKU.

### Arsitektur Web Top-Up (untuk fase mendekati rilis)

- Halaman "Top Up" terintegrasi iPaymu + sistem akun pemain + backend server kecil penerima webhook konfirmasi pembayaran agar Godot bisa me-fetch saldo Shards terbaru.

### Google Play (Jalur Android)

- Payout langsung ke rekening bank Indonesia via wire transfer (registrasi US$25 sekali bayar, min payout US$100, potongan Google Play Billing 15–30%).

---

## 7. Rewarded Ads (Android Only)

- Opsional menonton iklan singkat untuk reward tambahan (tidak wajib).
- **Khusus Android/iOS (Fase 6)**, tidak tersedia untuk versi Windows desktop (plugin rekomendasi: **AdMob Plugin oleh Poing Studios** untuk Godot 4.7).

---

## 8. Checklist Keputusan Ekonomi & Desain

- [x] Syarat duplicate-to-ticket: **5 Spirit dasar gratis (Bond 0) di Prolog** → Bond 1–5 (= Portray/Eidolon) dari duplikat gacha → 4 Fragment/duplikat setelahnya → 20 Fragment = 1 tiket pilihan
- [x] Sistem Elite Phase & Skill Leveling: **TIDAK dipakai**, cukup 2 lapis (Level 1–20 + Bond 1–5)
- [x] Sistem energi/stamina: **TIDAK dipakai**, pakai cap klaim harian untuk farm
- [x] Kurva EXP & Gold kasar Level 1→20 dibuat sebagai template awal
- [x] Stat karakter rebalance (`CP`, `Block 1` untuk Ranged, `Attack Interval` sesuai kode), 5 Main Class, `Manifest vs Phantasm DMG`, & 5 Elemen unik + warna resminya
- [ ] Jumlah stage/hari untuk cap penuh farm EXP/Gold
- [ ] Growth stat per level & angka detail skill aktif (Fase 2)
- [ ] Sumber Shards tambahan dari achievement & event
- [ ] Playtest seluruh angka ekonomi & battle saat build sudah lengkap
- [ ] Cek Payoneer & detail pricing resmi iPaymu sebelum rilis komersial

---

_Dokumen ini hidup — update seiring keputusan desain baru dan hasil playtest._