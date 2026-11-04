// Utilitas Logging Sistem (Winston): mencatat aktivitas server, peringatan keamanan, dan error ke konsol terminal serta file berkas log (error.log dan combined.log).

import winston from 'winston';

const { combine, timestamp, printf, colorize, errors } = winston.format;

// Format teks log: menyertakan timestamp waktu, level pesan (info/warn/error), isi pesan, dan stack trace jika error.
const logFormat = printf(({ level, message, timestamp, stack }) => {
  return stack
    ? `${timestamp} [${level}]: ${message}\n${stack}`
    : `${timestamp} [${level}]: ${message}`;
});

// Instance logger Winston: menulis ke terminal konsol (berwarna) dan menyimpan ke folder file logs/.
export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: combine(
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    errors({ stack: true }),
    logFormat,
  ),
  transports: [
    new winston.transports.Console({
      format: combine(colorize(), logFormat),
    }),
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
    }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ],
});
