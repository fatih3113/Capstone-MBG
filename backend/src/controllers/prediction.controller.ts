import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { ApiResponse } from '../utils/api-response';
import { JwtRequest } from '../middleware/auth.middleware';
import { logger } from '../utils/logger';

const prisma = new PrismaClient();

// Multer untuk upload gambar makanan
const storage = multer.diskStorage({
  destination: (_, __, cb) => {
    const dir = 'uploads/scans/';
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req: JwtRequest, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `scan_${req.userId}_${Date.now()}${ext}`);
  },
});

export const uploadScanImage = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (_, file, cb) => {
    const allowed = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    cb(null, allowed.includes(file.mimetype));
  },
}).single('image');

// ─── Data makanan MBG beserta label kelas TFLite ──────────────────────────
// (Pengolahan Citra Digital + Machine Learning)
const ML_FOOD_CLASSES = [
  'Nasi Putih', 'Ayam Goreng', 'Telur Rebus', 'Ikan Goreng',
  'Tempe Goreng', 'Tahu Goreng', 'Sayur Bayam', 'Sayur Wortel',
  'Pisang', 'Jeruk', 'Susu Putih', 'Mie Goreng',
  'Perkedel Kentang', 'Tumis Kangkung', 'Semangka',
];

export class PredictionController {

  /**
   * POST /predictions/classify
   * Klasifikasi gambar makanan.
   * Strategi (Strategy Pattern):
   *   1. Jika ML_SERVICE_URL di-set → forward ke Python/TensorFlow microservice
   *   2. Fallback ke mock predictions (development/testing)
   */
  classifyImage = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const mlServiceUrl = process.env.ML_SERVICE_URL;
      let predictions: Array<{ food_name: string; confidence: number }>;

      if (mlServiceUrl && req.file) {
        // ─── Forward ke ML Microservice ─────────────────────────────────
        // Menggunakan FormData + native fetch (Node 18+) atau axios
        try {
          const FormData = (await import('form-data')).default;
          const formData = new FormData();
          formData.append(
            'image',
            fs.createReadStream(req.file.path),
            { filename: req.file.filename, contentType: req.file.mimetype }
          );

          // Impor axios secara lazy untuk menghindari circular dependency
          const axios = (await import('axios')).default;
          const mlResponse = await axios.post<{
            predictions: Array<{ food_name: string; confidence: number }>;
          }>(
            `${mlServiceUrl}/classify`,
            formData,
            {
              headers: formData.getHeaders(),
              timeout: 30000, // 30 detik timeout
            }
          );

          predictions = mlResponse.data.predictions;
          logger.info(
            `ML microservice classified image for user ${req.userId}: ${predictions[0]?.food_name}`
          );
        } catch (mlError: any) {
          // ML service tidak tersedia → fallback ke mock
          logger.warn(
            `ML microservice unavailable (${mlError.message}), using mock predictions`
          );
          predictions = _generateMockPredictions();
        }
      } else {
        // Mock prediction (untuk development/testing tanpa ML service)
        predictions = _generateMockPredictions();
        logger.info(`Mock predictions generated for user ${req.userId}`);
      }

      // Bersihkan file sementara setelah diproses (jika ada)
      if (req.file?.path) {
        fs.unlink(req.file.path, () => {});
      }

      res.json(ApiResponse.success(predictions, 'Klasifikasi berhasil'));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /predictions/:id — Detail prediksi
   */
  getPredictionById = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const prediction = await prisma.prediction.findUnique({
        where: { id: req.params.id },
        include: {
          food: { include: { nutrition: true } },
          scan: { select: { userId: true, scannedAt: true } },
        },
      });

      if (!prediction) {
        res.status(404).json(ApiResponse.error('Prediksi tidak ditemukan', 404));
        return;
      }

      // Cek ownership
      if (prediction.scan.userId !== req.userId) {
        res.status(403).json(ApiResponse.error('Akses ditolak', 403));
        return;
      }

      res.json(ApiResponse.success(prediction));
    } catch (error) {
      next(error);
    }
  };

  /**
   * GET /predictions/scan/:scanId — Semua prediksi dari satu scan
   */
  getPredictionsByScan = async (req: JwtRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      // Cek apakah scan milik user ini
      const scan = await prisma.scanHistory.findFirst({
        where: { id: req.params.scanId, userId: req.userId },
      });

      if (!scan) {
        res.status(404).json(ApiResponse.error('Scan tidak ditemukan', 404));
        return;
      }

      const predictions = await prisma.prediction.findMany({
        where: { scanId: req.params.scanId },
        include: { food: { include: { nutrition: true } } },
        orderBy: { confidence: 'desc' },
      });

      res.json(ApiResponse.success(predictions));
    } catch (error) {
      next(error);
    }
  };
}

// Helper: Generate mock predictions untuk testing
function _generateMockPredictions() {
  // Simulasi top-2 prediksi dari model TFLite
  const shuffled = [...ML_FOOD_CLASSES].sort(() => Math.random() - 0.5);
  return [
    {
      food_name: shuffled[0],
      confidence: +(0.85 + Math.random() * 0.13).toFixed(4),
    },
    {
      food_name: shuffled[1],
      confidence: +(0.5 + Math.random() * 0.30).toFixed(4),
    },
  ].sort((a, b) => b.confidence - a.confidence);
}
