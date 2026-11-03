// Halaman Login: tempat pengguna memasukkan email dan password untuk masuk ke aplikasi.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/app_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// SingleTickerProviderStateMixin: diperlukan agar AnimationController bisa berjalan di widget ini.
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // GlobalKey<FormState>: kunci untuk mengakses dan memvalidasi semua field di dalam Form.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // FocusNode: untuk memindahkan fokus keyboard dari email ke password saat pengguna menekan "Next".
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // AnimationController + Animation: mengatur animasi fade dan slide saat halaman pertama kali dibuka.
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    // Animasi dijalankan sekali saat halaman terbuka supaya konten muncul dengan efek geser-naik.
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    // Semua controller dan node harus di-dispose agar tidak ada memory leak.
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // Notifikasi untuk login berhasil / gagal
  void _showNotif(String message, {required bool success}) {
    // ScaffoldMessenger: dipakai untuk menampilkan SnackBar (pesan sementara) di bagian bawah layar.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              // Icon berubah sesuai kondisi: centang hijau untuk berhasil, merah untuk gagal.
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // Dipanggil saat tombol "Masuk" ditekan: validasi form lalu kirim request login ke server.
  Future<void> _handleLogin() async {
    // Jika ada field yang tidak lolos validasi, proses dihentikan di sini.
    if (!_formKey.currentState!.validate()) return;

    // context.read: mengambil AuthProvider tanpa memicu rebuild, cukup untuk memanggil fungsi.
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _showNotif('Login berhasil! Selamat datang 👋', success: true);
      // Navigasi ke halaman Home dan menghapus semua riwayat navigasi sebelumnya.
      context.go('/home');
    } else {
      _showNotif(
        authProvider.errorMessage ?? 'Login gagal. Periksa email dan password.',
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: kerangka dasar halaman, menyediakan area body tanpa AppBar karena desain full-screen.
    return Scaffold(
      body: SafeArea(
        // FadeTransition + SlideTransition: menggabungkan animasi transparansi dan geser supaya halaman muncul dengan halus.
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            // SingleChildScrollView: agar konten bisa digulir saat keyboard muncul dan layar mengecil.
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              // Form: membungkus semua input field agar bisa divalidasi sekaligus lewat _formKey.
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Bagian header: logo aplikasi, judul, dan teks deskripsi singkat.
                    Center(
                      child: Column(
                        children: [
                          // AppLogo: widget kustom yang menampilkan logo MBG Nutrition.
                          const AppLogo(size: 104, withShadow: true),
                          const SizedBox(height: 20),
                          const Text('Selamat Datang!',
                            style: AppTextStyles.headlineLarge),
                          const SizedBox(height: 8),
                          Text(
                            'Masuk untuk memulai identifikasi\\ngizi menu MBG Anda',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // CustomTextField Email: input yang sudah dilengkapi validasi format email.
                    CustomTextField(
                      label: 'Email',
                      hint: 'email@contoh.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocus,
                      textInputAction: TextInputAction.next,
                      // Saat "Next" di keyboard ditekan, fokus otomatis pindah ke field password.
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.textHint, size: 20),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),

                    // CustomTextField Password: input dengan tombol show/hide password bawaan.
                    CustomTextField(
                      label: 'Password',
                      hint: 'Masukkan password',
                      controller: _passwordController,
                      isPassword: true,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      // Menekan "Done" di keyboard langsung memicu proses login.
                      onFieldSubmitted: (_) => _handleLogin(),
                      prefixIcon: const Icon(Icons.lock_outline,
                        color: AppColors.textHint, size: 20),
                      validator: (v) => Validators.required(v, fieldName: 'Password'),
                    ),
                    const SizedBox(height: 8),

                    // Tombol "Lupa Password?" diletakkan di kanan agar mudah dijangkau.
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('Lupa Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Consumer<AuthProvider>: tombol Masuk otomatis menampilkan loading spinner
                    // saat isLoading berubah, tanpa perlu rebuild seluruh halaman.
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => CustomButton(
                        label: 'Masuk',
                        onPressed: _handleLogin,
                        isLoading: auth.isLoading,
                        icon: const Icon(Icons.login_rounded,
                          color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tautan ke halaman Daftar bagi pengguna yang belum punya akun.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          )),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Daftar Sekarang',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
