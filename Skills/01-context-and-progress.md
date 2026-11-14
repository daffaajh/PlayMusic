# Skill: Modular Memory & Lifecycle Management

## Tujuan
Mencegah AI salah paham arsitektur atau hilang arah dengan membagi konteks ke dalam file teks modular di `Skills/systemAi/` serta menghapus artefak yang sudah usang.

## Inisialisasi Otomatis
- Jika folder `Skills/systemAi/pemahaman/` dan `Skills/systemAi/progres/` belum ada, AI **wajib langsung membuatnya secara otomatis** sebelum memulai eksekusi task apa pun.

## 1. Pemahaman Modular (`Skills/systemAi/pemahaman/`)
- **Granularitas File:** Jangan satukan semua pemahaman ke satu file raksasa. Buat file `.txt` terpisah per domain teknis, contoh:
  - `Skills/systemAi/pemahaman/arsitektur_global.txt` (overview, stack modern, & konvensi)
  - `Skills/systemAi/pemahaman/modul_auth.txt` (alur autentikasi, session, & security)
  - `Skills/systemAi/pemahaman/data_model.txt` (relasi entitas, skema, & state)
- **Kewajiban AI:** Sebelum mengubah logika di domain tertentu, baca file `.txt` terkait. Perbarui isi file jika ada arsitektur baru.

## 2. Pelacakan Progres Granular (`Skills/systemAi/progres/`)
- Gunakan file teks terpisah untuk task aktif (contoh: `progres_fitur_auth.txt`, `status_refactor_api.txt`).
- **Format Isi File:**
  ```text
  TASK: <nama task/fitur>
  LAST_UPDATE: <tanggal/waktu>
  STATUS: [ACTIVE / BLOCKED / READY_TO_TEST]
  DONE:
  - <komponen/perubahan yang sudah dieksekusi>
  NEXT_STEPS:
  - <langkah lanjutan untuk AI berikutnya>
  CRITICAL_NOTES:
  - <catatan teknis khusus agar tidak miskom>
  ```

## 3. Pruning & Lifecycle Management
- **Pembersihan Rutin:** File `.txt` di `Skills/systemAi/progres/` yang task-nya telah selesai/di-merge dan tidak lagi mempengaruhi sesi aktif wajib dihapus/di-purge.
- **Pembaruan Konteks:** Hapus atau perbarui file di `Skills/systemAi/pemahaman/` jika modul terkait telah dirombak total agar AI sesi berikutnya tidak terdistraksi konteks usang.