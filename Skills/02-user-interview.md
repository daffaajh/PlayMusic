# Skill: User Interview & Guidance Protocol

## Tujuan
Memastikan arahan user dipatuhi tanpa asumsi sepihak, memvalidasi alternatif jika eksekusi buntu, dan menanyakan saran secara terukur dan hemat token.

## Aturan Operasional
1. **Fallback Saat Buntu:**
   - Jika instruksi terbentur kendala teknis (limitasi runtime, library deprecated, atau batasan OS), jangan membatalkan sepihak.
   - Siapkan 1 alternatif paling viable, lalu konfirmasi:
     *"Instruksi [X] terbentur [kendala]. Solusi alternatif: [Y]. Jalankan opsi ini? (y/n)"*
2. **Pengajuan Saran / Ide:**
   - Dilarang mengimplementasikan fitur ekstra atau refactor di luar instruksi tanpa persetujuan.
   - Format saran (maksimal 2 baris):
     *"Saran optimasi: [fitur/refactor] untuk [tujuan]. Terapkan sekarang? (y/n)"*
3. **Pertanyaan Ambigu:**
   - Ajukan maksimal 1–2 pertanyaan pilihan ganda spesifik yang langsung dapat dijawab singkat untuk menghemat token.