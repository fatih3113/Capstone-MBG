import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/menu_provider.dart';
import '../../data/models/daily_nutrition_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<HistoryProvider>().loadHistory(auth.user!.id);
      context.read<MenuProvider>().loadWeeklyMenu();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final history = context.watch<HistoryProvider>();
    final menu = context.watch<MenuProvider>();
    final today = history.dailyNutrition.isNotEmpty
        ? history.dailyNutrition.first
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(auth.userName),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Nutrition summary card
                  _buildNutritionSummary(today),
                  const SizedBox(height: 20),

                  // Quick actions
                  _buildSectionTitle('Fitur Utama'),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),

                  // Today's menu
                  _buildSectionTitle('Menu Hari Ini'),
                  const SizedBox(height: 12),
                  _buildTodayMenu(menu),
                  const SizedBox(height: 20),

                  // Nutrition food guide
                  _buildSectionTitle('Panduan Makanan Bergizi'),
                  const SizedBox(height: 4),
                  const Text(
                    'Kelompok makanan penting untuk tubuh sehat',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionGuide(),
                  const SizedBox(height: 20),

                  // Recent scan
                  _buildSectionTitle('Scan Terakhir'),
                  const SizedBox(height: 12),
                  _buildRecentScans(history),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()},',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$userName 👋',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.restaurant_rounded,
                  color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Sudah makan menu MBG hari ini?',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(DailyNutritionModel? today) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gizi Hari Ini', style: AppTextStyles.titleMedium),
              GestureDetector(
                onTap: () => context.push('/stats'),
                child: Text('Lihat Detail',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniNutritionBar(
                label: 'Kalori',
                value: today?.totalCalories ?? 0,
                target: today?.caloriesTarget ?? 2000,
                unit: 'kcal',
                color: AppColors.calories,
              ),
              const SizedBox(width: 12),
              _MiniNutritionBar(
                label: 'Protein',
                value: today?.totalProtein ?? 0,
                target: today?.proteinTarget ?? 60,
                unit: 'g',
                color: AppColors.protein,
              ),
              const SizedBox(width: 12),
              _MiniNutritionBar(
                label: 'Karbo',
                value: today?.totalCarbs ?? 0,
                target: today?.carbsTarget ?? 300,
                unit: 'g',
                color: AppColors.carbs,
              ),
              const SizedBox(width: 12),
              _MiniNutritionBar(
                label: 'Lemak',
                value: today?.totalFat ?? 0,
                target: today?.fatTarget ?? 65,
                unit: 'g',
                color: AppColors.fat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleLarge);
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction('Scan\nMenu MBG', Icons.qr_code_scanner_rounded,
        AppColors.primary, () => context.go('/scan')),
      _QuickAction('Riwayat\nScan', Icons.history_rounded,
        AppColors.info, () => context.go('/history')),
      _QuickAction('Menu\nMBG', Icons.restaurant_menu_rounded,
        AppColors.secondary, () => context.go('/menu')),
      _QuickAction('Statistik\nGizi', Icons.bar_chart_rounded,
        AppColors.success, () => context.push('/stats')),
    ];

    // FIX: pakai tinggi tetap (mainAxisExtent) supaya tidak overflow,
    // dan padding zero supaya tidak ada jarak kosong di atas grid.
    return GridView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 140,
      ),
      children: actions.map((a) => _QuickActionCard(action: a)).toList(),
    );
  }

  Widget _buildTodayMenu(MenuProvider menu) {
    if (menu.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final todayMenu = menu.todayMenu;
    if (todayMenu == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Text('Menu hari ini belum tersedia'),
      );
    }

    return GestureDetector(
      onTap: () => context.go('/menu'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.cardGradient),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(todayMenu.dayName,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white)),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: todayMenu.items.map((item) => _FoodChip(
                name: item.food.name,
                category: item.food.category,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionGuide() {
    final guides = [
      const _NutritionGuide(
        emoji: '🍚',
        title: 'Karbohidrat',
        subtitle: 'Sumber energi utama',
        color: AppColors.carbs,
        bgColor: Color(0xFFFFFDE7),
        examples: ['Nasi', 'Roti Gandum', 'Ubi', 'Jagung'],
        tip: '½ piring per makan',
      ),
      const _NutritionGuide(
        emoji: '🍗',
        title: 'Protein',
        subtitle: 'Bangun & perbaiki otot',
        color: AppColors.protein,
        bgColor: Color(0xFFE0F7FA),
        examples: ['Ayam', 'Ikan', 'Telur', 'Tahu', 'Tempe'],
        tip: '¼ piring per makan',
      ),
      const _NutritionGuide(
        emoji: '🥦',
        title: 'Sayuran',
        subtitle: 'Kaya vitamin & serat',
        color: AppColors.success,
        bgColor: Color(0xFFE8F5E9),
        examples: ['Bayam', 'Brokoli', 'Wortel', 'Kangkung'],
        tip: '¼ piring per makan',
      ),
      const _NutritionGuide(
        emoji: '🍎',
        title: 'Buah-buahan',
        subtitle: 'Vitamin & antioksidan',
        color: AppColors.calories,
        bgColor: Color(0xFFFFEBEE),
        examples: ['Pisang', 'Jeruk', 'Apel', 'Pepaya'],
        tip: '2-3 porsi per hari',
      ),
      const _NutritionGuide(
        emoji: '🥑',
        title: 'Lemak Sehat',
        subtitle: 'Dukung fungsi otak',
        color: AppColors.secondary,
        bgColor: Color(0xFFFFF3E0),
        examples: ['Alpukat', 'Kacang', 'Minyak Zaitun', 'Ikan Salmon'],
        tip: 'Secukupnya, jangan berlebih',
      ),
    ];

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: guides.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _NutritionGuideCard(guide: guides[index]);
        },
      ),
    );
  }

  Widget _buildRecentScans(HistoryProvider history) {
    if (history.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (history.history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Center(
          child: Text('Belum ada scan. Mulai scan menu MBG!'),
        ),
      );
    }

    final recent = history.history.take(2).toList();
    return Column(
      children: recent.map((h) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('🍱', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.foodNames.take(2).join(', ') +
                        (h.predictions.length > 2 ? ' +${h.predictions.length - 2}' : ''),
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppFormatters.formatRelativeDate(h.scannedAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${h.totalCalories.toStringAsFixed(0)} kcal',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.calories),
                ),
                Text('${h.predictions.length} makanan',
                  style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _MiniNutritionBar extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;

  const _MiniNutritionBar({
    required this.label, required this.value, required this.target,
    required this.unit, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50, height: 50,
                child: CircularProgressIndicator(
                  value: pct,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 5,
                ),
              ),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: color, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption),
          Text(
            '${value.toStringAsFixed(0)}$unit',
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.color, this.onTap);
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(action.label,
              style: AppTextStyles.titleSmall.copyWith(color: action.color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _FoodChip extends StatelessWidget {
  final String name;
  final String category;
  const _FoodChip({required this.name, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(name,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
    );
  }
}

// ── Nutrition Guide Data & Card ──────────────────────────────────────────────

class _NutritionGuide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final List<String> examples;
  final String tip;

  const _NutritionGuide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.examples,
    required this.tip,
  });
}

class _NutritionGuideCard extends StatelessWidget {
  final _NutritionGuide guide;
  const _NutritionGuideCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: guide.bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: guide.color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: guide.color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji + title
          Row(
            children: [
              Text(guide.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  guide.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: guide.color,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            guide.subtitle,
            style: AppTextStyles.caption.copyWith(
              color: guide.color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 10),
          // Example foods
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: guide.examples.take(4).map((food) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: guide.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  food,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: guide.color,
                    fontSize: 10,
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Portion tip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: guide.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded,
                  size: 11, color: guide.color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    guide.tip,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: guide.color,
                      fontSize: 9.5,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}