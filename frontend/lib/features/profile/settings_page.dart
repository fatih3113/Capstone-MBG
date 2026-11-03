// Halaman Pengaturan (Settings): konfigurasi tema gelap/terang, preferensi notifikasi pengingat makan, hapus riwayat scan, dan informasi versi aplikasi.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch: memantau status tema aplikasi (gelap atau terang) dari ThemeProvider.
    final themeProvider = context.watch<ThemeProvider>();

    // Scaffold: kerangka halaman pengaturan dengan tombol kembali pada AppBar.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      // SingleChildScrollView: memastikan seluruh bagian menu pengaturan dapat digulir jika layar sempit.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Tampilan (Saklar mode gelap)
            Text('Tampilan', style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            _SettingsCard(children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                label: 'Mode Gelap',
                // Switch: saklar geser untuk mengaktifkan atau mematikan tema gelap aplikasi.
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Bagian Notifikasi (Pengingat waktu makan & menu baru)
            Text('Notifikasi', style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            _SettingsCard(children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Pengingat Makan',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _SettingsTile(
                icon: Icons.campaign_outlined,
                label: 'Info Menu Baru',
                trailing: Switch(
                  value: false,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Bagian Privasi & Data (Hapus riwayat pemindaian)
            Text('Privasi & Data', style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            _SettingsCard(children: [
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                label: 'Hapus Riwayat Scan',
                iconColor: AppColors.error,
                onTap: () => _showDeleteConfirm(context),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Kebijakan Privasi',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),

            // Bagian Informasi Aplikasi (Versi & Institusi Capstone)
            Text('Tentang', style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            const _SettingsCard(children: [
              const _SettingsTile(
                icon: Icons.info_outline,
                label: 'Versi Aplikasi',
                trailing: const Text('1.0.0',
                  style: AppTextStyles.bodySmall),
              ),
              _SettingsTile(
                icon: Icons.school_outlined,
                label: 'Capstone Project 2025',
                trailing: SizedBox.shrink(),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Dialog konfirmasi sebelum menghapus seluruh rekaman riwayat pemindaian makanan.
  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Riwayat?'),
        content: const Text(
          'Semua riwayat scan akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Kartu berlatar putih dengan garis pembatas (Divider) tipis antar-pengaturan.
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: children.asMap().entries.map((e) => Column(
          children: [
            e.value,
            if (e.key < children.length - 1)
              const Divider(height: 1, indent: 54),
          ],
        )).toList(),
      ),
    );
  }
}

// Komponen baris pengaturan ListTile dengan ikon berlatar warna dan tombol aksi di sisi kanan.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // ListTile: komponen standar untuk baris daftar interaktif lengkap dengan ikon awal, judul, dan widget trailing.
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 18),
      ),
      title: Text(label, style: AppTextStyles.titleSmall),
      trailing: trailing ?? (onTap != null
          ? const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textHint)
          : null),
    );
  }
}
