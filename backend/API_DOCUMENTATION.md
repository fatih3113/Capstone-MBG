# API Documentation — MBG Nutrition Backend

**Base URL:** `http://localhost:3000/api/v1`  
**Format response:** JSON  
**Autentikasi:** Bearer Token (JWT) di header `Authorization: Bearer <token>`

> [!NOTE]
> Endpoint bertanda 🔓 bersifat publik (tidak butuh token).  
> Endpoint bertanda 🔑 butuh token pengguna biasa.  
> Endpoint bertanda 🛡️ butuh token admin (role `admin`).

---

## Daftar Isi

1. [Auth](#1-auth)
2. [Users](#2-users)
3. [SPPG](#3-sppg)
4. [Schools](#4-schools)
5. [Foods](#5-foods)
6. [Nutrition](#6-nutrition)
7. [Scan History & Prediction](#7-scan-history--prediction)
8. [MBG Menu](#8-mbg-menu)
9. [Menu Requests](#9-menu-requests)
10. [Food Ratings](#10-food-ratings)
11. [Food Feedbacks](#11-food-feedbacks)
12. [Stats](#12-stats)
13. [Reports (Admin)](#13-reports-admin)
14. [Notifications](#14-notifications)

---

## 1. Auth

### 🔓 POST `/auth/register`

Mendaftarkan pengguna baru (siswa sekolah atau peserta posyandu).

**Request Body:**

```json
{
  "name": "Budi Santoso",
  "email": "budi@example.com",
  "password": "password123",
  "gender": "L",
  "age": 14,
  "class_": "8A",
  "allergies": ["dairy", "nuts"],
  "allergy_other": "",
  "allergy_filled": true,

  // Pilih salah satu cara menentukan SPPG:
  "sppg_code": "SPPG-AB1234",        // ← BARU: kode SPPG (direkomendasikan)
  "sppg_id": "uuid-sppg-lama",       // ← LAMA: backward compat, masih diterima

  // Pilih salah satu cara menentukan lembaga:
  "school_id": "uuid-sekolah",       // lembaga sudah terdaftar di SPPG ini

  "new_institution": {               // atau tambah lembaga baru
    "name": "SDN 01 Jakarta",
    "level": "SD",                   // SD | SMP | SMA | SMK | Posyandu
    "city": "Jakarta Selatan"        // opsional
  }
}
```

**Aturan validasi:**
- Jika `sppg_code` dikirim: dicari SPPG dengan kode tersebut (APPROVED + ACTIVE)
- Jika `school_id` dikirim: lembaga harus milik SPPG yang ditemukan dari kode
- Jika `new_institution` dikirim: cari lembaga nama sama di SPPG itu, buat baru jika tidak ada
- `level` wajib untuk non-posyandu: `SD`, `SMP`, `SMA`, atau `SMK`
- Pembuatan user + lembaga baru dilakukan dalam satu transaksi database

**Response 201:**
```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "id": "uuid",
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "role": "student"
  }
}
```

**Response 409** — email sudah terdaftar  
**Response 422** — validasi gagal (level tidak valid, nama lembaga kosong, dll.) dengan pesan Bahasa Indonesia

---

### 🔓 POST `/auth/login`

Login pengguna dan mendapatkan token JWT.

**Request Body:**
```json
{
  "email": "budi@example.com",
  "password": "password123"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGci...",
    "user": {
      "id": "uuid",
      "name": "Budi Santoso",
      "email": "budi@example.com",
      "role": "student",
      "gender": "L",
      "age": 14,
      "class_": "8A",
      "schoolId": "uuid-sekolah",
      "sppgId": "uuid-sppg"
    }
  }
}
```

**Response 401** — email/password salah

---

### 🔑 POST `/auth/logout`

Logout pengguna (invalidasi token di server).

**Response 200:**
```json
{ "success": true, "message": "Logout berhasil" }
```

---

### 🔓 POST `/auth/forgot-password`

Kirim link reset password ke email.

**Request Body:** `{ "email": "budi@example.com" }`

**Response 200:** `{ "success": true, "message": "Email reset password telah dikirim" }`

---

### 🔓 POST `/auth/reset-password`

Reset password dengan token dari email.

**Request Body:** `{ "token": "reset-token", "password": "passwordBaru123" }`

**Response 200:** `{ "success": true, "message": "Password berhasil direset" }`

---

## 2. Users

### 🔑 GET `/users/profile`

Mendapatkan profil pengguna yang sedang login.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "gender": "L",
    "age": 14,
    "class_": "8A",
    "schoolId": "uuid",
    "sppgId": "uuid",
    "allergies": ["dairy"],
    "allergy_other": "",
    "profileImageUrl": null
  }
}
```

---

### 🔑 PUT `/users/profile/update`

Update profil pengguna.

**Request Body:** (semua opsional)
```json
{
  "name": "Budi Baru",
  "gender": "L",
  "age": 15,
  "class_": "9A",
  "allergies": ["nuts"],
  "allergy_other": "Kacang mete",
  "allergy_filled": true
}
```

**Response 200:** `{ "success": true, "message": "Profil berhasil diperbarui", "data": { ... } }`

---

### 🔑 POST `/users/profile/photo`

Upload foto profil (multipart/form-data).

**Form field:** `photo` (file gambar, maks 5 MB)

**Response 200:** `{ "success": true, "data": { "profileImageUrl": "https://..." } }`

---

### 🔑 DELETE `/users/profile`

Hapus akun pengguna yang sedang login.

**Response 200:** `{ "success": true, "message": "Akun berhasil dihapus" }`

---

## 3. SPPG

### 🔓 GET `/sppg/by-code/:kode`

Verifikasi kode SPPG saat registrasi. Kode secara otomatis di-trim dan diubah ke huruf besar.

> [!IMPORTANT]
> **Rate limit:** 20 permintaan per 15 menit per IP. Dibatasi untuk mencegah brute-force kode SPPG.

**Parameter URL:** `:kode` — kode SPPG, contoh: `SPPG-AB1234`

**Syarat SPPG yang dikembalikan:**
- `verificationStatus = APPROVED`
- `operationalStatus = ACTIVE`
- `isActive = true`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-sppg",
    "kode": "SPPG-AB1234",
    "nama": "SPPG Kecamatan Cilandak",
    "provinsi": "DKI Jakarta",
    "kabupaten_kota": "Jakarta Selatan",
    "kecamatan": "Cilandak",
    "kelurahan_desa": "Cilandak Barat"
  }
}
```

**Response 404:** `{ "success": false, "message": "Kode SPPG tidak ditemukan atau belum aktif" }`  
**Response 429:** Rate limit terlampaui

---

### 🔓 GET `/sppg/regions`

Mendapatkan daftar wilayah SPPG (untuk dropdown registrasi lama — masih tersedia untuk backward compat).

---

### 🔓 GET `/sppg`

Mendapatkan semua SPPG.

---

## 4. Schools

### 🔓 GET `/schools`

Mendapatkan daftar sekolah/posyandu.

**Query params (semua opsional):**

| Param | Tipe | Keterangan |
|---|---|---|
| `sppg_id` | string | Filter sekolah milik SPPG tertentu |
| `level` | string | Filter jenjang: `SD`, `SMP`, `SMA`, `SMK`, `Posyandu` |
| `search` | string | Cari nama sekolah |

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "SDN 01 Jakarta",
      "level": "SD",
      "city": "Jakarta Selatan",
      "sppgId": "uuid-sppg"
    }
  ]
}
```

---

### 🔓 GET `/schools/:id`

Mendapatkan detail satu sekolah/posyandu.

---

## 5. Foods

### 🔑 GET `/foods`

Mendapatkan semua data makanan.

**Response 200:** `{ "success": true, "data": [ { "id": "uuid", "name": "Nasi Putih", "calories": 180, ... } ] }`

---

### 🔑 GET `/foods/search`

Cari makanan berdasarkan nama.

**Query param:** `q` — kata kunci pencarian

---

### 🔑 GET `/foods/:id`

Detail satu makanan.

---

## 6. Nutrition

### 🔑 GET `/nutrition`

Data nutrisi berdasarkan beberapa makanan.

**Query param:** `foodIds` — array ID makanan (contoh: `?foodIds[]=id1&foodIds[]=id2`)

---

### 🔑 GET `/nutrition/food/:foodId`

Data nutrisi satu makanan.

---

### 🔑 GET `/nutrition/daily`

Ringkasan nutrisi harian pengguna (hari ini).

---

### 🔑 GET `/nutrition/weekly`

Ringkasan nutrisi mingguan pengguna.

---

### 🔑 GET `/nutrition/recommendation`

Rekomendasi nutrisi berdasarkan profil pengguna.

---

## 7. Scan History & Prediction

### 🔑 GET `/scan-history`

Riwayat scan makanan pengguna.

---

### 🔑 GET `/scan-history/:id`

Detail satu riwayat scan.

---

### 🔑 POST `/scan-history/save`

Simpan hasil scan.

**Request Body:** `{ "foodId": "uuid", "portion": 1.5, "date": "2026-11-14" }`

---

### 🔑 POST `/prediction/classify`

Klasifikasi gambar makanan (multipart/form-data).

**Form field:** `image` (file gambar)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "scanId": "uuid",
    "predictions": [
      { "foodId": "uuid", "foodName": "Nasi Putih", "confidence": 0.92 }
    ]
  }
}
```

---

### 🔑 GET `/prediction/scan/:scanId`

Semua prediksi untuk satu scan.

---

### 🔑 GET `/prediction/:id`

Detail satu prediksi.

---

## 8. MBG Menu

### 🔑 GET `/mbg-menu`

Menu MBG minggu ini.

---

### 🔑 GET `/mbg-menu/today`

Menu MBG hari ini.

---

### 🔓 GET `/mbg-menu/date/:date`

Menu MBG pada tanggal tertentu. Format: `YYYY-MM-DD`

---

## 9. Menu Requests

### 🔑 POST `/menu-requests`

Ajukan permintaan menu.

**Request Body:** `{ "menuName": "Soto Ayam", "reason": "Cocok untuk siswa" }`

---

### 🔑 GET `/menu-requests/my`

Daftar permintaan menu milik pengguna.

---

### 🔑 GET `/menu-requests/grouped`

Ringkasan permintaan menu dikelompokkan per jenis menu.

---

### 🛡️ GET `/menu-requests`

Semua permintaan menu (admin).

---

### 🛡️ GET `/menu-requests/export`

Export permintaan menu ke CSV.

---

### 🛡️ PATCH `/menu-requests/:id/status`

Update status permintaan menu.

**Request Body:** `{ "status": "APPROVED" | "REJECTED", "note": "..." }`

---

## 10. Food Ratings

### 🔑 POST `/food-ratings`

Beri rating makanan.

**Request Body:** `{ "foodId": "uuid", "rating": 4, "comment": "Enak!" }`

---

### 🔑 GET `/food-ratings/my`

Rating makanan milik pengguna.

---

### 🔑 GET `/food-ratings/ranking`

Ranking makanan berdasarkan rata-rata rating.

---

### 🛡️ GET `/food-ratings`

Semua rating (admin).

---

### 🛡️ GET `/food-ratings/export`

Export rating ke CSV.

---

## 11. Food Feedbacks

### 🔑 POST `/food-feedbacks`

Kirim feedback makanan.

**Request Body:** `{ "foodId": "uuid", "type": "LIKE" | "DISLIKE", "note": "..." }`

---

### 🔑 GET `/food-feedbacks/my`

Feedback milik pengguna.

---

### 🛡️ GET `/food-feedbacks/summary`

Ringkasan feedback per makanan (admin).

---

### 🛡️ GET `/food-feedbacks`

Semua feedback (admin).

---

### 🛡️ GET `/food-feedbacks/export`

Export feedback ke CSV.

---

## 12. Stats

### 🔑 GET `/stats/daily`

Statistik harian pengguna (kalori, protein, dll.).

---

### 🔑 GET `/stats/weekly`

Statistik mingguan pengguna.

---

### 🔑 GET `/stats/top-foods`

Makanan yang paling sering dikonsumsi pengguna.

---

### 🔑 GET `/stats/summary`

Ringkasan keseluruhan statistik pengguna.

---

## 13. Reports (Admin)

### 🛡️ GET `/admin/dashboard`

Overview data dashboard admin.

---

### 🛡️ GET `/admin/nutrition-reports`

Laporan nutrisi semua pengguna.

---

### 🛡️ GET `/admin/nutrition-reports/export`

Export laporan nutrisi ke CSV.

---

## 14. Notifications

### 🔑 GET `/notifications`

Daftar notifikasi pengguna.

---

### 🔑 PATCH `/notifications/read-all`

Tandai semua notifikasi sebagai sudah dibaca.

---

### 🔑 PATCH `/notifications/:id/read`

Tandai satu notifikasi sebagai sudah dibaca.

---

## Kode Error Umum

| HTTP Status | Keterangan |
|---|---|
| `200` | OK |
| `201` | Created |
| `400` | Bad Request — input tidak valid |
| `401` | Unauthorized — token tidak ada atau kedaluwarsa |
| `403` | Forbidden — tidak punya izin |
| `404` | Not Found |
| `409` | Conflict — misal email sudah terdaftar |
| `422` | Unprocessable Entity — validasi bisnis gagal (pesan Bahasa Indonesia) |
| `429` | Too Many Requests — rate limit terlampaui |
| `500` | Internal Server Error |

---

## Catatan Versi

| Tanggal | Perubahan |
|---|---|
| Nov 2026 | Tambah `GET /sppg/by-code/:kode` — verifikasi kode SPPG saat registrasi (rate limit 20/15 menit) |
| Nov 2026 | Update `POST /auth/register` — tambah `sppg_code`, `new_institution`; backward compat `sppg_id` tetap diterima |
| Nov 2026 | Alur registrasi mobile diubah menjadi 4 langkah; pemilihan SPPG via kode, bukan dropdown wilayah |

