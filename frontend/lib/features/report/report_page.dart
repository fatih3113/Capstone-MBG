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

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report MBG'),
        backgroundColor: AppColors.white,
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
