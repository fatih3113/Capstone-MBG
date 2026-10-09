import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/history_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/scan_history_model.dart';
import '../../shared/widgets/state_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<HistoryProvider>().loadHistory(auth.user?.id ?? 'user1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Scan'),
        actions: [
          IconButton(
            onPressed: () => context.push('/stats'),
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistik',
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, history, _) {
          if (history.isLoading) {
            return const AppLoadingWidget(message: 'Memuat riwayat...');
          }
          if (history.error != null) {
            return AppErrorWidget(
              message: history.error!,
              onRetry: () {
                final auth = context.read<AuthProvider>();
                history.loadHistory(auth.user?.id ?? 'user1');
              },
            );
          }
          if (history.history.isEmpty) {
            return EmptyStateWidget(
              title: 'Belum ada riwayat',
              subtitle: 'Scan menu MBG pertama Anda untuk mulai melacak gizi',
              icon: Icons.history_outlined,
              onAction: () => context.go('/scan'),
              actionLabel: 'Mulai Scan',
            );
          }
          return _buildHistoryList(history.history);
        },
      ),
    );
  }

  Widget _buildHistoryList(List<ScanHistoryModel> historyList) {
    // Group by date
    final grouped = <String, List<ScanHistoryModel>>{};
    for (final h in historyList) {
      final dateKey = AppFormatters.formatDate(h.scannedAt);
      grouped.putIfAbsent(dateKey, () => []).add(h);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: grouped.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(entry.key, style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary)),
              ],
            ),
          ),
          ...entry.value.map((h) => _HistoryCard(
            history: h,
            onTap: () => context.push('/history/${h.id}', extra: h),
          )),
          const SizedBox(height: 8),
        ],
      )).toList(),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ScanHistoryModel history;
  final VoidCallback onTap;
  const _HistoryCard({required this.history, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Image / placeholder
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🍱', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.foodNames.take(2).join(', ') +
                        (history.predictions.length > 2
                            ? ' +${history.predictions.length - 2} lainnya'
                            : ''),
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatRelativeDate(history.scannedAt),
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 6),
                  // Nutrition chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _NutritionMini(
                        value: '${history.totalCalories.toStringAsFixed(0)} kcal',
                        color: AppColors.calories),
                      _NutritionMini(
                        value: '${history.totalProtein.toStringAsFixed(1)}g protein',
                        color: AppColors.protein),
                      if (history.consumptionData != null)
                        _NutritionMini(
                          value: '${history.consumptionData!.consumptionPercentage.toStringAsFixed(0)}% dimakan',
                          color: history.consumptionData!.consumptionPercentage >= 75
                              ? AppColors.success : AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              children: [
                // Sensory score stars jika ada
                if (history.sensoryData != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) => Icon(
                      i < history.sensoryData!.tasteScore.round()
                          ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i < history.sensoryData!.tasteScore.round()
                          ? AppColors.warning : AppColors.cardBorder,
                      size: 12,
                    )),
                  ),
                if (history.sensoryData != null) const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 16),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: AppColors.textHint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionMini extends StatelessWidget {
  final String value;
  final Color color;
  const _NutritionMini({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(value, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}
