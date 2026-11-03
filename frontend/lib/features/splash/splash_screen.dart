// Halaman Splash Screen: tampilan pembuka dengan animasi logo, nama aplikasi, dan progress bar sebelum masuk ke login.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// TickerProviderStateMixin: menyediakan ticker untuk beberapa AnimationController sekaligus (logo, teks, progress bar).
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    // Mengatur durasi dan kurva animasi untuk logo, teks nama aplikasi, serta loading bar.
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: AppConstants.splashDuration),
    );

    // Animasi logo membesar membal (elastic) dan muncul perlahan.
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5)),
    );
    // Animasi teks bergeser naik dan fade-in.
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    // Animasi bar pengisian progres dari 0% ke 100%.
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  // Menjalankan urutan animasi satu per satu, lalu berpindah ke halaman login.
  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    _progressController.forward();

    await Future.delayed(const Duration(seconds: AppConstants.splashDuration));
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    // Mematikan controller animasi agar tidak membebani memori setelah layar ditutup.
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: fondasi tampilan layar penuh tanpa app bar bawaan.
    return Scaffold(
      // Container: memberi latar belakang gradasi warna hijau khas MBG dari kiri atas ke kanan bawah.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.heroGradient,
          ),
        ),
        // SafeArea: menjaga konten tidak terpotong oleh notch kamera atau bilah status sistem.
        child: SafeArea(
          child: Column(
            children: [
              // Expanded: membuat bagian logo dan judul menempati sebagian besar ruang tengah layar.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AnimatedBuilder: merender ulang efek skala dan transparansi logo saat nilai animasi berubah.
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (_, child) => Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      ),
                      // AppLogo: komponen kustom yang menampilkan ikon/logo MBG.
                      child: const AppLogo(size: 150, withShadow: true),
                    ),
                    const SizedBox(height: 32),

                    // FadeTransition + SlideTransition: memunculkan teks judul dan slogan dengan gerakan lembut ke atas.
                    FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            Text(
                              AppConstants.appName,
                              style: AppTextStyles.displayMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants.appTagline,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bagian bawah: indikator progres garis putih untuk memberi tahu pengguna aplikasi sedang memuat.
              Padding(
                padding: const EdgeInsets.only(bottom: 48, left: 48, right: 48),
                child: Column(
                  children: [
                    // AnimatedBuilder: memperbarui panjang garis hijau/putih secara mulus seiring berjalannya timer.
                    AnimatedBuilder(
                      animation: _progressValue,
                      builder: (_, __) => ClipRRect(
                        // ClipRRect: membulatkan sudut bar progres agar terlihat rapi dan modern.
                        borderRadius: BorderRadius.circular(4),
                        // LinearProgressIndicator: bilah progres animasi dengan warna putih di atas latar transparan.
                        child: LinearProgressIndicator(
                          value: _progressValue.value,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Memuat aplikasi...',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
