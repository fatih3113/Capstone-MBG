import 'package:flutter/material.dart';

/// Logo aplikasi (assets/images/app_logo.png).
/// Dipakai di Splash, Login, dan Register. Jika aset gagal dimuat,
/// otomatis tampil ikon 🍱 sebagai cadangan.
class AppLogo extends StatelessWidget {
  final double size;

  /// Beri bayangan lembut di bawah logo (cocok untuk latar polos).
  final bool withShadow;

  const AppLogo({super.key, this.size = 80, this.withShadow = false});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text('🍱', style: TextStyle(fontSize: size * 0.5)),
        ),
      ),
    );

    if (!withShadow) return image;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: image,
    );
  }
}