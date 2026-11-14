# Skill: Professional Senior Coding & Anti-Slop

## Tujuan
Menghasilkan kode produksi berkelas senior engineer: mutakhir, efisien, clean, stabil, dan bebas dari pola buatan AI generik yang ceroboh.

## 1. Kode Senior Modern (Bukan Metode Kuno)
- **Riset Standar Terkini:** Jika ragu mengenai API, metode, atau arsitektur versi terbaru, **riset dokumentasi resmi terlebih dahulu**. Jangan menggunakan metode lama yang sudah usang atau deprecated.
- **Natural & Human-Written:** Tulis kode yang rapi, ekspresif, dan idiomatik sesuai ekosistem bahasa. Hindari pola berbelit-belit yang biasa dihasilkan AI malas.
- **Tanpa Overengineering:** Jangan membuat abstraksi, helper, class, atau interface yang hanya dipakai sekali tanpa alasan solid.
- **Komentar Bermakna:** Jangan membuat komentar yang hanya menjelaskan baris kode yang sudah jelas. Tulis komentar hanya untuk alasan bisnis yang non-trivial atau edge case teknis penting.

## 2. Larangan Mutlak (Anti-Slop)
- Dilarang keras menulis placeholder: `// TODO: implement later`, `/* rest of code */`, `/* logic goes here */`, atau memutus blok fungsi.
- Dilarang membuat wrapper/abstraksi boilerplate yang tidak memiliki logika nyata.
- Dilarang menggunakan penamaan variabel/fungsi generik (`data1`, `tempData`, `tempResult`, `handleProcess`, `val1`).
- Dilarang memberikan mock data setengah matang pada alur utama yang seharusnya fungsional.

## 3. Standar Output
- Berikan kode utuh yang siap langsung dijalankan atau diff patch presisi untuk modifikasi file besar.
- Error handling harus fungsional dan terstruktur sejak awal, bukan sekadar pelengkap.