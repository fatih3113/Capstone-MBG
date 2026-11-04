"use strict";
// Utilitas Logging Sistem (Winston): mencatat aktivitas server, peringatan keamanan, dan error ke konsol terminal serta file berkas log (error.log dan combined.log).
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.logger = void 0;
const winston_1 = __importDefault(require("winston"));
const { combine, timestamp, printf, colorize, errors } = winston_1.default.format;
// Format teks log: menyertakan timestamp waktu, level pesan (info/warn/error), isi pesan, dan stack trace jika error.
const logFormat = printf(({ level, message, timestamp, stack }) => {
    return stack
        ? `${timestamp} [${level}]: ${message}\n${stack}`
        : `${timestamp} [${level}]: ${message}`;
});
// Instance logger Winston: menulis ke terminal konsol (berwarna) dan menyimpan ke folder file logs/.
exports.logger = winston_1.default.createLogger({
    level: process.env.LOG_LEVEL || 'info',
    format: combine(timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }), errors({ stack: true }), logFormat),
    transports: [
        new winston_1.default.transports.Console({
            format: combine(colorize(), logFormat),
        }),
        new winston_1.default.transports.File({
            filename: 'logs/error.log',
            level: 'error',
        }),
        new winston_1.default.transports.File({ filename: 'logs/combined.log' }),
    ],
});
//# sourceMappingURL=logger.js.map