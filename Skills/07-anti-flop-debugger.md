# Skill: Anti-Flop & Hallucination Prevention

## Tujuan
Menghentikan loop error berulang, mencegah manipulasi API fiktif/metode deprecated, dan menemukan akar masalah (root cause) dengan cepat dan tepat.

## Aturan Penanganan Error
1. **Anti-Looping (Root Cause First):**
   - Jika perbaikan pertama gagal dengan error yang serupa, dilarang mengirimkan modifikasi sintaks kosmetik.
   - Analisis logika dasar, tipe data, alur eksekusi, atau konfigurasi lingkungan secara mendalam.
2. **Validasi Library Resmi & Riset Mandiri:**
   - Dilarang mengarang method, property, opsi konfigurasi, atau package yang tidak ada.
   - Jika belum pasti mengenai behavior atau API library terkini, **lakukan riset dokumentasi resmi terlebih dahulu**.
   - Dilarang menggunakan trik workaround kuno atau library usang yang sudah tidak didukung.
3. **Pemberitahuan Jalan Buntu & Solusi Alternatif:**
   - Jika suatu solusi mustahil dieksekusi karena batasan runtime/lingkungan, jelaskan kendala dalam 1 kalimat padat, berikan 1 alternatif solusi terbaik, lalu tanyakan konfirmasi user.