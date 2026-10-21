import { apiClient } from './client';
import type {
  LoginResponse, DashboardOverview,
  MenuRequest, GroupedMenuRequest, MenuRequestStatus,
  FoodRanking, FoodRatingRecord,
  FeedbackSummary, FeedbackRecord,
  NutritionReport, NutritionStats,
  DistributionSummary, SchoolDistribution, DistributionRecord,
  School, FoodOption, FoodItem, SchoolItem,
  PaginatedResponse,
} from '@/types/api.types';

// ── Auth ─────────────────────────────────────────────────────
export const authApi = {
  login: (email: string, password: string) =>
    apiClient.post<{ success: boolean; data: LoginResponse }>('/auth/login', { email, password }),
  profile: () =>
    apiClient.get('/auth/profile'),
};

// ── Dashboard ────────────────────────────────────────────────
export const dashboardApi = {
  overview: (params?: { startDate?: string; endDate?: string }) =>
    apiClient.get<{ success: boolean; data: DashboardOverview }>('/dashboard', { params }),
};

// ── Menu Requests ────────────────────────────────────────────
export const menuRequestsApi = {
  list: (params?: {
    status?: string; search?: string;
    startDate?: string; endDate?: string;
    page?: number; limit?: number;
  }) =>
    apiClient.get<{ success: boolean; data: PaginatedResponse<MenuRequest> }>('/menu-requests', { params }),

  grouped: () =>
    apiClient.get<{ success: boolean; data: GroupedMenuRequest[] }>('/menu-requests/grouped'),

  updateStatus: (id: string, status: MenuRequestStatus, adminNote?: string) =>
    apiClient.patch<{ success: boolean; data: MenuRequest }>(`/menu-requests/${id}/status`, {
      status, adminNote,
    }),
};

// ── Food Ratings ─────────────────────────────────────────────
export const foodRatingsApi = {
  ranking: (params?: { startDate?: string; endDate?: string; limit?: number }) =>
    apiClient.get<{ success: boolean; data: FoodRanking[] }>('/food-ratings/ranking', { params }),

  list: (params?: {
    startDate?: string; endDate?: string;
    foodName?: string; page?: number; limit?: number;
  }) =>
    apiClient.get<{ success: boolean; data: PaginatedResponse<FoodRatingRecord> }>('/food-ratings', { params }),
};

// ── Food Feedbacks ────────────────────────────────────────────
export const foodFeedbacksApi = {
  summary: (params?: { startDate?: string; endDate?: string }) =>
    apiClient.get<{ success: boolean; data: FeedbackSummary }>('/food-feedbacks/summary', { params }),

  list: (params?: {
    startDate?: string; endDate?: string;
    foodName?: string; consumptionStatus?: string;
    page?: number; limit?: number;
  }) =>
    apiClient.get<{ success: boolean; data: PaginatedResponse<FeedbackRecord> }>('/food-feedbacks', { params }),
};

// ── Nutrition Reports ─────────────────────────────────────────
export const nutritionReportsApi = {
  stats: (params?: { startDate?: string; endDate?: string }) =>
    apiClient.get<{ success: boolean; data: NutritionStats }>('/nutrition-reports/stats', { params }),

  list: (params?: {
    startDate?: string; endDate?: string;
    akgTarget?: string; schoolLevel?: string;
    page?: number; limit?: number;
  }) =>
    apiClient.get<{ success: boolean; data: PaginatedResponse<NutritionReport> }>('/nutrition-reports', { params }),
};

// ── Distribusi MBG ke Sekolah ─────────────────────────────────
export const distributionApi = {
  summary: (params?: { startDate?: string; endDate?: string }) =>
    apiClient.get<{ success: boolean; data: DistributionSummary }>('/distribution/summary', { params }),

  perSchool: (params?: { startDate?: string; endDate?: string }) =>
    apiClient.get<{ success: boolean; data: SchoolDistribution[] }>('/distribution/per-school', { params }),

  timeline: (params?: {
    startDate?: string; endDate?: string; page?: number; limit?: number;
  }) =>
    apiClient.get<{ success: boolean; data: PaginatedResponse<DistributionRecord> }>('/distribution/timeline', { params }),

  // ── Helpers dropdown ─────────────────────────────────────────
  getSchools: () =>
    apiClient.get<{ success: boolean; data: School[] }>('/distribution/schools'),

  getFoods: () =>
    apiClient.get<{ success: boolean; data: FoodOption[] }>('/distribution/foods'),

  // ── CRUD ─────────────────────────────────────────────────────
  createSchedule: (body: {
    schoolId: string; date: string;
    items: { foodId: string; portionGram: number }[];
  }) =>
    apiClient.post<{ success: boolean; message: string; data: any }>('/distribution/schedule', body),

  updateSchedule: (id: string, body: {
    schoolId?: string; date?: string;
    items?: { foodId: string; portionGram: number }[];
  }) =>
    apiClient.put<{ success: boolean; message: string; data: any }>(`/distribution/schedule/${id}`, body),

  deleteSchedule: (id: string) =>
    apiClient.delete<{ success: boolean; message: string }>(`/distribution/schedule/${id}`),
};

// ── Makanan (Foods CRUD) ────────────────────────────────────────────
export const foodsApi = {
  categories: () =>
    apiClient.get<{ success: boolean; data: string[] }>('/foods/categories'),

  list: (params?: {
    category?: string; search?: string; isActive?: string; page?: number; limit?: number;
  }) =>
    apiClient.get<{ success: boolean; data: PaginatedResponse<FoodItem> }>('/foods', { params }),

  findOne: (id: string) =>
    apiClient.get<{ success: boolean; data: FoodItem }>(`/foods/${id}`),

  create: (body: Partial<FoodItem> & { nutrition?: Record<string, number | string> }) =>
    apiClient.post<{ success: boolean; message: string; data: FoodItem }>('/foods', body),

  update: (id: string, body: Partial<FoodItem> & { nutrition?: Record<string, number | string> }) =>
    apiClient.put<{ success: boolean; message: string; data: FoodItem }>(`/foods/${id}`, body),

  toggle: (id: string) =>
    apiClient.patch<{ success: boolean; message: string; data: FoodItem }>(`/foods/${id}/toggle`),

  delete: (id: string) =>
    apiClient.delete<{ success: boolean; message: string }>(`/foods/${id}`),
};

// ── Sekolah (Schools CRUD) ───────────────────────────────────
export const schoolsApi = {
  list: (params?: { search?: string; level?: string; page?: number; limit?: number }) =>
    apiClient.get<{ success: boolean; data: PaginatedResponse<SchoolItem> }>('/schools', { params }),

  create: (body: { name: string; level: string; address?: string; city?: string }) =>
    apiClient.post<{ success: boolean; message: string; data: SchoolItem }>('/schools', body),

  update: (id: string, body: { name?: string; level?: string; address?: string; city?: string }) =>
    apiClient.put<{ success: boolean; message: string; data: SchoolItem }>(`/schools/${id}`, body),

  delete: (id: string) =>
    apiClient.delete<{ success: boolean; message: string }>(`/schools/${id}`),
};

