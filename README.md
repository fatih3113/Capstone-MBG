# Foodler – Aplikasi Deteksi & Analisis Gizi MBG

Aplikasi mobile untuk mendeteksi komponen makanan ompreng MBG, menganalisis kandungan gizi, dan melaporkan preferensi makanan siswa.

---

## Teknologi

| Layer | Stack |
|-------|-------|
| **Mobile** | Flutter + Dart |
| **Backend** | Node.js + Express + TypeScript |
| **Database** | PostgreSQL + Prisma ORM |
| **State Management** | Provider (Flutter) |
| **Navigasi** | GoRouter |
| **Dashboard Web** | HTML + CSS + Vanilla JS (Chart.js) |

---

## Struktur Proyek

```
Project-Capstone/
├── backend/              # Express API
│   ├── src/
│   │   ├── controllers/  # auth, food, scan, report, admin
│   │   ├── routes/       # semua endpoint API
│   │   ├── middleware/   # auth, admin, error, validation
│   │   └── utils/
│   └── prisma/
│       ├── schema.prisma
│       └── manual_migration_add_reports_and_role.sql
├── frontend/             # Flutter mobile app
│   └── lib/
│       ├── core/         # constants, theme, router, network
│       ├── features/     # scan, report, history, menu, profile
│       ├── data/         # models, services
│       └── providers/    # state management
└── admin-dashboard/      # Dashboard web admin (HTML/JS)
    ├── index.html
    ├── styles.css
    └── app.js
```

---

## Cara Menjalankan

### 1. Prasyarat

- Node.js v18+
- PostgreSQL 14+ (berjalan di localhost:5432)
- Flutter SDK 3.x
- Database bernama `mbg_nutrition_db`

### 2. Setup Backend

```bash
cd backend
npm install

# Buat database PostgreSQL
# CREATE DATABASE mbg_nutrition_db;

# Jalankan migrasi
node node_modules\prisma\build\index.js migrate dev --name init

# Atau jika database sudah ada, jalankan SQL manual:
# psql -U postgres -d mbg_nutrition_db -f prisma/manual_migration_add_reports_and_role.sql

# Generate Prisma Client
node node_modules\prisma\build\index.js generate

# Seed data awal
node node_modules\ts-node\dist\bin.js src/database/seed.ts

# Jalankan server
npm run dev
# Server berjalan di http://localhost:3000
```

### 3. Setup Flutter Mobile

```bash
cd frontend
flutter pub get
flutter run
```

### 4. Buka Dashboard Web Admin

Buka file `admin-dashboard/index.html` langsung di browser atau gunakan Live Server.

- URL backend default: `http://localhost:3000/api/v1`
- Login: `admin@mbg.test` / `password123`

---

## Akun Demo

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@mbg.test` | `password123` |
| **Siswa** | `siswa@mbg.test` | `password123` |

---

## Endpoint API Utama

### Auth
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`

### Scan & Prediksi
- `POST /api/v1/predictions/classify` — Upload gambar, deteksi makanan
- `GET  /api/v1/scan-history` — Riwayat scan

### Report MBG (Siswa)
- `POST /api/v1/reports/menu-requests` — Kirim usulan menu
- `GET  /api/v1/reports/menu-requests/my` — Riwayat usulan saya
- `POST /api/v1/reports/food-ratings` — Beri rating makanan
- `GET  /api/v1/reports/food-ratings/ranking` — Ranking makanan favorit
- `POST /api/v1/reports/food-feedbacks` — Kirim feedback makanan

### Admin Only
- `GET  /api/v1/admin/dashboard` — Ringkasan dashboard
- `GET  /api/v1/admin/nutrition-reports` — Laporan gizi scan
- `GET  /api/v1/admin/nutrition-reports/export` — Ekspor CSV gizi
- `GET  /api/v1/reports/menu-requests` — Semua usulan menu
- `PATCH /api/v1/reports/menu-requests/:id/status` — Update status usulan
- `GET  /api/v1/reports/food-feedbacks/summary` — Ringkasan feedback
- `GET  /api/v1/reports/*/export` — Ekspor CSV setiap laporan

---

## Fitur Mobile

### 1. Scan Makanan (Kamera/Galeri)
- Deteksi 8 kelas: nasi, ayam, telur, ikan, tahu, tempe, sayur, buah
- Tampilkan confidence score
- Koreksi hasil deteksi secara manual

### 2. Analisis Gizi
- Estimasi kalori, protein, karbohidrat, lemak, serat
- ⚠️ Nilai gizi adalah **estimasi** berdasarkan data komposisi pangan (TKPI/referensi internal), bukan analisis laboratorium

### 3. Perbandingan AKG MBG
- Dropdown pilihan sasaran: TK/PAUD, SD 1–3, SD 4–6, SMP, SMA, Balita, Ibu Hamil, Ibu Menyusui
- Perbandingan hasil scan vs rentang AKG MBG (Di Bawah / Dalam Rentang / Di Atas)
- Update instan tanpa perlu ulang scan

### 4. Report MBG (3 tab)
- **Tab A: Usulan Menu** — Kirim dan pantau status usulan menu baru
- **Tab B: Makanan Favorit** — Rating 1–5 bintang + ranking makanan terfavorit
- **Tab C: Feedback** — Penilaian sensorik (rasa/tekstur/aroma/porsi/kepuasan) + status konsumsi (pilihan pengguna)

---

## Dashboard Web Admin

### Halaman 1: Dashboard Ringkasan
- Kartu statistik: total usulan, rating, feedback, scan, rata-rata rating
- Grafik: makanan favorit, distribusi konsumsi, status usulan
- Tabel scan gizi terbaru

### Halaman 2: Usulan Menu
- Usulan yang dikelompokkan (menu terpopuler)
- Semua usulan dengan filter status dan pencarian
- Update status + catatan admin langsung dari tabel
- Ekspor CSV

### Halaman 3: Makanan Favorit
- Grafik batang ranking + jumlah suara
- Tabel lengkap dengan rata-rata rating dan bintang
- Filter tanggal + ekspor CSV

### Halaman 4: Feedback
- Distribusi status konsumsi (pilihan pengguna)
- Grafik sentimen kepuasan makanan
- Makanan yang sering dilaporkan hampir tidak dimakan
- Ekspor CSV

### Halaman 5: Laporan Gizi
- Tabel hasil scan dengan estimasi gizi per siswa
- Filter tanggal dan sasaran AKG
- Ekspor CSV

---

## Catatan Penting

> ⚠️ **Estimasi Gizi**: Semua nilai kandungan gizi dalam aplikasi adalah **estimasi** berdasarkan data komposisi pangan (referensi TKPI/internal Foodler). Nilai ini bukan hasil pemeriksaan laboratorium dan tidak dapat digunakan sebagai diagnosis medis atau rekomendasi gizi resmi.

> ⚠️ **AKG MBG**: Nilai target AKG MBG dalam aplikasi adalah estimasi berdasarkan referensi internal. Perlu verifikasi terhadap sumber resmi (Permenkes AKG atau regulasi MBG terbaru) sebelum digunakan sebagai rekomendasi resmi.

> ⚠️ **Status Konsumsi**: Data "sisa makanan" di aplikasi merupakan **pilihan pengguna** (habis/sebagian/hampir tidak), bukan pengukuran berat sisa makanan yang sebenarnya.
