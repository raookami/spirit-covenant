# WORKFLOW — Cara Dokumentasi Project Ini Bekerja

> Dokumen ini menjelaskan bagaimana Blueprint, Roadmap, Current State, dan Kanban saling terhubung. Sistem ini **100% Otomatis Dua Arah**. Kamu hanya perlu menyentuh Kanban.

---

## Peta Peran Tiap Dokumen

| Dokumen | Isi | Siapa yang edit | Kapan berubah |
|---|---|---|---|
| `SPIRIT_COVENANT_BLUEPRINT.md` | **Tujuan & visi** — lore, karakter, mekanik inti | Kamu, manual, jarang | Hanya kalau visi besar game berubah |
| `SPIRIT_COVENANT_ROADMAP.md` | **Rencana per fase** — checklist fitur besar | **Otomatis** oleh `sync_docs.ps1` | Setiap kali ada task Kanban Done |
| `CURRENT_STATE.md` | **Snapshot kondisi sekarang** — git log, task aktif | **Otomatis sepenuhnya** | Setiap commit, atau setiap kanban berubah |
| `kanban_tasks_data.kanban` | **Task granular** — satu-satunya tempat kamu ketik ide | Kamu, lewat GUI kanban di Godot | Kapan saja kamu mau |

**Aturan emas:** Blueprint gak boleh ada checklist progress. Roadmap gak boleh ada detail super teknis. Current State gak boleh diedit manual. Kamu cuma perlu sentuh **Kanban**.

---

## Alur Otomasi (Dua Arah)
