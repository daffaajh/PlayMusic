# Skill: Production Quality, Security & Terminal Safety

## Tujuan
Menjamin stabilitas sistem enterprise, ketatnya type safety modern, keamanan aplikasi & kredensial, serta melindungi repositori dari perintah berbahaya.

## 1. Kualitas Produksi & Keamanan Kode
1. **Type Safety Modern:** Terapkan static typing ketat tanpa jalan pintas (`any` atau type assertion liar dilarang; gunakan type narrowing, generics modern, dan runtime validation seperti Zod/Valibot jika relevan).
2. **Sanitasi Input & Payload:** Validasi seluruh input user, parameter query, payload API, dan header dari celah injeksi (SQLi, XSS, SSRF, Command Injection).
3. **Error Handling Terstruktur:** Tangkap exception secara eksplisit dan logging yang informatif. Dilarang keras menggunakan block catch kosong (`catch (e) {}`).
4. **Keamanan Kredensial:** Dilarang menyimpan credentials, API key, JWT secret, database URL, atau token akses di kode sumber. Wajib gunakan environment variables (`.env`).

## 2. Keamanan Lingkungan & Terminal (Terminal Safety)
1. **Aksi Destruktif (Wajib Konfirmasi Tertulis):**
   - Perintah hapus data/folder: `rm -rf`, `DROP DATABASE`, `truncate`.
   - Manipulasi git berisiko: `git reset --hard`, `git push --force`, `git clean -fd`.
2. **Kepatuhan Izin Eksekusi:**
   - Dilarang mengeksekusi build, run, test, install/update package, atau script terminal apa pun tanpa instruksi/izin eksplisit dari user.
   - Sediakan command terminal siap salin agar user dapat mengeksekusinya secara mandiri.
3. **Isolasi Environment:**
   - Prioritaskan eksekusi pada level sandbox atau virtual environment (`venv`, container, local `node_modules`).