import axios from 'axios';

// URL backend-dashboard dari env variable — tidak ada secret di sini
const BASE_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:4000/api/v1';

export const apiClient = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
});

// Attach JWT token dari localStorage setiap request
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('foodler_dashboard_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle 401 — redirect ke login
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('foodler_dashboard_token');
      localStorage.removeItem('foodler_dashboard_user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  },
);

// ── Helper: download CSV response ────────────────────────────
export async function downloadCsv(path: string, filename: string, params?: Record<string, string>) {
  const response = await apiClient.get(path, {
    params,
    responseType: 'blob',
  });
  const url = URL.createObjectURL(new Blob([response.data], { type: 'text/csv;charset=utf-8;' }));
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}
