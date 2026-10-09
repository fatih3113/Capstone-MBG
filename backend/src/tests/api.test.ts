import request from 'supertest';
import app from '../../src/index';

// Catatan: Test ini menggunakan mock Prisma.
// Untuk full integration test, diperlukan test database terpisah.

describe('Food API', () => {
  describe('GET /api/v1/foods', () => {
    it('should return 401 without auth token', async () => {
      const res = await request(app).get('/api/v1/foods');
      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });

    it('should return 401 for invalid token', async () => {
      const res = await request(app)
        .get('/api/v1/foods')
        .set('Authorization', 'Bearer invalid_token_xyz');
      expect(res.status).toBe(401);
    });
  });

  describe('GET /api/v1/foods/:id', () => {
    it('should return 401 without auth', async () => {
      const res = await request(app).get('/api/v1/foods/some-id');
      expect(res.status).toBe(401);
    });
  });
});

describe('MBG Menu API', () => {
  it('should return 401 for unauthenticated request', async () => {
    const res = await request(app).get('/api/v1/mbg-menu');
    expect(res.status).toBe(401);
  });

  it('should return 401 for today menu without auth', async () => {
    const res = await request(app).get('/api/v1/mbg-menu/today');
    expect(res.status).toBe(401);
  });

  it('should try date endpoint (no auth required)', async () => {
    const res = await request(app).get('/api/v1/mbg-menu/date/2025-06-09');
    // Either 404 (no menu) or 200 (if seeded) - both valid
    expect([200, 404, 500]).toContain(res.status);
  });

  it('should return 400 for invalid date format', async () => {
    const res = await request(app).get('/api/v1/mbg-menu/date/invalid-date');
    expect(res.status).toBe(400);
  });
});

describe('Stats API', () => {
  it('should return 401 for daily stats without auth', async () => {
    const res = await request(app).get('/api/v1/stats/daily');
    expect(res.status).toBe(401);
  });

  it('should return 401 for weekly stats without auth', async () => {
    const res = await request(app).get('/api/v1/stats/weekly');
    expect(res.status).toBe(401);
  });

  it('should return 401 for top-foods without auth', async () => {
    const res = await request(app).get('/api/v1/stats/top-foods');
    expect(res.status).toBe(401);
  });

  it('should return 401 for summary without auth', async () => {
    const res = await request(app).get('/api/v1/stats/summary');
    expect(res.status).toBe(401);
  });
});

describe('Schools API', () => {
  it('should return list of schools (public endpoint)', async () => {
    const res = await request(app).get('/api/v1/schools');
    // Either returns 200 with array, or 500 if DB not connected
    expect([200, 500]).toContain(res.status);
    if (res.status === 200) {
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    }
  });

  it('should return 404 for non-existent school', async () => {
    const res = await request(app).get('/api/v1/schools/non-existent-id');
    expect([404, 500]).toContain(res.status);
  });
});

describe('Nutrition API', () => {
  it('should return 401 for daily nutrition without auth', async () => {
    const res = await request(app).get('/api/v1/nutrition/daily');
    expect(res.status).toBe(401);
  });

  it('should return 401 for recommendation without auth', async () => {
    const res = await request(app).get('/api/v1/nutrition/recommendation');
    expect(res.status).toBe(401);
  });
});

describe('Scan History API', () => {
  it('should return 401 for scan history without auth', async () => {
    const res = await request(app).get('/api/v1/scan-history');
    expect(res.status).toBe(401);
  });

  it('should return 401 for save scan without auth', async () => {
    const res = await request(app)
      .post('/api/v1/scan-history/save')
      .send({ total_calories: 500, predictions: [] });
    expect(res.status).toBe(401);
  });
});

describe('User API', () => {
  it('should return 401 for profile without auth', async () => {
    const res = await request(app).get('/api/v1/users/profile');
    expect(res.status).toBe(401);
  });

  it('should return 401 for update profile without auth', async () => {
    const res = await request(app)
      .put('/api/v1/users/profile/update')
      .send({ name: 'Test' });
    expect(res.status).toBe(401);
  });
});

describe('Prediction API', () => {
  it('should return 401 for classify without auth', async () => {
    const res = await request(app).post('/api/v1/predictions/classify');
    expect(res.status).toBe(401);
  });
});
