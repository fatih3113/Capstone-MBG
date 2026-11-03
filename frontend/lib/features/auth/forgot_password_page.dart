// Halaman Lupa Password: untuk meminta pengiriman tautan reset kata sandi ke email pengguna.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // GlobalKey<FormState>: kunci untuk memvalidasi isian email sebelum mengirim permohonan reset.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    // Membebaskan controller agar memori tidak bocor saat halaman ditutup.
    _emailController.dispose();
    super.dispose();
  }

  // Mengirim permintaan reset password dan menampilkan status berhasil setelah selesai.
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Call forgot password API
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() { _isLoading = false; _emailSent = true; });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: struktur dasar halaman yang menyediakan AppBar navigasi dan ruang isi konten.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Password'),
        // IconButton kembali: memudahkan pengguna kembali ke halaman login sebelumnya.
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      // Padding: memberi jarak tepi 24dp agar tampilan form atau status berhasil tidak menempel di sisi layar.
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _emailSent ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  // Widget tampilan form input email jika email belum terkirim.
  Widget _buildForm() {
    // Form: membungkus input agar validasi format email bisa dipicu bersamaan saat tombol ditekan.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Container informasi: kartu pengingat dengan warna latar lembut agar pengguna paham fungsi halaman ini.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icon gembok reset: visual pendukung supaya pesan instruksi lebih menarik dan jelas.
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_reset_rounded,
                    color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reset Password', style: AppTextStyles.titleMedium),
                      SizedBox(height: 4),
                      const Text(
                        'Masukkan email Anda dan kami akan mengirim link reset password.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // CustomTextField: field isian teks kustom yang sudah dipasangi ikon email dan validasi format email.
          CustomTextField(
            label: 'Email',
            hint: 'email@contoh.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined,
              color: AppColors.textHint, size: 20),
            validator: Validators.email,
          ),
          const SizedBox(height: 24),
          // CustomButton: tombol aksi kirim yang menampilkan animasi loading saat proses request berlangsung.
          CustomButton(
            label: 'Kirim Link Reset',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  // Widget tampilan sukses saat tautan reset berhasil dikirim ke alamat email.
  Widget _buildSuccess() {
    // Center: menempatkan kartu info sukses tepat di tengah layar agar langsung terlihat oleh pengguna.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container lingkaran: lingkaran latar untuk ikon email sukses agar terkesan ramah dan positif.
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primaryLighter,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
              color: AppColors.primary, size: 64),
          ),
          const SizedBox(height: 24),
          const Text('Email Terkirim!', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Link reset password telah dikirim ke\n${_emailController.text}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // CustomButton: tombol kembali ke halaman login setelah pengguna membaca pesan sukses.
          CustomButton(
            label: 'Kembali ke Login',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
