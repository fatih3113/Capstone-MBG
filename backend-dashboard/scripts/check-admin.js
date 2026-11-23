const { PrismaClient } = require('../node_modules/@prisma/client');
const bcrypt = require('../node_modules/bcryptjs');

async function main() {
  const p = new PrismaClient();
  try {
    const users = await p.user.findMany({
      where: { role: 'SUPER_ADMIN' },
      select: { id: true, email: true, passwordHash: true, accountStatus: true }
    });
    console.log('=== SUPER ADMIN USERS ===');
    for (const u of users) {
      const matchAdmin123 = await bcrypt.compare('admin123', u.passwordHash);
      const matchPassword123 = await bcrypt.compare('password123', u.passwordHash);
      console.log({
        email: u.email,
        accountStatus: u.accountStatus,
        hashPrefix: u.passwordHash.substring(0, 20) + '...',
        matchAdmin123,
        matchPassword123,
      });
    }
  } finally {
    await p.$disconnect();
  }
}

main().catch(console.error);
