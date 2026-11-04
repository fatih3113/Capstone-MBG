"use strict";
// Middleware Otorisasi Admin: memastikan pengguna yang login memiliki role 'admin' sebelum diizinkan mengakses data manajemen/dashboard MBG.
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminMiddleware = void 0;
const client_1 = require("@prisma/client");
// Inisialisasi Prisma Client untuk mengecek data user di database.
const prisma = new client_1.PrismaClient();
// adminMiddleware: memverifikasi role akun pengguna di database; harus dipasang setelah authMiddleware.
const adminMiddleware = async (req, res, next) => {
    try {
        // Mengambil data role dari database berdasarkan userId yang diekstrak oleh authMiddleware.
        const user = await prisma.user.findUnique({
            where: { id: req.userId },
            select: { role: true },
        });
        // Menolak akses dengan HTTP 403 Forbidden jika akun tidak ditemukan atau bukan role 'admin'.
        if (!user || user.role !== 'admin') {
            res.status(403).json({
                success: false,
                message: 'Akses ditolak. Halaman ini hanya untuk admin pengelola MBG.',
            });
            return;
        }
        // Melanjutkan ke controller rute admin jika role terkonfirmasi valid.
        next();
    }
    catch (error) {
        // Menangani error jika terjadi gangguan koneksi database saat pengecekan role.
        res.status(500).json({ success: false, message: 'Gagal memverifikasi role pengguna.' });
    }
};
exports.adminMiddleware = adminMiddleware;
//# sourceMappingURL=admin.middleware.js.map