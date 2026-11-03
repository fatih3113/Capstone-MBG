// Halaman Pratinjau Foto: menampilkan hasil jepretan kamera sebelum dianalisis, lengkap dengan fitur zoom (InteractiveViewer) dan tips pengambilan foto.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_provider.dart';
import '../../shared/widgets/custom_button.dart';

class ImagePreviewPage extends StatelessWidget {
  final File imageFile;
  const ImagePreviewPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    // Scaffold: berlatar belakang hitam gelap agar foto makanan terlihat kontras dan fokus.
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Preview Foto',
          style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
      ),
      // Column: membagi layar menjadi area gambar di atas dan panel tombol aksi di bawah.
      body: Column(
        children: [
          // Expanded + InteractiveViewer: area foto yang bisa dicubit untuk memperbesar (zoom in/out) atau digeser.
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          // Panel putih bawah berisi tips foto dan tombol konfirmasi identifikasi.
          _buildBottomPanel(context),
        ],
      ),
    );
  }

  // Panel melengkung bawah berisi teks konfirmasi, tips pencahayaan, dan tombol kirim ke model AI.
  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Foto siap dianalisis', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Pastikan foto menu MBG terlihat jelas dan tidak blur untuk hasil terbaik.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          // Kotak informasi tips posisi kamera (top-down view)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tips: Foto dari atas dengan pencahayaan yang baik menghasilkan identifikasi lebih akurat.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Dua tombol sejajar: 'Ganti Foto' dan 'Identifikasi Sekarang'
          Row(
            children: [
              // CustomButton: kembali ke pemilih kamera/galeri untuk mengambil ulang foto.
              Expanded(
                child: CustomButton(
                  label: 'Ganti Foto',
                  isOutlined: true,
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: 12),
              // Consumer<ScanProvider>: tombol proses yang menampilkan animasi memuat saat AI menganalisis foto.
              Expanded(
                child: Consumer<ScanProvider>(
                  builder: (context, scan, _) => CustomButton(
                    label: 'Identifikasi Sekarang',
                    isLoading: scan.isProcessing,
                    onPressed: () async {
                      scan.setImage(imageFile);
                      final userId = context.read<AuthProvider>().user?.id ?? 'user1';
                      await scan.analyzeImage(userId);
                      if (context.mounted && scan.isWaitingEvaluation) {
                        context.pushReplacement('/scan/result');
                      } else if (context.mounted && scan.isDone) {
                        context.pushReplacement('/scan/result');
                      }
                    },
                    icon: const Icon(Icons.search_rounded,
                      color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Teks pesan status progres inferensi AI (misal: "Mendeteksi objek makanan...")
          Consumer<ScanProvider>(
            builder: (_, scan, __) => scan.isProcessing
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(scan.statusMessage,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
