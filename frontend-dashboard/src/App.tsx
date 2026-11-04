import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from '@/hooks/useAuth';
import Layout from '@/components/layout/Layout';
import RequireRole from '@/components/layout/RequireRole';
import LoginPage from '@/pages/LoginPage';
import RegisterPage from '@/pages/RegisterPage';
import DashboardPage from '@/pages/DashboardPage';
import MenuRequestsPage from '@/pages/menu-requests';
import FoodRatingsPage from '@/pages/FoodRatingsPage';
import FeedbackPage from '@/pages/FeedbackPage';
import NutritionPage from '@/pages/NutritionPage';
import DistributionPage from '@/pages/distribution';
import FoodsPage from '@/pages/foods';
import InstitutionsPage from '@/pages/institutions';
import SppgRegionsPage from '@/pages/SppgRegionsPage';
import SppgVerificationPage from '@/pages/sppg-verification';
import SppgProfilePage from '@/pages/SppgProfilePage';

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public */}
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />

          {/* Protected — semua halaman di bawah Layout (requires auth) */}
          <Route element={<Layout />}>
            {/* Semua role dashboard */}
            <Route index element={<DashboardPage />} />
            <Route path="menu-requests" element={<MenuRequestsPage />} />
            <Route path="food-ratings" element={<FoodRatingsPage />} />
            <Route path="feedback" element={<FeedbackPage />} />
            <Route path="nutrition" element={<NutritionPage />} />
            <Route path="distribution" element={<DistributionPage />} />
            <Route path="institutions" element={<InstitutionsPage />} />

            {/* Hanya Super Admin */}
            <Route path="foods" element={<RequireRole role="super"><FoodsPage /></RequireRole>} />
            <Route path="sppg" element={<RequireRole role="super"><SppgRegionsPage /></RequireRole>} />
            <Route
              path="sppg-verification"
              element={<RequireRole role="super"><SppgVerificationPage /></RequireRole>}
            />

            {/* Hanya Admin SPPG Daerah */}
            <Route path="profile" element={<RequireRole role="sppg"><SppgProfilePage /></RequireRole>} />

            {/* Link lama diarahkan ke Data Lembaga */}
            <Route path="schools" element={<Navigate to="/institutions" replace />} />
            <Route path="users" element={<Navigate to="/institutions" replace />} />
          </Route>

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
