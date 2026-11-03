// Halaman Menu MBG Mingguan: menampilkan jadwal hidangan makanan Makan Bergizi Gratis per hari (Senin s/d Sabtu) beserta gramatur porsinya.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../providers/menu_provider.dart';

import '../../shared/widgets/state_widgets.dart';

class MbgMenuPage extends StatefulWidget {
  const MbgMenuPage({super.key});

  @override
  State<MbgMenuPage> createState() => _MbgMenuPageState();
}

class _MbgMenuPageState extends State<MbgMenuPage> {
  @override
  void initState() {
    super.initState();
    // Memuat susunan menu MBG mingguan dari server begitu halaman pertama kali dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadWeeklyMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: fondasi halaman menu mingguan dengan AppBar dan latar belakang abu-abu muda.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menu MBG Mingguan'),
      ),
      // Consumer<MenuProvider>: merender status memuat, error, atau susunan menu berdasarkan data di provider.
      body: Consumer<MenuProvider>(
        builder: (context, menu, _) {
          // Menampilkan indikator loading berputar saat mengambil data menu.
          if (menu.isLoading) {
            return const AppLoadingWidget(message: 'Memuat menu MBG...');
          }
          // Menampilkan pesan error dan tombol coba lagi jika koneksi gagal.
          if (menu.error != null) {
            return AppErrorWidget(
              message: menu.error!,
              onRetry: () => menu.loadWeeklyMenu(),
            );
          }
          // Column: menata pemilih tab hari di bagian atas dan daftar hidangan di bawahnya.
          return Column(
            children: [
              // Bilah tab gulir horizontal untuk memilih hari (Senin - Sabtu).
              _buildDaySelector(menu),
              // Expanded: memberikan seluruh sisa ruang layar untuk menampilkan daftar hidangan menu hari terpilih.
              Expanded(child: _buildMenuContent(context, menu)),
            ],
          );
        },
      ),
    );
  }

  // Bilah tab hari horizontal: tombol berbentuk pil untuk beralih antara Senin hingga Sabtu.
  Widget _buildDaySelector(MenuProvider menu) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      // SingleChildScrollView horizontal: memungkinkan tab hari digeser ke samping dengan lancar.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: menu.weeklyMenus.asMap().entries.map((e) {
            final isSelected = e.key == menu.selectedDayIndex;
            final isToday = DateTime.now().weekday == e.key + 1;
            // GestureDetector: mendeteksi ketukan untuk memilih hari tertentu.
            return GestureDetector(
              onTap: () => menu.selectDay(e.key),
              // AnimatedContainer: animasi perubahan warna latar tombol saat hari dipilih.
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(color: AppColors.primary, width: 1.5)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      e.value.dayName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary),
                    ),
                    // Titik penanda kecil jika hari pada tab cocok dengan hari ini di dunia nyata
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 5, height: 5,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Konten rincian hidangan makanan pada hari yang sedang aktif dipilih.
  Widget _buildMenuContent(BuildContext context, MenuProvider menu) {
    final selectedMenu = menu.selectedMenu;
    // Menampilkan pesan kosong jika pada hari tersebut pihak SPPG belum menyusun menu.
    if (selectedMenu == null) {
      return const EmptyStateWidget(
        title: 'Menu tidak tersedia',
        subtitle: 'Menu untuk hari ini belum diatur',
        icon: Icons.restaurant_menu_outlined,
      );
    }

    // SingleChildScrollView: agar daftar makanan pada hari terpilih dapat digeser secara vertikal.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header kartu gradasi hijau: menampilkan nama hari, tanggal lengkap, dan nama sekolah penerima.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🗓️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedMenu.dayName,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white)),
                    Text(
                      AppFormatters.formatDate(selectedMenu.date),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70)),
                    Text(
                      selectedMenu.schoolName,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Menu Hari Ini', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),

          // Daftar kartu makanan per item hidangan (karbohidrat, lauk hewani, nabati, sayur, buah)
          ...selectedMenu.items.map((item) => GestureDetector(
            onTap: () => context.push('/menu/food/${item.food.id}',
              extra: item.food),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  // Kotak ikon emoji kategori makanan (nasi, ayam, sayur, dll)
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item.food.category)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(_getCategoryEmoji(item.food.category),
                        style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Informasi nama makanan, badge kategori, dan takaran porsi gramatur
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.food.name, style: AppTextStyles.titleSmall),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _CategoryBadge(
                              label: item.food.category,
                              color: _getCategoryColor(item.food.category),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.portionGram.toStringAsFixed(0)}g',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textHint),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  // Memilih kode warna khusus berdasarkan jenis kelompok makanan.
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Karbohidrat': return AppColors.carbs;
      case 'Protein Hewani': return AppColors.calories;
      case 'Protein Nabati': return AppColors.protein;
      case 'Sayuran': return AppColors.fiber;
      case 'Buah': return AppColors.secondary;
      case 'Minuman': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }

  // Memilih simbol emoji yang sesuai untuk tiap kelompok makanan.
  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Karbohidrat': return '🍚';
      case 'Protein Hewani': return '🍗';
      case 'Protein Nabati': return '🫘';
      case 'Sayuran': return '🥦';
      case 'Buah': return '🍎';
      case 'Minuman': return '🥛';
      default: return '🍽️';
    }
  }
}

// Badge kapsul warna-warni untuk menandai kategori kelompok makanan.
class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}
