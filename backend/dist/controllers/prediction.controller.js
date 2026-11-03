"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PredictionController = exports.uploadScanImage = void 0;
const client_1 = require("@prisma/client");
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const api_response_1 = require("../utils/api-response");
const logger_1 = require("../utils/logger");
const prisma = new client_1.PrismaClient();
// Multer untuk upload gambar makanan
const storage = multer_1.default.diskStorage({
    destination: (_, __, cb) => {
        const dir = 'uploads/scans/';
        if (!fs_1.default.existsSync(dir))
            fs_1.default.mkdirSync(dir, { recursive: true });
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        const ext = path_1.default.extname(file.originalname);
        cb(null, `scan_${req.userId}_${Date.now()}${ext}`);
    },
});
exports.uploadScanImage = (0, multer_1.default)({
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
class PredictionController {
    constructor() {
        /**
         * POST /predictions/classify
         * Klasifikasi gambar makanan.
         * Strategi (Strategy Pattern):
         *   1. Jika ML_SERVICE_URL di-set → forward ke Python/TensorFlow microservice
         *   2. Fallback ke mock predictions (development/testing)
         */
        this.classifyImage = async (req, res, next) => {
            try {
                const mlServiceUrl = process.env.ML_SERVICE_URL;
                let predictions;
                if (mlServiceUrl && req.file) {
                    // ─── Forward ke ML Microservice ─────────────────────────────────
                    // Menggunakan FormData + native fetch (Node 18+) atau axios
                    try {
                        const FormData = (await Promise.resolve().then(() => __importStar(require('form-data')))).default;
                        const formData = new FormData();
                        formData.append('image', fs_1.default.createReadStream(req.file.path), { filename: req.file.filename, contentType: req.file.mimetype });
                        // Impor axios secara lazy untuk menghindari circular dependency
                        const axios = (await Promise.resolve().then(() => __importStar(require('axios')))).default;
                        const mlResponse = await axios.post(`${mlServiceUrl}/classify`, formData, {
                            headers: formData.getHeaders(),
                            timeout: 30000, // 30 detik timeout
                        });
                        predictions = mlResponse.data.predictions;
                        logger_1.logger.info(`ML microservice classified image for user ${req.userId}: ${predictions[0]?.food_name}`);
                    }
                    catch (mlError) {
                        // ML service tidak tersedia → fallback ke mock
                        logger_1.logger.warn(`ML microservice unavailable (${mlError.message}), using mock predictions`);
                        predictions = _generateMockPredictions();
                    }
                }
                else {
                    // Mock prediction (untuk development/testing tanpa ML service)
                    predictions = _generateMockPredictions();
                    logger_1.logger.info(`Mock predictions generated for user ${req.userId}`);
                }
                // Bersihkan file sementara setelah diproses (jika ada)
                if (req.file?.path) {
                    fs_1.default.unlink(req.file.path, () => { });
                }
                res.json(api_response_1.ApiResponse.success(predictions, 'Klasifikasi berhasil'));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /predictions/:id — Detail prediksi
         */
        this.getPredictionById = async (req, res, next) => {
            try {
                const prediction = await prisma.prediction.findUnique({
                    where: { id: req.params.id },
                    include: {
                        food: { include: { nutrition: true } },
                        scan: { select: { userId: true, scannedAt: true } },
                    },
                });
                if (!prediction) {
                    res.status(404).json(api_response_1.ApiResponse.error('Prediksi tidak ditemukan', 404));
                    return;
                }
                // Cek ownership
                if (prediction.scan.userId !== req.userId) {
                    res.status(403).json(api_response_1.ApiResponse.error('Akses ditolak', 403));
                    return;
                }
                res.json(api_response_1.ApiResponse.success(prediction));
            }
            catch (error) {
                next(error);
            }
        };
        /**
         * GET /predictions/scan/:scanId — Semua prediksi dari satu scan
         */
        this.getPredictionsByScan = async (req, res, next) => {
            try {
                // Cek apakah scan milik user ini
                const scan = await prisma.scanHistory.findFirst({
                    where: { id: req.params.scanId, userId: req.userId },
                });
                if (!scan) {
                    res.status(404).json(api_response_1.ApiResponse.error('Scan tidak ditemukan', 404));
                    return;
                }
                const predictions = await prisma.prediction.findMany({
                    where: { scanId: req.params.scanId },
                    include: { food: { include: { nutrition: true } } },
                    orderBy: { confidence: 'desc' },
                });
                res.json(api_response_1.ApiResponse.success(predictions));
            }
            catch (error) {
                next(error);
            }
        };
    }
}
exports.PredictionController = PredictionController;
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
//# sourceMappingURL=prediction.controller.js.map