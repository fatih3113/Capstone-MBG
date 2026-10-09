import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database MBG Nutrition...\n');

  // ─── SCHOOL ──────────────────────────────────────────────────────────
  const school = await prisma.school.upsert({
    where: { id: 'school-sdn-01' },
    update: {},
    create: {
      id: 'school-sdn-01',
      name: 'SDN 01 Contoh',
      level: 'SD',
      address: 'Jl. Pendidikan No. 1',
      city: 'Jakarta',
    },
  });
  console.log('✅ School created:', school.name);

  // ─── DEMO USER ───────────────────────────────────────────────────────
  const passwordHash = await bcrypt.hash('password123', 12);
  const user = await prisma.user.upsert({
    where: { email: 'admin@mbg.test' },
    update: {},
    create: {
      name: 'Admin MBG',
      email: 'admin@mbg.test',
      passwordHash,
      schoolId: school.id,
      class_: '6A',
      gender: 'L',
      age: 12,
      schoolLevel: 'SD',
    },
  });
  console.log('✅ Demo user created:', user.email);

  // ─── FOODS + NUTRITION ───────────────────────────────────────────────
  const foods = [
    { name: 'Nasi Putih',        category: 'Karbohidrat',    cal: 130, prot: 2.7,  carb: 28.2, fat: 0.3,  fib: 0.4,  sugar: 0,    port: 200 },
    { name: 'Ayam Goreng',       category: 'Protein Hewani', cal: 260, prot: 27.0, carb: 2.5,  fat: 16.0, fib: 0,    sugar: 0,    port: 100 },
    { name: 'Telur Rebus',       category: 'Protein Hewani', cal: 155, prot: 13.0, carb: 1.1,  fat: 11.0, fib: 0,    sugar: 0,    port: 55  },
    { name: 'Ikan Goreng',       category: 'Protein Hewani', cal: 200, prot: 24.0, carb: 0.5,  fat: 11.5, fib: 0,    sugar: 0,    port: 100 },
    { name: 'Tempe Goreng',      category: 'Protein Nabati', cal: 190, prot: 17.0, carb: 9.0,  fat: 9.5,  fib: 3.8,  sugar: 0,    port: 75  },
    { name: 'Tahu Goreng',       category: 'Protein Nabati', cal: 120, prot: 9.0,  carb: 3.0,  fat: 8.0,  fib: 0.3,  sugar: 0,    port: 75  },
    { name: 'Sayur Bayam',       category: 'Sayuran',        cal: 23,  prot: 2.9,  carb: 3.6,  fat: 0.4,  fib: 2.2,  sugar: 0.4,  port: 75  },
    { name: 'Sayur Wortel',      category: 'Sayuran',        cal: 41,  prot: 0.9,  carb: 9.6,  fat: 0.2,  fib: 2.8,  sugar: 4.7,  port: 75  },
    { name: 'Pisang',            category: 'Buah',           cal: 89,  prot: 1.1,  carb: 22.8, fat: 0.3,  fib: 2.6,  sugar: 12.2, port: 100 },
    { name: 'Jeruk',             category: 'Buah',           cal: 47,  prot: 0.9,  carb: 11.8, fat: 0.1,  fib: 2.4,  sugar: 9.4,  port: 100 },
    { name: 'Susu Putih',        category: 'Minuman',        cal: 61,  prot: 3.2,  carb: 4.8,  fat: 3.3,  fib: 0,    sugar: 5.1,  port: 200 },
    { name: 'Mie Goreng',        category: 'Karbohidrat',    cal: 220, prot: 5.5,  carb: 33.0, fat: 8.0,  fib: 1.0,  sugar: 2.5,  port: 150 },
    { name: 'Perkedel Kentang',  category: 'Karbohidrat',    cal: 180, prot: 4.5,  carb: 20.0, fat: 9.0,  fib: 1.5,  sugar: 1.0,  port: 75  },
    { name: 'Tumis Kangkung',    category: 'Sayuran',        cal: 35,  prot: 2.5,  carb: 4.5,  fat: 1.5,  fib: 2.5,  sugar: 0.8,  port: 75  },
    { name: 'Semangka',          category: 'Buah',           cal: 30,  prot: 0.6,  carb: 7.6,  fat: 0.2,  fib: 0.4,  sugar: 6.2,  port: 200 },
  ];

  const foodIds: string[] = [];
  for (const f of foods) {
    const food = await prisma.food.create({
      data: {
        name: f.name,
        category: f.category,
        nutrition: {
          create: {
            calories: f.cal,
            protein: f.prot,
            carbs: f.carb,
            fat: f.fat,
            fiber: f.fib,
            sugar: f.sugar,
            portionGram: f.port,
          },
        },
      },
    });
    foodIds.push(food.id);
  }
  console.log(`✅ ${foods.length} foods + nutrition seeded`);

  // ─── WEEKLY MENU ─────────────────────────────────────────────────────
  const monday = new Date();
  monday.setDate(monday.getDate() - (monday.getDay() || 7) + 1);
  monday.setHours(0, 0, 0, 0);

  const menuConfig = [
    { day: 'Senin',  offset: 0, foods: [0, 1, 6, 8, 10] },
    { day: 'Selasa', offset: 1, foods: [0, 2, 7, 9, 10] },
    { day: 'Rabu',   offset: 2, foods: [0, 3, 6, 14, 10] },
    { day: 'Kamis',  offset: 3, foods: [0, 4, 5, 13, 8, 10] },
    { day: 'Jumat',  offset: 4, foods: [11, 2, 7, 9, 10] },
  ];

  for (const m of menuConfig) {
    const menuDate = new Date(monday);
    menuDate.setDate(monday.getDate() + m.offset);

    await prisma.mbgMenu.create({
      data: {
        schoolId: school.id,
        date: menuDate,
        dayName: m.day,
        items: {
          create: m.foods.map((fi) => ({
            foodId: foodIds[fi],
            portionGram: fi === 0 || fi === 10 || fi === 11 ? 200 : fi === 4 || fi === 5 || fi === 13 ? 75 : 100,
          })),
        },
      },
    });
  }
  console.log('✅ Weekly MBG menu seeded (Senin - Jumat)');

  console.log('\n✨ Seeding selesai!');
  console.log('🔑 Demo login: admin@mbg.test / password123');
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error('❌ Seed error:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
