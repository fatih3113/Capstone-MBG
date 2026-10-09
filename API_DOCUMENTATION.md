# 📋 MBG Nutrition API — Dokumentasi Lengkap

Dokumentasi ini mencakup endpoint yang digunakan oleh aplikasi **MBG Nutrition** pada bagian **Login**, **Register**, dan **Scan Makanan**.

> **Tech Stack:** Express.js · Prisma · PostgreSQL · JWT · Multer

---

## 🌐 Base URL

```
http://localhost:3000/api/v1
```

---

## 📦 Format Response

### ✅ Success

```json
{
  "success": true,
  "message": "Pesan berhasil",
  "data": {}
}
```

### ❌ Error

```json
{
  "success": false,
  "message": "Pesan error",
  "statusCode": 400
}
```

### ⚠️ Validation Error (422)

```json
{
  "success": false,
  "message": [
    "Format email tidak valid",
    "Password minimal 8 karakter"
  ],
  "statusCode": 422
}
```

---

## 📊 HTTP Status Codes

| Code | Keterangan |
|------|-----------|
| `200` | Request berhasil |
| `201` | Data berhasil dibuat |
| `401` | Belum login / token tidak valid |
| `403` | Tidak memiliki akses |
| `404` | Data tidak ditemukan |
| `409` | Conflict (misal: email sudah terdaftar) |
| `422` | Validation error |
| `500` | Internal server error |

---

## 🔑 Authentication Header

Endpoint yang memerlukan autentikasi harus menyertakan header:

```http
Authorization: Bearer {token}
```

---

---

# 1. AUTHENTICATION API

## 1.1 Register

Mendaftarkan user baru (siswa).

### Endpoint

```http
POST /api/v1/auth/register
```

### Request Body

| Field | Type | Required | Validasi |
|-------|------|:--------:|----------|
| `name` | string | ✅ | 2–100 karakter |
| `email` | string | ✅ | Format email valid |
| `password` | string | ✅ | Minimal 8 karakter |
| `gender` | string | ❌ | `"L"` atau `"P"` |
| `age` | integer | ❌ | 5–100 tahun |
| `school_id` | string (UUID) | ❌ | UUID sekolah |
| `class` | string | ❌ | Nama kelas (misal: `"7A"`) |

### Contoh Request

```json
{
  "name": "Budi Santoso",
  "email": "budi@example.com",
  "password": "password123",
  "gender": "L",
  "age": 13,
  "class": "7A"
}
```

### Response — HTTP 201 Created

```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "id": "a1b2c3d4-e5f6-...",
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "class_": "7A",
    "gender": "L",
    "age": 13,
    "schoolLevel": null,
    "createdAt": "2026-10-09T06:00:00.000Z"
  }
}
```

### Response — HTTP 409 Email Sudah Terdaftar

```json
{
  "success": false,
  "message": "Email sudah terdaftar",
  "statusCode": 409
}
```

### Response — HTTP 422 Validation Error

```json
{
  "success": false,
  "message": [
    "Nama harus antara 2-100 karakter",
    "Format email tidak valid",
    "Password minimal 8 karakter"
  ],
  "statusCode": 422
}
```

### Validation Rules (middleware: `validateRegister`)

```typescript
body('name').trim().isLength({ min: 2, max: 100 })
body('email').isEmail().normalizeEmail()
body('password').isLength({ min: 8 })
body('gender').optional().isIn(['L', 'P'])
body('age').optional().isInt({ min: 5, max: 100 })
```

---

## 1.2 Login

Login user ke aplikasi, mendapatkan JWT token.

### Endpoint

```http
POST /api/v1/auth/login
```

### Request Body

| Field | Type | Required | Validasi |
|-------|------|:--------:|----------|
| `email` | string | ✅ | Format email valid |
| `password` | string | ✅ | Tidak boleh kosong |

### Contoh Request

```json
{
  "email": "budi@example.com",
  "password": "password123"
}
```

### Response — HTTP 200 OK

