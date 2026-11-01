import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../shared/widgets/state_widgets.dart';

/// Halaman Notifikasi (tab di bottom navigation, bukan lagi halaman terpisah).
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _onlyUnread = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi MBG'),
        centerTitle: true,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, p, _) {
          if (p.isLoading && p.items.isEmpty) {
            return const AppLoadingWidget(message: 'Memuat notifikasi...');
          }
          if (p.error != null && p.items.isEmpty) {
            return AppErrorWidget(message: p.error!, onRetry: () => p.load());
          }
          if (p.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => p.load(),
              child: LayoutBuilder(
                builder: (context, c) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: c.maxHeight,
                    child: const EmptyStateWidget(
                      title: 'Belum ada notifikasi',
                      subtitle:
                          'Jadwal distribusi ompreng MBG akan muncul di sini',
                      icon: Icons.notifications_none_rounded,
                    ),
                  ),
                ),
              ),
            );
          }

          final list =
              _onlyUnread ? p.items.where((e) => !e.isRead).toList() : p.items;

          return RefreshIndicator(
            onRefresh: () => p.load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _HeaderCard(provider: p),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _FilterChip(
                      label: 'Semua',
                      selected: !_onlyUnread,
                      onTap: () => setState(() => _onlyUnread = false),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Belum dibaca',
                      selected: _onlyUnread,
                      onTap: () => setState(() => _onlyUnread = true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Semua notifikasi sudah dibaca 🎉',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...list.map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotificationTile(item: n),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Header hijau (gaya sama dengan kartu tanggal di halaman Menu) ─────────
class _HeaderCard extends StatelessWidget {
  final NotificationProvider provider;
  const _HeaderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final unread = provider.unreadCount;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unread > 0 ? '$unread belum dibaca' : 'Semua sudah dibaca',
                  style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.items.length} notifikasi distribusi',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (unread > 0)
            TextButton(
              onPressed: provider.markAllRead,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Tandai\ndibaca',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── Item notifikasi ───────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final NotificationModel item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final date = item.scheduleDate;
    final dateText = date == null
        ? ''
        : '${AppFormatters.formatDayName(date)}, ${AppFormatters.formatDate(date)}';
    final names = item.items
        .map((e) => (e['name'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () {
        context.read<NotificationProvider>().markRead(item.id);
        _showDetail(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.white : AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? AppColors.cardBorder
                : AppColors.primary.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🍱', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: AppTextStyles.titleSmall),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (item.schoolName.isNotEmpty || dateText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [item.schoolName, dateText]
                          .where((s) => s.isNotEmpty)
                          .join(' • '),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                  if (names.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...names.take(3).map((n) => _MenuChip(label: n)),
                        if (names.length > 3)
                          _MenuChip(label: '+${names.length - 3}'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(AppFormatters.formatRelativeDate(item.createdAt),
                      style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final date = item.scheduleDate;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: AppTextStyles.titleLarge),
              const SizedBox(height: 6),
              if (item.schoolName.isNotEmpty)
                Text(item.schoolName, style: AppTextStyles.titleSmall),
              if (date != null)
                Text(
                  '${AppFormatters.formatDayName(date)}, ${AppFormatters.formatDate(date)}',
                  style: AppTextStyles.bodySmall,
                ),
              const SizedBox(height: 14),
              const Text('Menu yang akan diterima:',
                  style: AppTextStyles.titleSmall),
              const SizedBox(height: 6),
              ...item.items.map((e) {
                final g = e['portionGram'];
                final gram = g is num ? ' (${g.toStringAsFixed(0)} g)' : '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('•  ${e['name'] ?? ''}$gram'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuChip extends StatelessWidget {
  final String label;
  const _MenuChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
    );
  }
}