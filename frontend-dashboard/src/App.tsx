import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from '@/hooks/useAuth';
import Layout from '@/components/layout/Layout';
import LoginPage from '@/pages/LoginPage';
import DashboardPage from '@/pages/DashboardPage';
import MenuRequestsPage from '@/pages/MenuRequestsPage';
import FoodRatingsPage from '@/pages/FoodRatingsPage';
import FeedbackPage from '@/pages/FeedbackPage';
import NutritionPage from '@/pages/NutritionPage';
import DistributionPage from '@/pages/DistributionPage';
import FoodsPage from '@/pages/FoodsPage';
import SchoolsPage from '@/pages/SchoolsPage';

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Public */}
          <Route path="/login" element={<LoginPage />} />

          {/* Protected — semua halaman di bawah Layout (requires auth) */}
          <Route element={<Layout />}>
            <Route index element={<DashboardPage />} />
            <Route path="menu-requests" element={<MenuRequestsPage />} />
            <Route path="food-ratings" element={<FoodRatingsPage />} />
            <Route path="feedback" element={<FeedbackPage />} />
            <Route path="nutrition" element={<NutritionPage />} />
            <Route path="distribution" element={<DistributionPage />} />
            <Route path="foods" element={<FoodsPage />} />
            <Route path="schools" element={<SchoolsPage />} />
          </Route>

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
