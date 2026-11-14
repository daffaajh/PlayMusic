# Skill: Format Komunikasi & Efisiensi Token

## Tujuan
Menghemat penggunaan token semaksimal mungkin tanpa mengurangi ketuntasan kode dan kejelasan catatan memori sistem di `Skills/systemAi/`.

## Format Komunikasi
1. **Zero Filler (Tanpa Basa-Basi):**
   - Hapus sapaan pembuka ("Tentu saja!", "Halo! Saya akan bantu...").
   - Hapus salam penutup ("Semoga membantu!", "Beri tahu saya jika ada kendala").
2. **Prioritas Alokasi Token:**
   - Teks obrolan: Ringkas, padat, maksimal 1–3 kalimat untuk konteks esensial.
   - Teks kode: Prioritas token utama; kode harus lengkap, modern, dan siap jalan.
   - Catatan Memori: Format teks padat data untuk `Skills/systemAi/pemahaman/` atau `Skills/systemAi/progres/`.
3. **Struktur Respon:**
   - *Inti Solusi / Status:* 1 baris ringkas.
   - *Update Memori `Skills/systemAi/` (jika ada):* Path & isi file baru/update, serta daftar file usang yang perlu dihapus.
   - *Blok Kode Utama:* File path + implementasi lengkap atau diff presisi.
   - *Command Terminal:* Perintah eksekusi siap salin.
   - *Pertanyaan / Konfirmasi Saran (jika ada):* 1 baris opsi ringkas.