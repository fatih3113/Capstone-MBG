import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 90,
      );
      if (pickedFile != null && mounted) {
        context.push('/scan/preview', extra: File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Menu MBG'),
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Scanner illustration
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryLighter,
                        AppColors.primaryLighter.withValues(alpha: 0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLighter,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text('🍽️', style: TextStyle(fontSize: 72)),
                        ),
                      ),
                      // Corner frame decorations
                      const Positioned(top: 30, left: 30,
                        child: const _CornerBracket(alignment: Alignment.topLeft)),
                      const Positioned(top: 30, right: 30,
                        child: const _CornerBracket(alignment: Alignment.topRight)),
                      const Positioned(bottom: 30, left: 30,
                        child: const _CornerBracket(alignment: Alignment.bottomLeft)),
                      const Positioned(bottom: 30, right: 30,
                        child: const _CornerBracket(alignment: Alignment.bottomRight)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text('Identifikasi Menu MBG',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Foto menu MBG Anda dan sistem akan\nmengidentifikasi kandungan gizinya secara otomatis',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // How it works
              _buildHowItWorks(),
              const SizedBox(height: 32),

              // Buttons
              CustomButton(
                label: 'Buka Kamera',
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Pilih dari Galeri',
                onPressed: () => _pickImage(ImageSource.gallery),
                isOutlined: true,
                icon: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      ('1', '📸', 'Foto Makanan', 'Foto atau unggah foto menu MBG Anda'),
      ('2', '🔍', 'Identifikasi Menu', 'AI mengklasifikasi jenis makanan dalam foto'),
      ('3', '📊', 'Data Kandungan Gizi', 'Sistem mengambil data kalori, protein, karbohidrat, lemak & serat'),
      ('4', '⭐', 'Data Sensorik', 'Isi penilaian rasa, asin, manis, tekstur & aroma'),
      ('5', '🥘', 'Data Konsumsi', 'Isi porsi, sisa makanan & apakah dihabiskan'),
      ('6', '✅', 'Analisis Gizi', 'Estimasi gizi lengkap + skor sensorik + skor konsumsi'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cara Kerja Analisis MBG', style: AppTextStyles.titleMedium),
          const SizedBox(height: 14),
          ...steps.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(s.$2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Step ${s.$1}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(s.$3,
                              style: AppTextStyles.titleSmall)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(s.$4, style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final Alignment alignment;
  const _CornerBracket({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _BracketPainter(alignment),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Alignment alignment;
  _BracketPainter(this.alignment);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;
    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;

    canvas.drawLine(
      Offset(x, y),
      Offset(isLeft ? size.width * 0.6 : size.width * 0.4, y),
      paint,
    );
    canvas.drawLine(
      Offset(x, y),
      Offset(x, isTop ? size.height * 0.6 : size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
