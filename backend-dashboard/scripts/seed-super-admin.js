const { PrismaClient } = require('../node_modules/@prisma/client');
const bcrypt = require('../node_modules/bcryptjs');

async function main() {
  const p = new PrismaClient();
  try {
    // Cek semua user dengan role yang mengandung 'super' atau 'admin'
    const allUsers = await p.user.findMany({
      select: { id: true, email: true, role: true, accountStatus: true }
    });
    console.log('=== ALL USERS ===');
    allUsers.forEach(u => console.log(JSON.stringify(u)));

    // Cek apakah super admin sudah ada
    const existing = allUsers.find(u => u.email === 'admin@mbg.test');
    if (existing) {
      console.log('\n=== admin@mbg.test SUDAH ADA, UPDATE PASSWORD ===');
      const hash = await bcrypt.hash('admin123', 12);
      await p.user.update({
        where: { email: 'admin@mbg.test' },
        data: { passwordHash: hash, accountStatus: 'ACTIVE', role: 'SUPER_ADMIN' }
      });
      console.log('Password berhasil diupdate ke admin123');
    } else {
      console.log('\n=== BUAT SUPER ADMIN BARU ===');
      const hash = await bcrypt.hash('admin123', 12);
      const user = await p.user.create({
        data: {
          email: 'admin@mbg.test',
          passwordHash: hash,
          name: 'Super Admin',
          role: 'BGN_ADMIN',
          accountStatus: 'ACTIVE',
          gender: 'L',
          age: 30,
        }
      });
      console.log('Super admin dibuat:', user.email, user.role);
    }
  } finally {
    await p.$disconnect();
  }
}

main().catch(console.error);
