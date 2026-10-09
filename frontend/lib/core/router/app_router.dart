import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/food_model.dart';
import '../../data/models/scan_history_model.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/main/main_page.dart';
import '../../features/home/home_page.dart';
import '../../features/scan/scan_page.dart';
import '../../features/scan/image_preview_page.dart';
import '../../features/scan/prediction_result_page.dart';
import '../../features/scan/food_evaluation_page.dart';
import '../../features/scan/analysis_result_page.dart';
import '../../features/nutrition/nutrition_stats_page.dart';
import '../../features/mbg_menu/mbg_menu_page.dart';
import '../../features/mbg_menu/food_detail_page.dart';
import '../../features/history/history_page.dart';
import '../../features/history/history_detail_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/profile/edit_profile_page.dart';
import '../../features/profile/settings_page.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      redirect: (ctx, state) {
        // Auth guard - check if user is logged in
        // Skip redirect for splash, login, register, forgot-password
        return null; // Let splash handle the redirect
      },
      routes: [
        // Splash
        GoRoute(
          path: '/',
          builder: (_, __) => const SplashScreen(),
        ),

        // Auth routes
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordPage(),
        ),

        // Main shell with bottom navigation
        ShellRoute(
          builder: (_, __, child) => MainPage(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomePage(),
            ),
            GoRoute(
              path: '/scan',
              builder: (_, __) => const ScanPage(),
            ),
            GoRoute(
              path: '/menu',
              builder: (_, __) => const MbgMenuPage(),
            ),
            GoRoute(
              path: '/history',
              builder: (_, __) => const HistoryPage(),
            ),
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfilePage(),
            ),
          ],
        ),

        // Standalone routes (no bottom nav)
        GoRoute(
          path: '/scan/preview',
          builder: (_, state) {
            final imageFile = state.extra as File;
            return ImagePreviewPage(imageFile: imageFile);
          },
        ),
        GoRoute(
          path: '/scan/result',
          builder: (_, __) => const PredictionResultPage(),
        ),
        GoRoute(
          path: '/scan/evaluate',
          builder: (_, __) => const FoodEvaluationPage(),
        ),
        GoRoute(
          path: '/scan/analysis-result',
          builder: (_, __) => const AnalysisResultPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (_, __) => const NutritionStatsPage(),
        ),
        GoRoute(
          path: '/menu/food/:id',
          builder: (_, state) {
            final food = state.extra as FoodModel;
            return FoodDetailPage(food: food);
          },
        ),
        GoRoute(
          path: '/history/:id',
          builder: (_, state) {
            final history = state.extra as ScanHistoryModel;
            return HistoryDetailPage(history: history);
          },
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (_, __) => const EditProfilePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsPage(),
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('404', style: TextStyle(fontSize: 48,
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Halaman tidak ditemukan: ${state.uri}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali ke Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
