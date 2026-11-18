# WORKFLOW — Cara Dokumentasi Project Ini Bekerja

> Dokumen ini menjelaskan bagaimana Blueprint, Roadmap, Current State, dan Kanban saling terhubung — dan bagaimana membuatnya tetap sinkron **tanpa perlu kamu edit dokumen manapun secara manual**.

---

## Peta Peran Tiap Dokumen

| Dokumen | Isi | Siapa yang edit | Kapan berubah |
|---|---|---|---|
| `SPIRIT_COVENANT_BLUEPRINT.md` | **Tujuan & visi** — lore, karakter, mekanik inti, filosofi desain | Kamu, manual, jarang | Hanya kalau visi besar game berubah |
| `SPIRIT_COVENANT_ROADMAP.md` | **Rencana per fase** — checklist fitur besar per fase, ditandai `<!--id:xxx-->` | **Otomatis** oleh `sync_docs.ps1` | Setiap kali ada task Done di Kanban yang cocok |
| `CURRENT_STATE.md` | **Snapshot kondisi sekarang** — git log terbaru, task aktif, hasil sync | **Otomatis sepenuhnya** | Setiap commit, atau setiap kanban berubah (watch mode) |
| `kanban_tasks_data.kanban` | **Task granular** — satu-satunya tempat kamu ketik task baru | Kamu, manual, lewat GUI kanban di Godot | Kapan saja kamu mau |

**Aturan emas:** Blueprint gak boleh ada checklist progress. Roadmap gak boleh ada detail super teknis (itu tugas commit message/git log). Current State gak boleh diedit manual sama sekali (akan ketimpa otomatis). Kamu cuma perlu sentuh **Kanban**.

---

## Alur Otomasi

```
Kamu ketik/drag task di Kanban (GUI Godot)
            │
            ▼
   kanban_tasks_data.kanban berubah
            │
            ▼
  sync_docs.ps1 mendeteksi perubahan
  (lewat -Watch mode, jalan otomatis saat
   folder dibuka di VS Code)
            │
            ├──► Task yang masuk "Done" dicocokkan ke
            │    checklist Roadmap (keyword matching,
            │    atau Groq AI kalau -UseGroq dipakai)
            │         │
            │         ├─ Cocok → centang [x] di Roadmap otomatis
            │         └─ Tidak cocok → dicatat di section
            │           "Di Luar Rencana Awal" di Roadmap
            │
            └──► CURRENT_STATE.md ditulis ulang total:
                 - 3 commit git terakhir
                 - Task aktif (Doing + Todo)
                 - Hasil sync barusan
                 - Reminder: item Roadmap yang belum
                   ada task Kanban-nya
```

Plus, terpisah dari alur di atas:

```
git commit
    │
    ├──► [pre-commit hook] jalankan check_deadcode.ps1
    │         │
    │         ├─ Ada dead code di kode sendiri → COMMIT DIBLOKIR
    │         └─ Bersih → commit lanjut
    │
    └──► [post-commit hook] jalankan sync_docs.ps1 otomatis
             (supaya CURRENT_STATE langsung reflect commit baru)
```

---

## Setup Sekali Saja (per mesin/clone baru)

1. **Aktifkan git hooks custom** (supaya pre-commit & post-commit otomatis jalan):
   ```powershell
   git config core.hooksPath .githooks
   ```

2. **(Opsional) Kalau mau pakai Groq AI untuk matching yang lebih pintar:**
   ```powershell
   $env:GROQ_API_KEY = "gsk_xxx..."
   ```
   Tanpa ini, sistem tetap jalan penuh pakai keyword-matching (tanpa AI) — lihat bagian "Soal Groq" di bawah.

3. **Watch mode otomatis jalan** begitu kamu buka folder project ini di VS Code (sudah dikonfigurasi di `.vscode/tasks.json` dengan `runOn: folderOpen`). Kalau mau jalankan manual:
   ```powershell
   .\sync_docs.ps1 -Watch
   ```
   Atau sync sekali saja tanpa watch:
   ```powershell
   .\sync_docs.ps1
   ```

---

## Soal Groq (AI, opsional)

`sync_docs.ps1` punya dua mode matching:

- **Mode default (tanpa `-UseGroq`)**: keyword-matching murni, tanpa AI, tanpa internet. Cocok kalau task & roadmap share minimal 2 kata kunci yang sama. Ini **gratis, cepat, dan tidak pernah gagal** karena tidak bergantung ke layanan luar.
- **Mode `-UseGroq`**: coba panggil Groq API dulu (model cepat & gratis) untuk pencocokan yang lebih pintar (paham konteks, bukan cuma kata kunci). **Kalau API gagal/timeout/key kosong, otomatis jatuh ke keyword-matching** — tidak pernah membuat sync berhenti total.

Status mode yang dipakai selalu tercatat di `CURRENT_STATE.md` bagian `[AI SYNC]`, jadi kamu selalu tahu apakah sync barusan pakai AI atau fallback.

---

## Kenapa Roadmap → Kanban TIDAK Otomatis (Satu Arah Saja)

Sengaja. Kalau kamu edit Roadmap manual (nambah rencana baru), itu **tidak** otomatis bikin task Kanban. Alasannya: breakdown dari "rencana satu baris" jadi "task actionable dengan Target + Langkah Pertama" butuh keputusan kamu sendiri — itu bukan hal yang bisa ditebak otomatis dengan baik oleh script atau bahkan AI kecil seperti Groq. Sebagai gantinya, item Roadmap yang belum ada task Kanban-nya akan **diingatkan** di `CURRENT_STATE.md` bagian `[REMINDER]`, supaya tidak ada yang kelupaan — tapi kamu yang putuskan mau dibuatkan task-nya atau belum.

---

## Kalau Ada Ide Baru Mendadak (Di Luar Rencana)

Cukup ketik task baru langsung di Kanban (GUI Godot), isi Target + Langkah Pertama seperti biasa. Tidak perlu tag khusus, tidak perlu edit dokumen manapun. Begitu task itu selesai dan di-drag ke Done:
- Kalau mirip sesuatu yang sudah direncanakan di Roadmap → otomatis match & dicentang.
- Kalau benar-benar baru/di luar rencana → otomatis masuk ke section "Di Luar Rencana Awal" di Roadmap, jadi tetap tercatat tanpa mengganggu checklist fase yang sudah terstruktur.

---

## File-File Terkait

- `sync_docs.ps1` — mesin utama (baca kanban + git, tulis Roadmap + CURRENT_STATE)
- `add_task.ps1` — tambah task dari terminal (opsional, kamu bisa tetap ketik langsung di GUI kanban)
- `check_deadcode.ps1` — deteksi dead code (dipanggil otomatis oleh pre-commit hook)
- `.githooks/pre-commit` + `.githooks/pre-commit.ps1` — blokir commit kalau ada dead code
- `.githooks/post-commit` + `.githooks/post-commit.ps1` — auto-sync setelah commit
- `.vscode/tasks.json` — tombol manual untuk sync & watch mode
