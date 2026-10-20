import { apiClient } from './client';
import type {
  LoginResponse, DashboardOverview,
  MenuRequest, GroupedMenuRequest, MenuRequestStatus,
  FoodRanking, FoodRatingRecord,
  FeedbackSummary, FeedbackRecord,
  NutritionReport, NutritionStats,
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
