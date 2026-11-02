// Semua tipe API response dari backend-dashboard

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
}

export interface PaginatedResponse<T> {
  records: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// Auth
export interface AuthUser {
  id: string;
  name: string;
  email: string;
  role: string;
}

export interface LoginResponse {
  token: string;
  user: AuthUser;
}

// Dashboard
export interface DashboardSummary {
  totalMenuRequests: number;
  totalFoodRatings: number;
  totalFeedbacks: number;
  totalScans: number;
  avgFoodRating: number | null;
}

export interface StatusCount { status: string; count: number; }
export interface FavoriteFood { foodName: string; avgRating: number; voteCount: number; }

export interface RecentScan {
  id: string;
  scannedAt: string;
  akgTarget: string | null;
  user: { name: string; email: string; schoolLevel: string | null };
  nutrition: { calories: number; protein: number; carbs: number; fat: number };
  foods: string[];
}

export interface DashboardOverview {
  summary: DashboardSummary;
  menuRequestsByStatus: StatusCount[];
  consumptionSummary: StatusCount[];
  topFavorites: FavoriteFood[];
  recentScans: RecentScan[];
}

// Menu Requests
export interface MenuRequest {
  id: string;
  menuName: string;
  reason: string | null;
  status: string;
  adminNote: string | null;
  submittedAt: string;
  updatedAt: string;
  user: { name: string; email: string; schoolLevel: string | null; class_: string | null };
}

export type MenuRequestStatus = 'received' | 'reviewing' | 'considered' | 'approved' | 'rejected';

export interface GroupedMenuRequest { menuName: string; count: number; }

// Food Ratings
export interface FoodRanking {
  rank: number;
  foodName: string;
  avgRating: number;
  voteCount: number;
}

export interface FoodRatingRecord {
  id: string;
  foodName: string;
  rating: number;
  reason: string | null;
  ratedAt: string;
  user: { name: string; schoolLevel: string | null };
}

// Food Feedbacks
export interface FoodSentiment {
  foodName: string;
  avgSatisfaction: number | null;
  avgTaste: number | null;
  totalFeedbacks: number;
}

export interface LeftoverReport {
  foodName: string;
  reportCount: number;
  note: string;
}

export interface FeedbackSummary {
  consumptionDistribution: StatusCount[];
  foodSentiment: FoodSentiment[];
  mostLeftoverReported: LeftoverReport[];
}

export interface FeedbackRecord {
  id: string;
  foodName: string;
  tastRating: number | null;
  textureRating: number | null;
  aromaRating: number | null;
  portionRating: number | null;
  satisfactionRating: number | null;
  consumptionStatus: string | null;
  suggestion: string | null;
  submittedAt: string;
  user: { name: string; schoolLevel: string | null };
}

// Nutrition Reports
export interface NutritionReport {
  id: string;
  scannedAt: string;
  akgTarget: string | null;
  user: { name: string; email: string; schoolLevel: string | null; class_: string | null };
  estimatedNutrition: {
    calories: number; protein: number; carbs: number; fat: number; fiber: number;
  };
  foods: { name: string; category: string; confidence: number; portionGram: number }[];
  disclaimer: string;
}

export interface NutritionStats {
  totalScans: number;
  avgCalories: number;
  avgProtein: number;
  avgCarbs: number;
  avgFat: number;
  disclaimer: string;
}

// ── Distribusi MBG ──────────────────────────────────────────────────────
export interface DistributionSummary {
  totalMenuSchedules: number;
  totalSchoolsCovered: number;
  totalFoodItems: number;
  dateRange: { earliest: string | null; latest: string | null };
}

export interface SchoolTopFood {
  name: string;
  category: string;
  count: number;
}

export interface SchoolDistribution {
  schoolId: string;
  schoolName: string;
  level: string;
  city: string | null;
  menuCount: number;
  recentDates: string[];
  topFoods: SchoolTopFood[];
}

export interface DistributionMenuItem {
  name: string;
  category: string;
  portionGram: number;
}

export interface DistributionRecord {
  id: string;
  date: string;
  dayName: string;
  school: { name: string; level: string; city: string | null };
  foods: DistributionMenuItem[];
}

export interface School {
  id: string; name: string; level: string;
  address: string | null; city: string | null;
}

export interface FoodOption {
  id: string; name: string; category: string;
}

// ── CRUD Makanan ──────────────────────────────────────────────────────
export interface FoodNutrition {
  id: string; foodId: string;
  calories: number; protein: number; carbs: number; fat: number; fiber: number;
  sugar: number; sodium: number; calcium: number; iron: number;
  vitaminC: number; vitaminA: number;
  portionGram: number; cookingMethod: string | null; dataSource: string;
}

export interface FoodItem {
  id: string; name: string; category: string;
  description: string | null; imageUrl: string | null; isActive: boolean;
  nutrition: FoodNutrition | null;
}

// ── Data Pengguna Mobile ───────────────────────────────────────────
export interface UserItem {
  id: string; name: string; email: string;
  gender: 'L' | 'P' | null; age: number | null;
  className: string | null; schoolLevel: string | null;
  createdAt: string;
  allergies: string[]; allergyOther: string | null; allergyFilled: boolean;
  school: { id: string; name: string } | null;
  sppg: { id: string; nama: string } | null;
}

export interface UserSummary {
  total: number; newThisMonth: number; withAllergy: number;
  withoutSchool: number; male: number; female: number;
}

// ── CRUD Sekolah ───────────────────────────────────────────────────
export interface SchoolItem {
  id: string; name: string; level: string;
  address: string | null; city: string | null;
  sppgId: string | null;
  sppg: { id: string; nama: string; provinsi: string; kabupatenKota: string } | null;
  _count: { mbgMenus: number };
}

// ── SPPG ─────────────────────────────────────────────────────────
export interface SppgItem {
  id: string;
  kode: string | null;
  nama: string;
  provinsi: string;
  kabupatenKota: string;
  kecamatan: string;
  kelurahanDesa: string;
  alamat: string | null;
  latitude: number | null;
  longitude: number | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  _count: { users: number; schools: number };
}

export interface SppgSummaryStats {
  totalSppg: number;
  totalProvinsi: number;
  totalKabupaten: number;
  totalSiswa: number;
}

export interface SppgListItem {
  id: string;
  kode: string | null;
  nama: string;
  kecamatan: string;
  kelurahanDesa: string;
  alamat: string | null;
  latitude: number | null;
  longitude: number | null;
  jumlahSekolah: number;
  jumlahSiswaTerdaftar: number;
  jumlahScan: number;
  rataRataRating: number | null;
  distribusiKonsumsi: Record<string, number>;
}

export interface SppgKecamatan {
  kecamatan: string;
  sppgList: SppgListItem[];
  jumlahSppg: number;
}

export interface SppgKabupaten {
  kabupatenKota: string;
  kecamatanList: SppgKecamatan[];
  jumlahSppg: number;
  jumlahSekolah: number;
  jumlahSiswaTerdaftar: number;
}

export interface SppgProvinsi {
  provinsi: string;
  kabupatenList: SppgKabupaten[];
  jumlahSppg: number;
  jumlahSekolah: number;
  jumlahSiswaTerdaftar: number;
}

export interface SppgRegionSummary {
  summary: SppgSummaryStats;
  wilayah: SppgProvinsi[];
}

export interface SppgOption {
  id: string;
  kode: string | null;
  nama: string;
  provinsi: string;
  kabupatenKota: string;
  kecamatan: string;
}