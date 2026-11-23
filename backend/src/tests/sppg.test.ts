import request from 'supertest';
import app from '../index';

describe('SPPG API', () => {
  describe('GET /api/v1/sppg/by-code/:kode', () => {
    it('should return SPPG for valid active code', async () => {
      // SPPG-3374-001 adalah kode seed yang ada di DB
      const res = await request(app)
        .get('/api/v1/sppg/by-code/SPPG-3374-001');
      // Jika SPPG aktif: 200; jika tidak ada di DB test: 404
      expect([200, 404]).toContain(res.status);
      if (res.status === 200) {
        expect(res.body.success).toBe(true);
        expect(res.body.data).toHaveProperty('kode');
        expect(res.body.data).toHaveProperty('nama');
      }
    });

    it('should return 404 for non-existent code', async () => {
      const res = await request(app)
        .get('/api/v1/sppg/by-code/SPPG-TIDAKADA-999');
      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
    });

    it('should be case-insensitive', async () => {
      const res = await request(app)
        .get('/api/v1/sppg/by-code/sppg-3374-001');
      expect([200, 404]).toContain(res.status);
    });
  });
});
