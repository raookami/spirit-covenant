# WORKFLOW — Cara Dokumentasi Project Ini Bekerja

> Dokumen ini menjelaskan bagaimana Blueprint, Roadmap, Current State, dan Kanban saling terhubung. Sistem ini **Otomatis Dua Arah**. Untuk urusan task harian, kamu cukup menyentuh Kanban.

---

## Peta Peran Tiap Dokumen

| Dokumen | Isi | Siapa yang edit | Kapan berubah |
|---|---|---|---|
| `SPIRIT_COVENANT_BLUEPRINT.md` | **Tujuan & visi** — lore, karakter, mekanik inti | Kamu, manual, jarang | Hanya kalau visi besar game berubah |
| `SPIRIT_COVENANT_ROADMAP.md` | **Rencana per fase** — checklist fitur besar | **Otomatis** oleh `sync_docs.ps1` | Setiap kali ada task Kanban `Done` |
| `CURRENT_STATE.md` | **Snapshot kondisi sekarang** — git log, task aktif | **Otomatis sepenuhnya** | Setiap commit, atau saat `sync_docs.ps1` jalan |
| `kanban_tasks_data.kanban` | **Task granular** — satu-satunya tempat kamu ketik ide/task | Kamu, lewat GUI kanban di Godot | Kapan saja kamu mau |

**Aturan emas:** Blueprint tidak boleh berisi checklist progress. Roadmap tidak boleh berisi detail coding yang terlalu teknis. `CURRENT_STATE.md` **tidak boleh diedit manual**. Kamu cukup mengurus **Kanban**.

---

## Alur Otomasi (Dua Arah)

1. **Roadmap → Kanban (`sync_docs.ps1`):**
   - Setiap item checklist `[ ]` di `SPIRIT_COVENANT_ROADMAP.md` yang belum masuk ke Kanban otomatis dibuatkan kartunya di kolom **Todo** lengkap dengan tag `(ID: ...)`.
2. **Kanban → Roadmap (`sync_docs.ps1`):**
   - Saat kamu memindahkan kartu ke kolom **Done** di plugin Kanban Godot, `sync_docs.ps1` mencocokkan task tersebut ke item Roadmap lalu otomatis mencentang `[x]` pada baris yang sesuai.
   - Jika ada kartu **Done** yang memang ide baru di luar rencana awal, judulnya otomatis dicatat ke bagian `Di Luar Rencana Awal` di Roadmap.
3. **Update Snapshot (`CURRENT_STATE.md`):**
   - `sync_docs.ps1` mengambil 3 commit Git terakhir dan daftar kartu di kolom **Doing** & **Todo**, lalu menuliskannya ulang ke `docs/CURRENT_STATE.md`.
   - *(Catatan: Gunakan `sync_docs.ps1` sebagai script utama; hindari menjalankan `update_state.ps1` agar format `CURRENT_STATE.md` tidak berubah-ubah).*
4. **Script Bantu & Git Hooks:**
   - `add_task.ps1` — menambah task baru ke kolom **Todo** Kanban langsung lewat terminal.
   - `.githooks/pre-commit` — otomatis menjalankan `check_deadcode.ps1` (`gdshrapt`) sebelum commit dan memblokir commit jika masih ada *dead code* di skrip buatan sendiri.
   - `.githooks/post-commit` — otomatis menjalankan `sync_docs.ps1` setelah commit berhasil (jika working tree ikut ter-update di dokumen, cukup commit ulang jika ingin bersih).