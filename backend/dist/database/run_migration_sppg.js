"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Jalankan migration SPPG menggunakan Prisma executeRaw
 * Usage: npx ts-node src/database/run_migration_sppg.ts
 */
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function main() {
    console.log('🔧 Menjalankan migration: add_sppg\n');
    // 1. Buat tabel sppgs
    console.log('1️⃣  Membuat tabel sppgs...');
    try {
        await prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS sppgs (
        id              TEXT        PRIMARY KEY DEFAULT gen_random_uuid()::text,
        kode            TEXT        UNIQUE,
        nama            TEXT        NOT NULL,
        provinsi        TEXT        NOT NULL,
        kabupaten_kota  TEXT        NOT NULL,
        kecamatan       TEXT        NOT NULL,
        kelurahan_desa  TEXT        NOT NULL,
        alamat          TEXT,
        latitude        DOUBLE PRECISION,
        longitude       DOUBLE PRECISION,
        is_active       BOOLEAN     NOT NULL DEFAULT true,
        created_at      TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at      TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    `);
        console.log('   ✅ Tabel sppgs berhasil dibuat (atau sudah ada)');
    }
    catch (e) {
        console.error('   ❌ Gagal membuat tabel sppgs:', e.message);
        throw e;
    }
    // 2. Trigger updated_at untuk sppgs
    console.log('2️⃣  Membuat trigger updated_at untuk sppgs...');
    try {
        // Cek apakah fungsi update_updated_at_column sudah ada
        await prisma.$executeRawUnsafe(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column'
        ) THEN
          CREATE OR REPLACE FUNCTION update_updated_at_column()
          RETURNS TRIGGER AS $func$
          BEGIN
            NEW.updated_at = CURRENT_TIMESTAMP;
            RETURN NEW;
          END;
          $func$ LANGUAGE plpgsql;
        END IF;
      END
      $$;
    `);
        await prisma.$executeRawUnsafe(`
      DROP TRIGGER IF EXISTS update_sppgs_updated_at ON sppgs;
      CREATE TRIGGER update_sppgs_updated_at
        BEFORE UPDATE ON sppgs
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    `);
        console.log('   ✅ Trigger updated_at berhasil dibuat');
    }
    catch (e) {
        console.warn('   ⚠️  Trigger (non-fatal):', e.message);
    }
    // 3. Tambah kolom sppg_id ke tabel users
    console.log('3️⃣  Menambah kolom sppg_id ke tabel users...');
    try {
        await prisma.$executeRawUnsafe(`
      ALTER TABLE users ADD COLUMN IF NOT EXISTS sppg_id TEXT
    `);
        console.log('   ✅ Kolom sppg_id di users berhasil ditambah');
    }
    catch (e) {
        if (e.message.includes('already exists')) {
            console.log('   ⏭️  Kolom sppg_id sudah ada di users');
        }
        else {
            console.error('   ❌', e.message);
        }
    }
    // 4. Tambah kolom sppg_id ke tabel schools
    console.log('4️⃣  Menambah kolom sppg_id ke tabel schools...');
    try {
        await prisma.$executeRawUnsafe(`
      ALTER TABLE schools ADD COLUMN IF NOT EXISTS sppg_id TEXT
    `);
        console.log('   ✅ Kolom sppg_id di schools berhasil ditambah');
    }
    catch (e) {
        if (e.message.includes('already exists')) {
            console.log('   ⏭️  Kolom sppg_id sudah ada di schools');
        }
        else {
            console.error('   ❌', e.message);
        }
    }
    // 5. Foreign keys
    console.log('5️⃣  Menambah foreign key constraints...');
    try {
        await prisma.$executeRawUnsafe(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.table_constraints
          WHERE constraint_name = 'fk_users_sppg' AND table_name = 'users'
        ) THEN
          ALTER TABLE users
            ADD CONSTRAINT fk_users_sppg
              FOREIGN KEY (sppg_id) REFERENCES sppgs(id)
              ON DELETE SET NULL ON UPDATE CASCADE;
        END IF;
      END $$;
    `);
        await prisma.$executeRawUnsafe(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.table_constraints
          WHERE constraint_name = 'fk_schools_sppg' AND table_name = 'schools'
        ) THEN
          ALTER TABLE schools
            ADD CONSTRAINT fk_schools_sppg
              FOREIGN KEY (sppg_id) REFERENCES sppgs(id)
              ON DELETE SET NULL ON UPDATE CASCADE;
        END IF;
      END $$;
    `);
        console.log('   ✅ Foreign keys berhasil ditambah');
    }
    catch (e) {
        console.warn('   ⚠️  FK (non-fatal):', e.message);
    }
    // 6. Indexes
    console.log('6️⃣  Membuat indexes...');
    try {
        await prisma.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS idx_sppgs_provinsi ON sppgs(provinsi)`);
        await prisma.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS idx_sppgs_prov_kab ON sppgs(provinsi, kabupaten_kota)`);
        await prisma.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS idx_sppgs_is_active ON sppgs(is_active)`);
        await prisma.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS idx_users_sppg_id ON users(sppg_id)`);
        await prisma.$executeRawUnsafe(`CREATE INDEX IF NOT EXISTS idx_schools_sppg_id ON schools(sppg_id)`);
        console.log('   ✅ Indexes berhasil dibuat');
    }
    catch (e) {
        console.warn('   ⚠️  Index (non-fatal):', e.message);
    }
    console.log('\n✨ Migration add_sppg selesai!\n');
}
main()
    .then(() => prisma.$disconnect())
    .catch(async (e) => {
    console.error('\n❌ Migration gagal:', e.message);
    await prisma.$disconnect();
    process.exit(1);
});
//# sourceMappingURL=run_migration_sppg.js.map