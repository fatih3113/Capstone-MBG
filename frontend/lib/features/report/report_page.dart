// Halaman Laporan (Report): navigasi 3 tab aspirasi makanan MBG (Usulan Menu baru, Rating Makanan Favorit, dan Feedback Kualitas Makanan).

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'tabs/menu_request_tab.dart';
import 'tabs/food_rating_tab.dart';
import 'tabs/food_feedback_tab.dart';

/// Halaman utama Report MBG
/// Berisi 3 tab: Permintaan Menu, Makanan Favorit, Feedback Makanan
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

// SingleTickerProviderStateMixin: mengendalikan transisi animasi geser antar tab laporan.
class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Menginisialisasi controller 3 tab: Usulan Menu, Favorit, dan Feedback.
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Mematikan controller tab agar tidak ada kebocoran memori.
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: kerangka halaman laporan dengan TabBar navigasi di bawah judul AppBar.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report MBG'),
        backgroundColor: AppColors.white,
        // TabBar: bilah 3 tombol tab dilengkapi ikon dan label nama menu laporan.
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700),
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_menu_rounded, size: 18),
              text: 'Usulan Menu',
            ),
            Tab(
              icon: Icon(Icons.star_rounded, size: 18),
              text: 'Favorit',
            ),
            Tab(
              icon: Icon(Icons.feedback_rounded, size: 18),
              text: 'Feedback',
            ),
          ],
        ),
      ),
      // TabBarView: menampilkan konten halaman tab yang aktif (MenuRequestTab, FoodRatingTab, atau FoodFeedbackTab).
      body: TabBarView(
        controller: _tabController,
        children: const [
          MenuRequestTab(),
          FoodRatingTab(),
          FoodFeedbackTab(),
        ],
      ),
    );
  }
}
