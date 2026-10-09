import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/history_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../data/models/daily_nutrition_model.dart';
import '../../shared/widgets/state_widgets.dart';

class NutritionStatsPage extends StatefulWidget {
  const NutritionStatsPage({super.key});

  @override
  State<NutritionStatsPage> createState() => _NutritionStatsPageState();
}

class _NutritionStatsPageState extends State<NutritionStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load nutrition stats from NutritionProvider (live API)
      context.read<NutritionProvider>().loadAll();
    });
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
        title: const Text('Statistik Gizi'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Harian'),
            Tab(text: 'Rekomendasi'),
            Tab(text: 'Ringkasan'),
          ],
        ),
      ),
      body: Consumer2<NutritionProvider, HistoryProvider>(
        builder: (context, nutrition, history, _) {
          if (nutrition.isLoading) {
            return const AppLoadingWidget(message: 'Memuat statistik gizi...');
          }
          if (nutrition.state == NutritionLoadState.error) {
            return AppErrorWidget(
              message: nutrition.error ?? 'Gagal memuat data',
              onRetry: () => nutrition.loadAll(),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDailyTab(nutrition),
              _buildRecommendationTab(nutrition),
              _buildSummaryTab(nutrition, history),
            ],
          );
        },
      ),
    );
  }

  // ─── Tab: Harian (7-day charts) ────────────────────────────────────────────

  Widget _buildDailyTab(NutritionProvider nutrition) {
    final data = nutrition.weeklyNutrition;
    if (data.isEmpty) {
      return const EmptyStateWidget(
        title: 'Belum ada data',
        subtitle: 'Mulai scan makanan untuk melihat statistik',
        icon: Icons.bar_chart_outlined,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today summary card
          _buildTodayCard(nutrition),
          const SizedBox(height: 24),

          const Text('Kalori 7 Hari Terakhir', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          _buildCaloriesChart(data),
          const SizedBox(height: 24),

          const Text('Protein 7 Hari Terakhir', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          _buildProteinChart(data),
          const SizedBox(height: 24),

          const Text('Detail Per Hari', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          ...data.take(7).map((d) => _DailyNutritionRow(data: d)),
        ],
      ),
    );
  }

  Widget _buildTodayCard(NutritionProvider nutrition) {
    final pct = nutrition.caloriesPercentage;
    final statusColor = pct < 0.6
        ? AppColors.warning
        : pct > 1.1
            ? AppColors.error
            : AppColors.success;
    final statusLabel = pct < 0.6
        ? 'Kurang'
        : pct > 1.1
            ? 'Berlebih'
            : 'Cukup';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gizi Hari Ini',
                      style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nutrition.todayCalories.toStringAsFixed(0)} / ${nutrition.caloriesTarget.toStringAsFixed(0)} kcal',
                      style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: Colors.white30,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutrientChip(
                  label: 'Protein',
                  value: '${nutrition.todayProtein.toStringAsFixed(0)}g'),
              _NutrientChip(
                  label: 'Karbo',
                  value: '${nutrition.todayCarbs.toStringAsFixed(0)}g'),
              _NutrientChip(
                  label: 'Lemak',
                  value: '${nutrition.todayFat.toStringAsFixed(0)}g'),
              _NutrientChip(
                  label: 'Serat',
                  value: '${nutrition.todayFiber.toStringAsFixed(0)}g'),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab: Rekomendasi ──────────────────────────────────────────────────────

  Widget _buildRecommendationTab(NutritionProvider nutrition) {
    final rec = nutrition.recommendation;
    if (rec == null) {
      return const EmptyStateWidget(
        title: 'Rekomendasi belum tersedia',
        subtitle: 'Scan makanan terlebih dahulu untuk mendapatkan rekomendasi',
        icon: Icons.lightbulb_outline_rounded,
      );
    }

    final target = rec['target'] as Map<String, dynamic>? ?? {};
    final consumed = rec['consumed'] as Map<String, dynamic>? ?? {};
    final remaining = rec['remaining'] as Map<String, dynamic>? ?? {};
    final status = rec['status'] as String? ?? '';
    final message = rec['message'] as String? ?? '';
    final percentage = rec['percentage'] as int? ?? 0;

    Color statusColor;
    IconData statusIcon;
    if (status == 'kurang') {
      statusColor = AppColors.warning;
      statusIcon = Icons.trending_down_rounded;
    } else if (status == 'berlebih') {
      statusColor = AppColors.error;
      statusIcon = Icons.trending_up_rounded;
    } else {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(statusIcon, color: statusColor, size: 40),
                const SizedBox(height: 10),
                Text(
                  '$percentage% Terpenuhi',
                  style: AppTextStyles.headlineSmall.copyWith(
                      color: statusColor),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Target vs Konsumsi Hari Ini',
              style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          _NutrientComparisonTable(
            target: target,
            consumed: consumed,
            remaining: remaining,
          ),
        ],
      ),
    );
  }

  // ─── Tab: Ringkasan ────────────────────────────────────────────────────────

  Widget _buildSummaryTab(
      NutritionProvider nutrition, HistoryProvider history) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(nutrition),
          const SizedBox(height: 20),
          const Text('Makanan Sering Dikonsumsi',
              style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          _buildTopFoodsFromNutrition(nutrition),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(NutritionProvider nutrition) {
    final summary = nutrition.summary;
    final totalScans = summary?['totalScans'] as int? ?? 0;
    final weeklyAvgCalories = summary?['weeklyAvgCalories'] as int? ?? 0;
    final daysLogged = summary?['daysLogged'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Total Scan',
            value: totalScans.toString(),
            icon: Icons.qr_code_scanner_rounded,
          ),
          _StatItem(
            label: 'Rata Kalori/Hari',
            value: '$weeklyAvgCalories kcal',
            icon: Icons.local_fire_department_rounded,
          ),
          _StatItem(
            label: 'Hari Dicatat',
            value: '$daysLogged hari',
            icon: Icons.calendar_today_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTopFoodsFromNutrition(NutritionProvider nutrition) {
    final topFoods = nutrition.topFoods;
    if (topFoods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Center(
          child: Text('Belum ada data makanan'),
        ),
      );
    }
    return Column(
      children: topFoods.asMap().entries.map((e) {
        final food = e.value['food'] as Map<String, dynamic>? ?? {};
        final count = e.value['count'] as int? ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${e.key + 1}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food['name']?.toString() ?? '-',
                      style: AppTextStyles.titleSmall,
                    ),
                    Text(
                      food['category']?.toString() ?? '',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${count}x',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Charts ────────────────────────────────────────────────────────────────

  Widget _buildCaloriesChart(List<DailyNutritionModel> data) {
    final reversed = data.reversed.toList();
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 2500,
          barGroups: reversed.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.totalCalories,
                  color: AppColors.calories,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (val, _) =>
                    Text(val.toInt().toString(), style: AppTextStyles.caption),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  if (val.toInt() < reversed.length) {
                    return Text(
                      AppFormatters.formatDayMonth(reversed[val.toInt()].date),
                      style: AppTextStyles.caption,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildProteinChart(List<DailyNutritionModel> data) {
    final reversed = data.reversed.toList();
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: reversed
                  .asMap()
                  .entries
                  .map((e) =>
                      FlSpot(e.key.toDouble(), e.value.totalProtein))
                  .toList(),
              isCurved: true,
              color: AppColors.protein,
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.protein.withValues(alpha: 0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (val, _) =>
                    Text('${val.toInt()}g', style: AppTextStyles.caption),
              ),
            ),
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _DailyNutritionRow extends StatelessWidget {
  final DailyNutritionModel data;
  const _DailyNutritionRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                AppFormatters.formatDayMonth(data.date),
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.totalCalories.toStringAsFixed(0)} kcal',
                  style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.calories),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: data.caloriesPercent,
                  backgroundColor: AppColors.calories.withValues(alpha: 0.15),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.calories),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${data.totalScans} scan',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final String value;
  const _NutrientChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
        Text(label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70)),
      ],
    );
  }
}

class _NutrientComparisonTable extends StatelessWidget {
  final Map<String, dynamic> target;
  final Map<String, dynamic> consumed;
  final Map<String, dynamic> remaining;

  const _NutrientComparisonTable({
    required this.target,
    required this.consumed,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final nutrients = [
      {
        'label': 'Kalori',
        'unit': 'kcal',
        'target': target['caloriesTarget'],
        'consumed': consumed['calories'],
        'remaining': remaining['calories'],
        'color': AppColors.calories,
      },
      {
        'label': 'Protein',
        'unit': 'g',
        'target': target['proteinTarget'],
        'consumed': consumed['protein'],
        'remaining': remaining['protein'],
        'color': AppColors.protein,
      },
      {
        'label': 'Karbo',
        'unit': 'g',
        'target': target['carbsTarget'],
        'consumed': consumed['carbs'],
        'remaining': remaining['carbs'],
        'color': AppColors.carbs,
      },
      {
        'label': 'Lemak',
        'unit': 'g',
        'target': target['fatTarget'],
        'consumed': consumed['fat'],
        'remaining': remaining['fat'],
        'color': AppColors.fat,
      },
      {
        'label': 'Serat',
        'unit': 'g',
        'target': target['fiberTarget'],
        'consumed': consumed['fiber'],
        'remaining': remaining['fiber'],
        'color': AppColors.fiber,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: nutrients.asMap().entries.map((entry) {
          final n = entry.value;
          final isLast = entry.key == nutrients.length - 1;
          final targetVal = (n['target'] as num?)?.toDouble() ?? 0;
          final consumedVal = (n['consumed'] as num?)?.toDouble() ?? 0;
          final pct = targetVal > 0
              ? (consumedVal / targetVal).clamp(0.0, 1.0)
              : 0.0;
          final color = n['color'] as Color;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: const BorderSide(color: AppColors.cardBorder)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(n['label'] as String,
                        style: AppTextStyles.titleSmall),
                    const Spacer(),
                    Text(
                      '${consumedVal.toStringAsFixed(0)} / ${targetVal.toStringAsFixed(0)} ${n['unit']}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