```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "a1b2c3d4-e5f6-...",
      "name": "Budi Santoso",
      "email": "budi@example.com",
      "school_name": "SMPN 1 Jakarta",
      "class": "7A",
      "gender": "L",
      "age": 13,
      "school_level": null
    }
  }
}
```

### Response — HTTP 401 Credentials Salah

```json
{
  "success": false,
  "message": "Email atau password salah",
  "statusCode": 401
}
```

### Response — HTTP 422 Validation Error

```json
{
  "success": false,
  "message": [
    "Format email tidak valid"
  ],
  "statusCode": 422
}
```

### Validation Rules (middleware: `validateLogin`)

```typescript
body('email').isEmail().normalizeEmail()
body('password').notEmpty()
```

> **⚠️ Penting:** Token JWT berlaku selama **7 hari**. Simpan token di `flutter_secure_storage` atau `SharedPreferences` dan sertakan pada setiap request yang membutuhkan autentikasi.

---

## 1.3 Logout

Logout user. Karena JWT bersifat stateless, client **wajib menghapus token secara lokal**.

### Endpoint

```http
POST /api/v1/auth/logout
```

### Headers

```http
Authorization: Bearer {token}
```

### Response — HTTP 200 OK

```json
{
  "success": true,
  "message": "Logout berhasil",
  "data": null
}
```

---

## 1.4 Forgot Password

Mengirimkan permintaan reset password.

### Endpoint

```http
POST /api/v1/auth/forgot-password
```

### Request Body

```json
{
  "email": "budi@example.com"
}
```

### Response — HTTP 200 OK

```json
{
  "success": true,
  "message": "Jika email terdaftar, link reset password akan dikirim",
  "data": null
}
```

> **Catatan:** Selalu mengembalikan 200 meskipun email tidak terdaftar, untuk mencegah **email enumeration attack**.

---

---

# 2. FOOD SCAN API

Fitur utama aplikasi — identifikasi makanan menggunakan kamera dan analisis kandungan gizi.

## Alur Scan Makanan

```
📸 Ambil Foto
     │
     ▼
POST /api/v1/predictions/classify
     │ → kirim gambar, terima prediksi makanan
     ▼
⭐ Evaluasi Sensorik & Konsumsi (di Flutter — food_evaluation_page.dart)
     │
     ▼
POST /api/v1/scan-history/save
     │ → simpan hasil scan + data evaluasi ke database
     ▼
✅ Lihat Riwayat
GET /api/v1/scan-history
GET /api/v1/scan-history/:id
```

---

## 2.1 Klasifikasi Gambar Makanan

Mengirimkan foto makanan dan mendapatkan prediksi jenis makanan beserta confidence score.

### Endpoint

```http
POST /api/v1/predictions/classify
```

### Headers

