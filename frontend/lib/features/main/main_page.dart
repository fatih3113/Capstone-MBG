import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/notification_provider.dart';
import '../../shared/widgets/distribution_notification_watcher.dart';

class MainPage extends StatelessWidget {
  final Widget child;
  const MainPage({super.key, required this.child});

  static const List<_NavItem> _navItems = [
    _NavItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        path: '/home'),
    _NavItem(
        label: 'Scan',
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner_rounded,
        path: '/scan'),
    // Tab Menu diganti Notifikasi
    _NavItem(
        label: 'Notif',
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        path: '/notifications'),
    _NavItem(
        label: 'Report',
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        path: '/report'),
    _NavItem(
        label: 'Profil',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Tab aktif dihitung dari lokasi router, jadi selalu sinkron
    // (termasuk saat pindah halaman lewat context.go dari Home).
    final location = GoRouterState.of(context).uri.path;
    final currentIndex =
        _navItems.indexWhere((e) => location.startsWith(e.path));

    return DistributionNotificationWatcher(
      dio: DioClient.instance,
      onUnreadChanged: (n) =>
          context.read<NotificationProvider>().setUnread(n),
      child: Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final isActive = i == currentIndex;

                  void onTap() {
                    if (!location.startsWith(item.path)) context.go(item.path);
                  }

                  // Special style for Scan button
                  if (i == 1) {
                    return GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(item.activeIcon,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 6),
                            Text('Scan',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  }

                  final isNotifTab = item.path == '/notifications';

                  return GestureDetector(
                    onTap: onTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryLighter
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isActive ? item.activeIcon : item.icon,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textHint,
                                size: 22,
                              ),
                              // Badge jumlah notifikasi belum dibaca
                              if (isNotifTab)
                                Positioned(
                                  top: -4,
                                  right: -6,
                                  child: Consumer<NotificationProvider>(
                                    builder: (_, n, __) {
                                      if (n.unreadCount <= 0) {
                                        return const SizedBox.shrink();
                                      }
                                      return Container(
                                        padding: const EdgeInsets.all(3),
                                        constraints: const BoxConstraints(
                                            minWidth: 16, minHeight: 16),
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          n.unreadCount > 9
                                              ? '9+'
                                              : '${n.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            height: 1,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: AppTextStyles.caption.copyWith(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}