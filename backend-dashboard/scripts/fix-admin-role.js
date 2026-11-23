const { PrismaClient } = require('../node_modules/@prisma/client');
const bcrypt = require('../node_modules/bcryptjs');

async function main() {
  const p = new PrismaClient();
  try {
    const hash = await bcrypt.hash('admin123', 12);
    // Role yang benar di sistem ini: 'BGN_ADMIN' (bukan SUPER_ADMIN)
    const user = await p.user.update({
      where: { email: 'admin@mbg.test' },
      data: {
        passwordHash: hash,
        accountStatus: 'ACTIVE',
        role: 'BGN_ADMIN',
      },
      select: { email: true, role: true, accountStatus: true }
    });
    console.log('Updated:', JSON.stringify(user));
    console.log('Login credentials: admin@mbg.test / admin123');
  } finally {
    await p.$disconnect();
  }
}

main().catch(console.error);

