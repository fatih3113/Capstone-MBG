/**
 * Seed SPPG (Satuan Pelayanan Pemenuhan Gizi)
 * ~13 SPPG contoh di beberapa provinsi/kota berbeda untuk demo dashboard
 *
 * Jalankan: npx ts-node src/database/seed_sppg.ts
 */

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const sppgData = [
  // ── Jawa Tengah ──────────────────────────────────────────────────────
  {
    id: 'sppg-jateng-001',
    kode: 'SPPG-3374-001',
    nama: 'SPPG Semarang Tengah',
    provinsi: 'Jawa Tengah',
    kabupatenKota: 'Kota Semarang',
    kecamatan: 'Semarang Tengah',
    kelurahanDesa: 'Jagalan',
    alamat: 'Jl. Pemuda No. 12, Semarang',
    latitude: -6.9932,
    longitude: 110.4229,
    isActive: true,
  },
  {
    id: 'sppg-jateng-002',
    kode: 'SPPG-3374-002',
    nama: 'SPPG Banyumanik',
    provinsi: 'Jawa Tengah',
    kabupatenKota: 'Kota Semarang',
    kecamatan: 'Banyumanik',
    kelurahanDesa: 'Ngesrep',
    alamat: 'Jl. Ngesrep Barat V No. 8, Semarang',
    latitude: -7.0555,
    longitude: 110.4241,
    isActive: true,
  },
  {
    id: 'sppg-jateng-003',
    kode: 'SPPG-3305-001',
    nama: 'SPPG Kebumen Kota',
    provinsi: 'Jawa Tengah',
    kabupatenKota: 'Kabupaten Kebumen',
    kecamatan: 'Kebumen',
    kelurahanDesa: 'Kebumen',
    alamat: 'Jl. Pahlawan No. 5, Kebumen',
    latitude: -7.6651,
    longitude: 109.6526,
    isActive: true,
  },

  // ── Jawa Barat ───────────────────────────────────────────────────────
  {
    id: 'sppg-jabar-001',
    kode: 'SPPG-3273-001',
    nama: 'SPPG Bandung Buah Batu',
    provinsi: 'Jawa Barat',
    kabupatenKota: 'Kota Bandung',
    kecamatan: 'Buah Batu',
    kelurahanDesa: 'Sekejati',
    alamat: 'Jl. Soekarno Hatta No. 22, Bandung',
    latitude: -6.9444,
    longitude: 107.6570,
    isActive: true,
  },
  {
    id: 'sppg-jabar-002',
    kode: 'SPPG-3273-002',
    nama: 'SPPG Bandung Coblong',
    provinsi: 'Jawa Barat',
    kabupatenKota: 'Kota Bandung',
    kecamatan: 'Coblong',
    kelurahanDesa: 'Dago',
    alamat: 'Jl. Ir. H. Juanda No. 45, Bandung',
    latitude: -6.8861,
    longitude: 107.6135,
    isActive: true,
  },
  {
    id: 'sppg-jabar-003',
    kode: 'SPPG-3276-001',
    nama: 'SPPG Depok Beji',
    provinsi: 'Jawa Barat',
    kabupatenKota: 'Kota Depok',
    kecamatan: 'Beji',
    kelurahanDesa: 'Beji',
    alamat: 'Jl. Margonda Raya No. 100, Depok',
    latitude: -6.3728,
    longitude: 106.8317,
    isActive: true,
  },

  // ── DKI Jakarta ──────────────────────────────────────────────────────
  {
    id: 'sppg-jakarta-001',
    kode: 'SPPG-3171-001',
    nama: 'SPPG Jakarta Pusat',
    provinsi: 'DKI Jakarta',
    kabupatenKota: 'Kota Jakarta Pusat',
    kecamatan: 'Gambir',
    kelurahanDesa: 'Gambir',
    alamat: 'Jl. Merdeka Selatan No. 3, Jakarta Pusat',
    latitude: -6.1753,
    longitude: 106.8272,
    isActive: true,
  },
  {
    id: 'sppg-jakarta-002',
    kode: 'SPPG-3172-001',
    nama: 'SPPG Jakarta Utara Penjaringan',
    provinsi: 'DKI Jakarta',
    kabupatenKota: 'Kota Jakarta Utara',
    kecamatan: 'Penjaringan',
    kelurahanDesa: 'Penjaringan',
    alamat: 'Jl. Pluit Raya No. 10, Jakarta Utara',
    latitude: -6.1126,
    longitude: 106.7925,
    isActive: true,
  },

  // ── Jawa Timur ───────────────────────────────────────────────────────
  {
    id: 'sppg-jatim-001',
    kode: 'SPPG-3578-001',
    nama: 'SPPG Surabaya Gubeng',
    provinsi: 'Jawa Timur',
    kabupatenKota: 'Kota Surabaya',
    kecamatan: 'Gubeng',
    kelurahanDesa: 'Gubeng',
    alamat: 'Jl. Pemuda No. 31, Surabaya',
    latitude: -7.2653,
    longitude: 112.7504,
    isActive: true,
  },
  {
    id: 'sppg-jatim-002',
    kode: 'SPPG-3507-001',
    nama: 'SPPG Malang Klojen',
    provinsi: 'Jawa Timur',
    kabupatenKota: 'Kota Malang',
    kecamatan: 'Klojen',
    kelurahanDesa: 'Klojen',
    alamat: 'Jl. Ijen No. 14, Malang',
    latitude: -7.9811,
    longitude: 112.6282,
    isActive: true,
  },

  // ── Sumatera Utara ───────────────────────────────────────────────────
  {
    id: 'sppg-sumut-001',
    kode: 'SPPG-1275-001',
    nama: 'SPPG Medan Baru',
    provinsi: 'Sumatera Utara',
    kabupatenKota: 'Kota Medan',
    kecamatan: 'Medan Baru',
    kelurahanDesa: 'Babura',
    alamat: 'Jl. Universitas No. 6, Medan',
    latitude: 3.5853,
    longitude: 98.6613,
    isActive: true,
  },
  {
    id: 'sppg-sumut-002',
    kode: 'SPPG-1275-002',
    nama: 'SPPG Medan Johor',
    provinsi: 'Sumatera Utara',
    kabupatenKota: 'Kota Medan',
    kecamatan: 'Medan Johor',
    kelurahanDesa: 'Gedung Johor',
    alamat: 'Jl. Karya Jaya No. 21, Medan',
    latitude: 3.5502,
    longitude: 98.6867,
    isActive: false, // contoh SPPG tidak aktif
  },

  // ── Sulawesi Selatan ─────────────────────────────────────────────────
  {
    id: 'sppg-sulsel-001',
    kode: 'SPPG-7371-001',
    nama: 'SPPG Makassar Tamalate',
    provinsi: 'Sulawesi Selatan',
    kabupatenKota: 'Kota Makassar',
    kecamatan: 'Tamalate',
    kelurahanDesa: 'Jongaya',
    alamat: 'Jl. Gowa Raya No. 7, Makassar',
    latitude: -5.1868,
    longitude: 119.4239,
    isActive: true,
  },
];

