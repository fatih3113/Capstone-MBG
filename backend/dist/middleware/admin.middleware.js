"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminMiddleware = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
/**
 * Middleware: Hanya role "admin" yang bisa mengakses endpoint yang dilindungi.
 * Harus dipasang SETELAH authMiddleware.
 */
const adminMiddleware = async (req, res, next) => {
    try {
        const user = await prisma.user.findUnique({
            where: { id: req.userId },
            select: { role: true },
        });
        if (!user || user.role !== 'admin') {
            res.status(403).json({
                success: false,
                message: 'Akses ditolak. Halaman ini hanya untuk admin pengelola MBG.',
            });
            return;
        }
        next();
    }
    catch (error) {
        res.status(500).json({ success: false, message: 'Gagal memverifikasi role pengguna.' });
    }
};
exports.adminMiddleware = adminMiddleware;
//# sourceMappingURL=admin.middleware.js.map