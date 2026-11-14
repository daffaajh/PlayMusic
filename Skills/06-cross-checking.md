# Skill: Cross-Checking & System Integrity Audit

## Tujuan
Memastikan perubahan kode tidak menimbulkan bug regresi, memory leak, konflik dependensi, atau rusaknya alur data antar-komponen.

## Audit Pra-Pengiriman
1. **Integrasi Dependensi & Kompatibilitas Pemanggil:**
   - Cek seluruh pemanggil fungsi/komponen yang diubah di seluruh repository agar tidak timbul breaking changes.
   - Pastikan package yang di-import sudah terdaftar resmi pada dependency manager project.
2. **Edge Cases & Asynchronous Handling:**
   - Validasi nilai kosong (`null`, `undefined`, NaN, array/objek kosong).
   - Validasi aliran async: pastikan tidak ada unhandled promise rejection, race condition, atau data mutation saat fetch paralel.
3. **State Consistency & Performa:**
   - Pastikan perubahan reactive state tidak menimbulkan circular update, infinite re-render, atau memory leak.
4. **Housekeeping & Sinkronisasi Memori:**
   - Periksa file terkait di `Skills/systemAi/pemahaman/` untuk memastikan modul tetap sinkron.
   - Bersihkan/hapus file `.txt` task di `Skills/systemAi/progres/` yang sudah terselesaikan.