async function main() {
  console.log('🌱 Seeding SPPG data...\n');

  let created = 0;
  let skipped = 0;

  for (const data of sppgData) {
    try {
      await prisma.sppg.upsert({
        where: { id: data.id },
        update: {
          kode: data.kode,
          nama: data.nama,
          provinsi: data.provinsi,
          kabupatenKota: data.kabupatenKota,
          kecamatan: data.kecamatan,
          kelurahanDesa: data.kelurahanDesa,
          alamat: data.alamat,
          latitude: data.latitude,
          longitude: data.longitude,
          isActive: data.isActive,
        },
        create: {
          id: data.id,
          kode: data.kode,
          nama: data.nama,
          provinsi: data.provinsi,
          kabupatenKota: data.kabupatenKota,
          kecamatan: data.kecamatan,
          kelurahanDesa: data.kelurahanDesa,
          alamat: data.alamat,
          latitude: data.latitude,
          longitude: data.longitude,
          isActive: data.isActive,
        },
      });
      console.log(`  ✅ ${data.nama} (${data.provinsi})`);
      created++;
    } catch (e: any) {
      console.warn(`  ⚠️  Gagal seed ${data.nama}: ${e.message}`);
      skipped++;
    }
  }

  // Hubungkan sekolah demo ke SPPG Semarang Tengah (jika ada)
  try {
    const updated = await prisma.school.updateMany({
      where: { id: 'school-sdn-01' },
      data: { sppgId: 'sppg-jateng-001' },
    });
    if (updated.count > 0) {
      console.log('\n  🏫 SDN 01 Contoh dihubungkan ke SPPG Semarang Tengah');
    }
  } catch (_) {
    // sekolah demo mungkin belum ada — abaikan
  }

  // Hubungkan user demo siswa ke SPPG Semarang Tengah (jika ada)
  try {
    const updated = await prisma.user.updateMany({
      where: { email: 'siswa@mbg.test' },
      data: { sppgId: 'sppg-jateng-001' },
    });
    if (updated.count > 0) {
      console.log('  👤 siswa@mbg.test dihubungkan ke SPPG Semarang Tengah');
    }
  } catch (_) {
    // user demo mungkin belum ada — abaikan
  }

  console.log(`\n✨ SPPG seeding selesai!`);
  console.log(`   ✅ ${created} SPPG berhasil di-upsert`);
  if (skipped > 0) console.log(`   ⚠️  ${skipped} SPPG dilewati`);
  console.log(`\n   Provinsi yang dicakup:`);
  const provinces = [...new Set(sppgData.map((s) => s.provinsi))];
  provinces.forEach((p) => {
    const count = sppgData.filter((s) => s.provinsi === p).length;
    console.log(`   - ${p}: ${count} SPPG`);
  });
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error('❌ Seed SPPG error:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
