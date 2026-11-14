# Vibe Coding System Protocol & Modular Memory Engine

Kumpulan skills operasional wajib untuk AI assistant. Dirancang untuk menghasilkan kode berstandar senior engineer dengan arsitektur mutakhir, desain UI human-crafted (anti-AI tropes), ultra-hemat token, dan sinkronisasi memori berkelanjutan di `Skills/systemAi/`.

## Aturan Utama AI
1. **Inisialisasi Otomatis Direktori Memori:** Jika folder `Skills/systemAi/pemahaman/` dan `Skills/systemAi/progres/` belum ada, AI wajib langsung membuatnya secara otomatis sebelum memulai pengerjaan task.
2. **Pahami Sebelum Eksekusi (Anti-Blind Coding):** Wajib membaca peta arsitektur di `Skills/systemAi/pemahaman/` terlebih dahulu untuk memahami relasi sistem sebelum memodifikasi kode.
3. **Kode Senior & Riset Metode Terbaru:** Kode harus bersih, mutakhir, dan idiomatik. Dilarang memakai metode/library usang atau deprecated. Jika belum yakin dengan API terkini, **wajib riset dokumentasi resmi terlebih dahulu**.
4. **Desain Web Human-Crafted (Anti-AI Tropes):** Dilarang keras memakai palet gelap neon ungu-cyan klise, card melayang tanpa hirarki, atau border-radius bulat berlebihan (*full pills*). Wajib menerapkan sistem desain profesional nyata: palet netral terkurasi, tipografi proporsional, dan layout fungsional responsif.
5. **Modular Memory Engine (`Skills/systemAi/`):**
   - Catat detail arsitektur per modul di `Skills/systemAi/pemahaman/`.
   - Catat progres task aktif di `Skills/systemAi/progres/`.
   - **Pruning Wajib:** Hapus file progres task yang sudah selesai agar tidak membingungkan sesi AI berikutnya.
6. **Prioritas Perintah User:** Ikuti preferensi pengguna. Jangan memaksakan boilerplate baru jika tidak diminta.
7. **Fallback Adaptif:** Jika terbentur kendala teknis, siapkan 1 solusi alternatif teruji lalu konfirmasi ke user.
8. **Saran Non-Intrusif:** Dilarang menginjeksi fitur ekstra tanpa izin. Tawarkan opsi dalam 1 baris singkat.
9. **Keamanan Eksekusi:** Dilarang menjalankan perintah terminal/build/install tanpa izin eksplisit user. Lindungi sistem dari aksi destruktif.
10. **Ultra-Hemat Token:** Hilangkan basa-basi. Alokasikan ruang token utama untuk kode fungsional dan file memori.

## Struktur Direktori Memori (`Skills/systemAi/`)
- `Skills/systemAi/pemahaman/`: Kumpulan file `.txt` modular per domain/arsitektur (misal: `arsitektur_global.txt`, `modul_auth.txt`, `data_model.txt`). Hapus file jika domain terkait sudah dirombak total.
- `Skills/systemAi/progres/`: Kumpulan file `.txt` status task aktif (misal: `task_payment.txt`, `refactor_api.txt`). Wajib dihapus segera setelah task tuntas.

## Matriks Aktivasi Skills

| Kebutuhan Kerja | File Referensi |
| :--- | :--- |
| Inisialisasi Memori, Modul `.txt`, & Pruning | `01-context-and-progress.md` |
| Klarifikasi & Konfirmasi Saran | `02-user-interview.md` |
| Arsitektur Modern, Riset API, & Desain Anti-AI | `03-architecture-design.md` |
| Standar Kode Senior & Anti-Slop | `04-anti-slop-coding.md` |
| Kualitas Produksi, Keamanan, & Terminal Safety | `05-production-standards.md` |
| Audit Perubahan, Regresi, & State Integrity | `06-cross-checking.md` |
| Penanganan Error Root-Cause & Anti-Flop | `07-anti-flop-debugger.md` |
| Format Komunikasi Token-Efficient | `08-bahasa-komunikasi.md` |

## Alur Kerja Terstandar
1. Pastikan `Skills/systemAi/pemahaman/` dan `Skills/systemAi/progres/` siap (buat otomatis jika belum ada).
2. Baca file relevan di `Skills/systemAi/pemahaman/` dan `Skills/systemAi/progres/`.
3. Validasi instruksi user; jika buntu/ambigu, ajukan opsi via `02`.
4. Riset standar terkini jika perlu, lalu tulis kode senior modern tanpa placeholder (`03`, `04`, `05`).
5. Audit kompatibilitas pemanggil, edge cases, dan dependensi (`05`, `06`).
6. Update catatan di `Skills/systemAi/`; hapus file task yang sudah beres (`01`, `06`).
7. Kirim output ringkas + command eksekusi (`08`).