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
      body: Column(
        children: [
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
          _buildBottomPanel(context),
        ],
      ),
    );
  }

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
          // Tips
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
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Ganti Foto',
                  isOutlined: true,
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: 12),
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
          // Status message
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
