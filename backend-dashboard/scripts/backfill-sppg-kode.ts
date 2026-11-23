/**
 * Skrip sekali jalan: mengisi kode SPPG pada semua SPPG berstatus APPROVED yang kodenya masih null.
 * Jalankan dengan: npx ts-node scripts/backfill-sppg-kode.ts
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const SAFE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

function generateSppgKode(): string {
  let code = 'SPPG-';
  for (let i = 0; i < 6; i++) {
    code += SAFE_CHARS[Math.floor(Math.random() * SAFE_CHARS.length)];
  }
  return code;
}

async function main() {
  const sppgList = await prisma.sppg.findMany({
    where: { verificationStatus: 'APPROVED', kode: null },
    select: { id: true, nama: true },
  });

  console.log(`Ditemukan ${sppgList.length} SPPG tanpa kode.`);

  for (const sppg of sppgList) {
    let kode: string | null = null;
    let attempts = 0;
    while (attempts < 10) {
      const candidate = generateSppgKode();
      const conflict = await prisma.sppg.findUnique({ where: { kode: candidate }, select: { id: true } });
      if (!conflict) { kode = candidate; break; }
      attempts++;
    }
    if (!kode) {
      console.error(`Gagal generate kode untuk SPPG: ${sppg.nama}`);
      continue;
    }
    await prisma.sppg.update({ where: { id: sppg.id }, data: { kode } });
    console.log(`✓ ${sppg.nama} → ${kode}`);
  }

  console.log('Selesai.');
}

main().catch(console.error).finally(() => prisma.$disconnect());