```http
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

### Request Body (Form Data)

| Field | Type | Required | Keterangan |
|-------|------|:--------:|-----------|
| `image` | file | ✅ | JPEG / PNG / WebP, maks **10 MB** |

### Contoh Request — Flutter

```dart
final request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/predictions/classify'),
);
request.headers['Authorization'] = 'Bearer $token';
request.files.add(
  await http.MultipartFile.fromPath('image', file.path),
);
final streamed = await request.send();
final response = await http.Response.fromStream(streamed);
final body = jsonDecode(response.body);
// body['data'] = [{ "food_name": "Nasi Putih", "confidence": 0.92 }, ...]
```

### Response — HTTP 200 OK

```json
{
  "success": true,
  "message": "Klasifikasi berhasil",
  "data": [
    {
      "food_name": "Nasi Putih",
      "confidence": 0.9234
    },
    {
      "food_name": "Ayam Goreng",
      "confidence": 0.7812
    }
  ]
}
```

### Keterangan Field Response

| Field | Type | Keterangan |
|-------|------|-----------|
| `food_name` | string | Nama makanan yang teridentifikasi |
| `confidence` | float (0–1) | Tingkat keyakinan model. `0.9` = 90% |

### Daftar Makanan yang Dapat Diidentifikasi

| No | Nama Makanan | Kategori |
|----|-------------|---------|
| 1 | Nasi Putih | Karbohidrat |
| 2 | Ayam Goreng | Protein Hewani |
| 3 | Telur Rebus | Protein Hewani |
| 4 | Ikan Goreng | Protein Hewani |
| 5 | Tempe Goreng | Protein Nabati |
| 6 | Tahu Goreng | Protein Nabati |
| 7 | Sayur Bayam | Sayuran |
| 8 | Sayur Wortel | Sayuran |
| 9 | Pisang | Buah |
| 10 | Jeruk | Buah |
| 11 | Susu Putih | Minuman |
| 12 | Mie Goreng | Karbohidrat |
| 13 | Perkedel Kentang | Karbohidrat |
| 14 | Tumis Kangkung | Sayuran |
| 15 | Semangka | Buah |

> **Development Mode:** Jika `ML_SERVICE_URL` tidak dikonfigurasi di `.env`, API akan menggunakan **mock prediction** (data acak) untuk keperluan testing.

---

## 2.2 Simpan Hasil Scan

Menyimpan hasil scan beserta data sensorik dan konsumsi ke database.

### Endpoint

```http
POST /api/v1/scan-history/save
```

### Headers

```http
Authorization: Bearer {token}
Content-Type: application/json
```

### Request Body

| Field | Type | Required | Validasi |
|-------|------|:--------:|----------|
| `total_calories` | float | ✅ | `>= 0` |
| `total_protein` | float | ✅ | `>= 0` |
| `total_carbs` | float | ❌ | `>= 0` |
| `total_fat` | float | ❌ | `>= 0` |
| `total_fiber` | float | ❌ | `>= 0` |
| `predictions` | array | ✅ | Min 1 item |
| `predictions[].food_id` | string | ✅ | Tidak boleh kosong |
| `predictions[].confidence` | float | ✅ | 0–1 |
| `predictions[].portion_gram` | float | ❌ | Estimasi berat gram |
| `sensory_data` | object | ❌ | Lihat struktur di bawah |
| `consumption_data` | object | ❌ | Lihat struktur di bawah |

### Contoh Request Lengkap

```json
{
  "total_calories": 350.5,
  "total_protein": 18.2,
  "total_carbs": 45.0,
  "total_fat": 8.5,
  "total_fiber": 3.2,
  "predictions": [
    {
      "food_id": "uuid-nasi-putih",
      "confidence": 0.9234,
      "portion_gram": 150
    },
    {
      "food_id": "uuid-ayam-goreng",
      "confidence": 0.7812,
      "portion_gram": 80
    }
  ],
  "sensory_data": {
    "taste": "Enak",
    "salt_level": "Pas",
    "sweet_level": "Pas",
    "texture": "Pas",
    "aroma": "Sedap"
  },
  "consumption_data": {
    "portion_size": "Penuh (100%)",
    "leftover_amount": "Tidak ada",
    "is_finished": true
  }
}
```

### Struktur `sensory_data`

| Field | Pilihan Nilai |
|-------|--------------|
| `taste` | `"Sangat Enak"` · `"Enak"` · `"Biasa"` · `"Kurang Enak"` · `"Tidak Enak"` |
| `salt_level` | `"Terlalu Asin"` · `"Agak Asin"` · `"Pas"` · `"Kurang Asin"` · `"Tidak Asin"` |
| `sweet_level` | `"Terlalu Manis"` · `"Agak Manis"` · `"Pas"` · `"Kurang Manis"` · `"Tidak Manis"` |
| `texture` | `"Sangat Baik"` · `"Baik"` · `"Pas"` · `"Kurang Baik"` · `"Tidak Baik"` |
| `aroma` | `"Sangat Sedap"` · `"Sedap"` · `"Biasa"` · `"Kurang Sedap"` · `"Tidak Sedap"` |

### Struktur `consumption_data`

| Field | Pilihan Nilai |
|-------|--------------|
| `portion_size` | `"Penuh (100%)"` · `"3/4 Porsi (75%)"` · `"1/2 Porsi (50%)"` · `"1/4 Porsi (25%)"` · `"Sedikit (<25%)"` |
| `leftover_amount` | `"Tidak ada"` · `"Sedikit"` · `"Setengah"` · `"Banyak"` · `"Semua"` |
| `is_finished` | `true` / `false` |

### Response — HTTP 201 Created

```json
{
  "success": true,
  "message": "Scan berhasil disimpan",
  "data": {
    "id": "scan-uuid-...",
    "userId": "user-uuid-...",
    "scannedAt": "2026-10-09T06:30:00.000Z",
    "totalCalories": 350.5,
    "totalProtein": 18.2,
    "totalCarbs": 45.0,
    "totalFat": 8.5,
    "status": "success"
  }
}
```

### Response — HTTP 422 Validation Error

```json
{
  "success": false,
  "message": [
    "Total kalori tidak valid",
    "Prediksi tidak boleh kosong"
  ],
  "statusCode": 422
}
```

### Validation Rules (middleware: `validateSaveScan`)

```typescript
body('total_calories').isFloat({ min: 0 })
body('total_protein').isFloat({ min: 0 })
body('predictions').isArray({ min: 1 })
body('predictions.*.food_id').notEmpty()
body('predictions.*.confidence').isFloat({ min: 0, max: 1 })
```

---

## 2.3 Riwayat Scan Saya

Mengambil seluruh riwayat scan milik user yang sedang login.

### Endpoint

```http
GET /api/v1/scan-history
```

### Headers

```http
Authorization: Bearer {token}
```

### Response — HTTP 200 OK

```json
{
  "success": true,
  "message": "Riwayat scan berhasil diambil",
  "data": [
    {
      "id": "scan-uuid-001",
      "scannedAt": "2026-10-09T06:30:00.000Z",
      "totalCalories": 350.5,
      "totalProtein": 18.2,
      "totalCarbs": 45.0,
      "totalFat": 8.5,
      "status": "success",
      "predictions": [
        {
          "id": "pred-uuid-001",
          "confidence": 0.9234,
          "food": {
            "id": "food-uuid-001",
            "name": "Nasi Putih",
            "category": "Karbohidrat"
          }
        }
      ]
    }
  ]
}
```

---

## 2.4 Detail Riwayat Scan

Mengambil detail satu scan berdasarkan ID, termasuk data sensorik, konsumsi, dan prediksi lengkap dengan nutrisi.

### Endpoint

```http
GET /api/v1/scan-history/:id
```

### Headers

```http
Authorization: Bearer {token}
```

### Contoh Request

```http
GET /api/v1/scan-history/scan-uuid-001
```

### Response — HTTP 200 OK

```json
{
  "success": true,
  "message": "Detail scan berhasil diambil",
  "data": {
    "id": "scan-uuid-001",
    "scannedAt": "2026-10-09T06:30:00.000Z",
    "totalCalories": 350.5,
    "totalProtein": 18.2,
    "totalCarbs": 45.0,
    "totalFat": 8.5,
    "totalFiber": 3.2,
    "status": "success",
    "sensoryData": {
      "taste": "Enak",
      "salt_level": "Pas",
      "sweet_level": "Pas",
      "texture": "Pas",
      "aroma": "Sedap"
    },
    "consumptionData": {
      "portion_size": "Penuh (100%)",
      "leftover_amount": "Tidak ada",
      "is_finished": true
    },
    "predictions": [
      {
        "id": "pred-uuid-001",
        "confidence": 0.9234,
        "portionEstimateGram": 150,
        "calories": 195.0,
        "protein": 3.6,
        "carbs": 43.0,
        "fat": 0.4,
        "food": {
          "id": "food-uuid-001",
          "name": "Nasi Putih",
          "category": "Karbohidrat",
          "nutrition": {
            "calories": 130,
            "protein": 2.4,
            "carbs": 28.7,
            "fat": 0.3,
            "fiber": 0.2
          }
        }
      }
    ]
  }
}
```

### Response — HTTP 403 Bukan Milik User

```json
{
  "success": false,
  "message": "Akses ditolak",
  "statusCode": 403
}
```

### Response — HTTP 404 Tidak Ditemukan

```json
{
  "success": false,
  "message": "Scan tidak ditemukan",
  "statusCode": 404
}
```

---

---

# 3. ENDPOINT SUMMARY

## 🔐 Authentication

| Method | Endpoint | Auth |
|--------|----------|:----:|
| `POST` | `/api/v1/auth/register` | ❌ |
| `POST` | `/api/v1/auth/login` | ❌ |
| `POST` | `/api/v1/auth/logout` | ✅ |
| `POST` | `/api/v1/auth/forgot-password` | ❌ |
| `POST` | `/api/v1/auth/reset-password` | ❌ |

## 🍱 Food Scan

| Method | Endpoint | Auth |
|--------|----------|:----:|
| `POST` | `/api/v1/predictions/classify` | ✅ |
| `GET` | `/api/v1/predictions/scan/:scanId` | ✅ |
| `GET` | `/api/v1/predictions/:id` | ✅ |
| `GET` | `/api/v1/scan-history` | ✅ |
| `GET` | `/api/v1/scan-history/:id` | ✅ |
| `POST` | `/api/v1/scan-history/save` | ✅ |

## 👤 User & Profile

| Method | Endpoint | Auth |
|--------|----------|:----:|
| `GET` | `/api/v1/users/profile` | ✅ |
| `PUT` | `/api/v1/users/profile/update` | ✅ |
| `POST` | `/api/v1/users/profile/photo` | ✅ |
| `DELETE` | `/api/v1/users/profile` | ✅ |

## 📊 Lainnya

| Method | Endpoint | Auth |
|--------|----------|:----:|
| `GET` | `/api/v1/foods` | ❌ |
| `GET` | `/api/v1/nutrition/:foodId` | ❌ |
| `GET` | `/api/v1/mbg-menu` | ✅ |
| `GET` | `/api/v1/schools` | ❌ |
| `GET` | `/api/v1/stats/daily` | ✅ |
| `GET` | `/health` | ❌ |

---

---

# 4. VALIDATION CHECKLIST

Sebelum endpoint dianggap selesai, gunakan checklist berikut:

### Register

- [ ] `name` tidak boleh kosong dan 2–100 karakter
- [ ] `email` harus format email valid
- [ ] `password` minimal 8 karakter
- [ ] `gender` hanya boleh `"L"` atau `"P"` (opsional)
- [ ] `age` harus integer 5–100 (opsional)
- [ ] Email belum terdaftar di database → tolak dengan **409**

### Login

- [ ] `email` harus format email valid
- [ ] `password` tidak boleh kosong
- [ ] Kembalikan JWT token bila credentials benar
- [ ] Kembalikan **401** bila email atau password salah

### Scan Makanan — Classify

- [ ] File `image` dikirim sebagai `multipart/form-data`
- [ ] Tipe file harus `image/jpeg`, `image/jpg`, `image/png`, atau `image/webp`
- [ ] Ukuran file maksimal **10 MB**
- [ ] User sudah login (ada Bearer token valid)

### Simpan Scan

- [ ] `total_calories` >= 0
- [ ] `total_protein` >= 0
- [ ] `predictions` tidak boleh kosong (min 1 item)
- [ ] Setiap `predictions[].food_id` tidak boleh kosong
- [ ] Setiap `predictions[].confidence` antara 0–1
- [ ] User sudah login

---

---

# 5. ALUR APLIKASI FLUTTER

## Register & Login

```
splash_page.dart
    │
    ├─ belum login ──► login_page.dart
    │                       │
    │                       ├── POST /auth/login
    │                       │       └── simpan token di AuthProvider
    │                       │
    │                       └── belum punya akun ──► register_page.dart
    │                                                     │
    │                                                     └── POST /auth/register
    │                                                             └── kembali ke login
    │
    └─ sudah login ──► home_page.dart
