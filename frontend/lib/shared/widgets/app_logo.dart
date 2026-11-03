// Komponen logo aplikasi: menampilkan gambar logo resmi MBG Nutrition dari berkas aset lokal lengkap dengan fallback teks dan efek bayangan lembut.
import 'package:flutter/material.dart';

/// Logo aplikasi (assets/images/app_logo.png).
/// Dipakai di Splash, Login, dan Register. Jika aset gagal dimuat,
/// otomatis tampil ikon 🍱 sebagai cadangan.
// StatelessWidget: widget tampilan logo statis tanpa perubahan state internal.
class AppLogo extends StatelessWidget {
  final double size;

  /// Beri bayangan lembut di bawah logo (cocok untuk latar polos).
  final bool withShadow;

  const AppLogo({super.key, this.size = 80, this.withShadow = false});

  @override
  Widget build(BuildContext context) {
    // Image.asset: memuat gambar logo dari direktori assets/images/app_logo.png dengan fallback jika file belum tersedia.
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

    // Container: menambahkan efek bayangan (boxShadow) dan sudut melengkung jika opsi withShadow diaktifkan.
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
