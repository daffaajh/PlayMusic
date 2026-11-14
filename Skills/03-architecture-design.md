# Skill: Modern Architecture & Anti-AI Human Design

## Tujuan
Memastikan struktur kode berstandar senior engineer dengan paradigma modern, sinkron dengan memori `Skills/systemAi/`, serta menghasilkan UI/UX berkelas karya desainer profesional (bukan template klise AI).

## 1. Standar Arsitektur Modern & Mutakhir
- **Metode & Pola Terbaru:** Gunakan standar industri terkini (modern ES/TypeScript, functional/declarative idioms, immutable state management, clean architecture).
- **Riset Sebelum Menulis:** Jika belum yakin dengan versi API atau library terbaru, **lakukan riset dokumentasi terlebih dahulu**. Dilarang keras memakai metode kuno (legacy patterns, `var`, lifecycle deprecated, synchronous I/O blocking, wrapper callback kuno).
- **Separation of Concerns:** Pisahkan state, business logic, data access, dan presentation layer secara ketat.
- **Minimal External Deps:** Utamakan fitur native platform (Web API, modern standard library) sebelum menambah paket pihak ketiga.
- **Sinkronisasi Konteks:** Catat setiap arsitektur baru di `Skills/systemAi/pemahaman/`.

## 2. Standar Desain UI Anti-AI (Human-Crafted Aesthetics)
- **Larangan Keras (AI Aesthetic Tropes):**
  - **Warna Klise:** Dilarang menggunakan background gelap pekat dengan aksen glow neon, gradien ungu-ke-biru/cyan klise, atau warna jenuh generik tanpa kurasi.
  - **Bentuk Seragam:** Dilarang memakai border-radius bulat ekstrem (*full-rounded pills*) di semua tombol, badge, dan container.
  - **Komponen Kosong:** Dilarang menumpuk card melayang berulang tanpa hirarki fungsi nyata atau card transparan (glassmorphism murah) yang mengorbankan readability.
- **Standar Wajib (Desain Profesional Manusia):**
  - **Palet Warna Terkurasi:** Gunakan skala netral premium (zinc, slate, stone, warm neutral) dengan 1–2 warna aksen fungsional yang memiliki kontras tajam (lulus uji aksesibilitas WCAG AA/AAA).
  - **Hirarki Tipografi Human-Crafted:** Terapkan tipografi modern (Inter, Geist, Plus Jakarta Sans, Outfit, SF Pro) dengan kontras tegas antara title, label, dan body text (atur weight 400/500/600, leading proporsional, tracking pas).
  - **Struktur & Whitespace:** Terapkan grid sistem 4px/8px, padding longgar yang terencana, dan border halus (1px border beropasitas rendah 8–15%) untuk memisahkan section.
  - **Interaktivitas Nyata:** Berikan state interaksi mikro yang halus dan elegan (hover, active, focus-visible, disabled, skeleton loading).