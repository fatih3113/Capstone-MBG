import request from 'supertest';
import app from '../../src/index';

describe('Auth API', () => {
  // ─── Register ────────────────────────────────────────────────────────
  describe('POST /api/v1/auth/register', () => {
    it('should register a new user successfully', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Test User',
          email: `test_${Date.now()}@example.com`,
          password: 'password123',
          gender: 'L',
          age: 12,
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('id');
      expect(res.body.data.name).toBe('Test User');
    });

    it('should return 422 for invalid email', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Test User',
          email: 'invalid-email',
          password: 'password123',
        });

      expect(res.status).toBe(422);
      expect(res.body.success).toBe(false);
    });

    it('should return 422 for short password', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Test User',
          email: 'test@example.com',
          password: '123',
        });

      expect(res.status).toBe(422);
    });
  });

  // ─── Login ───────────────────────────────────────────────────────────
  describe('POST /api/v1/auth/login', () => {
    it('should login with correct credentials', async () => {
      // Note: This test requires a seeded user in the test database
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'admin@mbg.test',
          password: 'password123',
        });

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('token');
      expect(res.body.data).toHaveProperty('user');
    });

    it('should return 401 for wrong password', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'admin@mbg.test',
          password: 'wrongpassword',
        });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });

    it('should return 422 for missing email', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({ password: 'password123' });

      expect(res.status).toBe(422);
    });
  });

  // ─── Health Check ────────────────────────────────────────────────────
  describe('GET /health', () => {
    it('should return health status', async () => {
      const res = await request(app).get('/health');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toContain('running');
    });
  });

  // ─── 404 ─────────────────────────────────────────────────────────────
  describe('Unknown routes', () => {
    it('should return 404 for unknown routes', async () => {
      const res = await request(app).get('/api/v1/nonexistent');
      expect(res.status).toBe(404);
    });
  });
});
