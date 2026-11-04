// Halaman Profil Pengguna: menampilkan ringkasan data akun (sekolah/posyandu, kelas, gender, umur), data alergi makanan, menu navigasi pengaturan, dan tombol logout.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../shared/helpers/profile_photo_helper.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/user_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploadingPhoto = false;

  @override
  Widget build(BuildContext context) {
    // context.watch: memantau objek pengguna yang login agar perubahan data profil langsung terbarui di UI.
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    // Akun posyandu/puskesmas: tidak punya Kelas & Jenjang sekolah
    final isHealth = const {'Posyandu', 'Puskesmas'}.contains(user?.schoolLevel);

    // Scaffold: fondasi visual halaman profil dengan warna latar serasi tema aplikasi.
    return Scaffold(
      backgroundColor: AppColors.background,
      // CustomScrollView: menyatukan header avatar melengkung dengan kartu informasi profil yang dapat digulir bersama.
      body: CustomScrollView(
        slivers: [
          // SliverAppBar: area header atas dengan efek gradasi hijau, inisial avatar pengguna, nama lengkap, dan email.
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            title: const Text('Profil Saya'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.heroGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // UserAvatar: menampilkan foto profil asli pengguna dari server atau inisial nama, lengkap dengan tombol ubah foto.
                      UserAvatar(
                        user: user,
                        size: 84,
                        showBorder: true,
                        showEditBadge: true,
                        isLoading: _isUploadingPhoto,
                        onTap: () => ProfilePhotoHelper.showPhotoPickerSheet(
                          context,
                          onLoadingChanged: (loading) {
                            if (mounted) {
                              setState(() => _isUploadingPhoto = loading);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? 'Pengguna',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white),
                      ),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SliverToBoxAdapter: memasukkan kartu rincian identitas, alergi makanan, menu setting, dan tombol keluar.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu informasi biodata sekolah/posyandu, kelas, jenis kelamin, dan usia
                  _buildInfoCard([
                    _InfoRow(icon: Icons.school_outlined,
                      label: isHealth ? 'Posyandu' : 'Sekolah',
                      value: user?.schoolName ?? '-'),
                    if (!isHealth)
                      _InfoRow(icon: Icons.class_outlined,
                        label: 'Kelas',
                        value: user?.className ?? '-'),
                    _InfoRow(icon: Icons.person_outline,
                      label: 'Jenis Kelamin',
                      value: user?.genderLabel ?? '-'),
                    _InfoRow(icon: Icons.cake_outlined,
                      label: 'Umur',
                      value: user?.age != null ? '${user!.age} tahun' : '-'),
                    _InfoRow(icon: Icons.account_balance_outlined,
                      label: isHealth ? 'Jenis' : 'Jenjang',
                      value: user?.schoolLevel ?? '-'),
                  ]),
                  const SizedBox(height: 16),

                  // Kartu penampil status alergi makanan (daftar alergi, tidak ada alergi, atau belum diisi)
                  _buildAllergyCard(context, user),
                  const SizedBox(height: 20),

                  // Kartu daftar menu navigasi akun
                  const Text('Menu', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profil',
                      color: AppColors.primary,
                      onTap: () => context.push('/profile/edit'),
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Pengaturan',
                      color: AppColors.textSecondary,
                      onTap: () => context.push('/settings'),
                    ),
                    _MenuItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Statistik Gizi',
                      color: AppColors.info,
                      onTap: () => context.push('/stats'),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang Aplikasi',
                      color: AppColors.secondary,
                      onTap: () => _showAbout(context),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // CustomButton: tombol keluar dari akun (logout) dengan garis tepi merah/hijau.
                  CustomButton(
                    label: 'Keluar',
                    isOutlined: true,
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout_rounded,
                      color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Wadah kartu putih untuk menyajikan deretan baris informasi profil pengguna.
  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: rows.map((row) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Icon(row.icon, color: AppColors.primary, size: 18),
                  const SizedBox(width: 12),
                  Text(row.label, style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary)),
                  const Spacer(),
                  Text(row.value, style: AppTextStyles.titleSmall),
                ],
              ),
            ),
            if (row != rows.last)
              const Divider(height: 1, indent: 46),
          ],
        )).toList(),
      ),
    );
  }

  // Menampilkan chip alergi makanan pengguna atau tombol ajakan mengisi jika belum diisi.
  Widget _buildAllergyCard(BuildContext context, UserModel? user) {
    final filled = user?.allergyFilled ?? false;
    final labels = user?.allergyLabels ?? const <String>[];

    Widget content;
    // Jika akun lama belum pernah mengisi data alergi, beri tombol langsung ke Edit Profil.
    if (!filled) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belum diisi',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Isi Alergi Makanan'),
            ),
          ),
        ],
      );
    } else if (labels.isEmpty) {
      content = Text(
        'Tidak ada alergi',
        style:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      );
    } else {
      // Wrap: menampilkan daftar chip alergi makanan yang dimiliki pengguna.
      content = Wrap(
        spacing: 8,
        runSpacing: 8,
        children: labels
            .map(
              (label) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
            )
            .toList(),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.no_food_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 12),
              const Text('Alergi Makanan', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  // Menyusun daftar tautan menu navigasi ke halaman lain (Edit Profil, Pengaturan, dsb).
  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: items.map((item) => Column(
          children: [
            // InkWell: memberikan efek riak sentuhan (ripple) saat baris menu diklik.
            InkWell(
              onTap: item.onTap,
              borderRadius: item == items.first
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : item == items.last
                      ? const BorderRadius.vertical(
                          bottom: Radius.circular(16))
                      : BorderRadius.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Text(item.label, style: AppTextStyles.titleSmall),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            if (item != items.last)
              const Divider(height: 1, indent: 54),
          ],
        )).toList(),
      ),
    );
  }

  // Menampilkan kotak dialog informasi versi dan deskripsi hak cipta aplikasi.
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
        title: const Text('MBG Nutrition'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versi 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Sistem Identifikasi dan Analisis Kandungan Gizi Menu Makan Bergizi Gratis (MBG) Berbasis Mobile.',
            ),
            SizedBox(height: 8),
            Text('© 2025 Capstone Project'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// Representasi satu baris data info profil (ikon, label nama kolom, nilai data).
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
}

// Model data konfigurasi item menu pengaturan.
class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label,
    required this.color, required this.onTap});
}