```

## Scan Makanan

```
scan_page.dart
    │
    ├── ambil foto (camera / gallery)
    │
    ▼
image_preview_page.dart
    │
    └── konfirmasi foto
                │
                └── POST /predictions/classify
                            │
                            ▼
                prediction_result_page.dart
                            │
                            └── lanjut ke evaluasi
                                        │
                                        ▼
                            food_evaluation_page.dart
                                        │
                                        ├── pilih rasa, asin, manis, tekstur, aroma
                                        ├── pilih porsi & sisa makanan
                                        │
                                        └── "Lihat Analisis Gizi"
                                                    │
                                                    └── POST /scan-history/save
                                                                │
                                                                ▼
                                                    analysis_result_page.dart
```

---

---

# 6. CONTOH KODE DART / FLUTTER

## Login

```dart
final response = await http.post(
  Uri.parse('$baseUrl/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': 'budi@example.com',
    'password': 'password123',
  }),
);

final body = jsonDecode(response.body);
if (body['success'] == true) {
  final token = body['data']['token'];
  final user = body['data']['user'];
  // Simpan token ke secure storage
}
```

## Register

```dart
final response = await http.post(
  Uri.parse('$baseUrl/auth/register'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'name': 'Budi Santoso',
    'email': 'budi@example.com',
    'password': 'password123',
    'gender': 'L',
    'age': 13,
  }),
);
```

## Classify (Upload Gambar)

```dart
final request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/predictions/classify'),
);
request.headers['Authorization'] = 'Bearer $token';
request.files.add(
  await http.MultipartFile.fromPath('image', file.path),
);
final streamed = await request.send();
final response = await http.Response.fromStream(streamed);
final body = jsonDecode(response.body);
// body['data'] = [{ "food_name": "Nasi Putih", "confidence": 0.92 }, ...]
```

## Simpan Scan

```dart
final response = await http.post(
  Uri.parse('$baseUrl/scan-history/save'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'total_calories': 350.5,
    'total_protein': 18.2,
    'predictions': [
      {
        'food_id': 'uuid-nasi-putih',
        'confidence': 0.9234,
        'portion_gram': 150,
      },
    ],
    'sensory_data': {
      'taste': 'Enak',
      'salt_level': 'Pas',
      'sweet_level': 'Pas',
      'texture': 'Pas',
      'aroma': 'Sedap',
    },
    'consumption_data': {
      'portion_size': 'Penuh (100%)',
      'leftover_amount': 'Tidak ada',
      'is_finished': true,
    },
  }),
);
```

---

---

# 7. DATABASE MODEL

## User

```prisma
model User {
  id              String   @id @default(uuid())
  name            String
  email           String   @unique
  passwordHash    String
  schoolId        String?
  class_          String?
  gender          String?          // 'L' | 'P'
  age             Int?
  profileImageUrl String?
  schoolLevel     String?          // SD | SMP | SMA | SMK
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
}
```

## ScanHistory

```prisma
model ScanHistory {
  id              String   @id @default(uuid())
  userId          String
  imageUrl        String?
  scannedAt       DateTime @default(now())
  totalCalories   Float    @default(0)
  totalProtein    Float    @default(0)
  totalCarbs      Float    @default(0)
  totalFat        Float    @default(0)
  totalFiber      Float    @default(0)
  status          String   @default("success")   // success | failed | processing
  sensoryData     Json?    // { taste, salt_level, sweet_level, texture, aroma }
  consumptionData Json?    // { portion_size, leftover_amount, is_finished }
  predictions     Prediction[]
}
```

## Prediction

```prisma
model Prediction {
  id                  String  @id @default(uuid())
  scanId              String
  foodId              String
  confidence          Float
  portionEstimateGram Float   @default(100)
  calories            Float?
  protein             Float?
  carbs               Float?
  fat                 Float?
}
```

## Nutrition

```prisma
model Nutrition {
  foodId      String @unique
  calories    Float   // kcal per 100g
  protein     Float   // g per 100g
  carbs       Float   // g per 100g
  fat         Float   // g per 100g
  fiber       Float   // g per 100g
  sugar       Float
  sodium      Float
  calcium     Float
  iron        Float
  vitaminC    Float
  vitaminA    Float
  portionGram Float   @default(100)
}
```

---

> **Dibuat untuk:** Project Capstone — MBG Nutrition
> **Tanggal:** Oktober 2026
> **Stack:** Express.js · Prisma · PostgreSQL · Flutter · JWT
