import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function seedDistribution() {
  console.log('🌱 Seeding distribusi MBG...');

  // Ambil food IDs
  const foods = await prisma.food.findMany({ where: { isActive: true } });
  const f = (name: string) => foods.find((f) => f.name === name)?.id ?? '';

  // Sekolah 2
  const school2 = await prisma.school.upsert({
    where: { id: 'school-smp-cibinong' },
    create: {
      id: 'school-smp-cibinong',
      name: 'SMP Negeri 3 Cibinong',
      level: 'SMP',
      address: 'Jl. Raya Cibinong No.45',
      city: 'Bogor',
    },
    update: {},
  });

  // Sekolah 3
  const school3 = await prisma.school.upsert({
    where: { id: 'school-sma-depok' },
    create: {
      id: 'school-sma-depok',
      name: 'SMA Negeri 1 Depok',
      level: 'SMA',
      address: 'Jl. Margonda Raya No.12',
      city: 'Depok',
    },
    update: {},
  });

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const days = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];

  // 3 hari menu SMP
  for (let i = 2; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    const existing = await prisma.mbgMenu.findUnique({
      where: { schoolId_date: { schoolId: school2.id, date: d } },
    });
    if (!existing) {
      await prisma.mbgMenu.create({
        data: {
          schoolId: school2.id,
          date: d,
          dayName: days[d.getDay()],
          items: {
            create: [
              { foodId: f('Nasi Putih'), portionGram: 200 },
              { foodId: f(i % 2 === 0 ? 'Ikan Goreng' : 'Ayam Goreng'), portionGram: 100 },
              { foodId: f(i === 0 ? 'Sayur Bayam' : 'Tempe Goreng'), portionGram: 75 },
              { foodId: f('Pisang'), portionGram: 100 },
            ],
          },
        },
      });
    }
  }

  // 2 hari menu SMA
  for (let i = 1; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    const existing = await prisma.mbgMenu.findUnique({
      where: { schoolId_date: { schoolId: school3.id, date: d } },
    });
    if (!existing) {
      await prisma.mbgMenu.create({
        data: {
          schoolId: school3.id,
          date: d,
          dayName: days[d.getDay()],
          items: {
            create: [
              { foodId: f('Nasi Putih'), portionGram: 250 },
              { foodId: f(i === 1 ? 'Ayam Goreng' : 'Ikan Goreng'), portionGram: 150 },
              { foodId: f('Sayur Bayam'), portionGram: 100 },
              { foodId: f('Jeruk'), portionGram: 100 },
            ],
          },
        },
      });
    }
  }

  const totalMenus = await prisma.mbgMenu.count();
  const totalSchools = await prisma.mbgMenu.groupBy({ by: ['schoolId'] });
  console.log(`✅ Done! Total: ${totalMenus} jadwal menu, ${totalSchools.length} sekolah`);
}

seedDistribution()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
