# 🍱 MBG Nutrition - Capstone Project

**Sistem Identifikasi dan Analisis Kandungan Gizi Menu Makan Bergizi Gratis (MBG) Berbasis Mobile**

---

## 📁 Struktur Proyek

```
d:\Project-Capstone\
├── frontend/              ← Aplikasi Mobile (Flutter/Dart)
│   ├── lib/
│   │   ├── core/          ← Theme, Router, Constants, Network, Utils
│   │   ├── data/          ← Models, Services, Dummy Data
│   │   ├── ml/            ← ML Service, Image Processing
│   │   ├── providers/     ← State Management (Provider)
│   │   ├── features/      ← 16 UI Screens
│   │   └── shared/        ← Widgets, Helpers
│   ├── pubspec.yaml
│   └── test/
│
├── backend/               ← REST API (Node.js + TypeScript + Express)
│   ├── src/
│   │   ├── controllers/   ← Business logic
│   │   ├── routes/        ← API endpoints
│   │   ├── middleware/     ← Auth, Validation, Error handling
│   │   ├── utils/         ← Logger, API Response
│   │   └── tests/         ← Integration tests (Jest + Supertest)
│   ├── prisma/
│   │   └── schema.prisma  ← Database schema (PostgreSQL)
│   ├── package.json
│   └── tsconfig.json
│
└── README.md
```

---

## 🎓 Integrasi 8 Mata Kuliah

| # | Mata Kuliah | Implementasi |
|---|---|---|
| 1 | **Mobile Programming** | Flutter + Dart, Provider, GoRouter, Material 3 |
| 2 | **Komputasi & Aplikasi Cloud** | Express.js REST API, Prisma ORM, PostgreSQL, Deployment-ready |
| 3 | **Framework Programming** | Express.js (Backend), Flutter Framework (Frontend) |
| 4 | **Data Warehouse** | DailyNutrition aggregate table, statistik mingguan, top-foods analytics |
| 5 | **Pengujian Perangkat Lunak** | Jest + Supertest (Backend), Flutter Test (Frontend) |
| 6 | **Machine Learning** | TFLite food classification, Strategy pattern (`MLService`) |
| 7 | **Pemrograman Sistem Cerdas** | Rule-based nutrition recommendation engine |
| 8 | **Pengolahan Citra Digital** | Histogram equalization, image resizing, normalization, pixel processing |

---

## 🚀 Quick Start

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

### Backend (Express)
```bash
cd backend
cp .env.example .env
# Isi DATABASE_URL di .env
npm install
npx prisma migrate dev
npm run seed
npm run dev
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register pengguna baru |
| POST | `/api/v1/auth/login` | Login |
| GET | `/api/v1/foods` | Daftar makanan MBG |
| GET | `/api/v1/foods/:id` | Detail makanan + gizi |
| GET | `/api/v1/mbg-menu` | Menu mingguan MBG |
| GET | `/api/v1/scan-history` | Riwayat scan pengguna |
| POST | `/api/v1/scan-history/save` | Simpan hasil scan |
| GET | `/api/v1/stats/weekly` | Statistik gizi mingguan |
| GET | `/api/v1/stats/top-foods` | Makanan paling sering dikonsumsi |
| GET | `/health` | API health check |

---

## 🛠️ Tech Stack

**Frontend:** Flutter 3.x · Dart 3.x · Provider · GoRouter · fl_chart · Hive · image_picker · tflite_flutter

**Backend:** Node.js · TypeScript · Express.js · Prisma ORM · PostgreSQL · JWT · Multer · Winston · Jest

---

*© 2025 Capstone Project*
