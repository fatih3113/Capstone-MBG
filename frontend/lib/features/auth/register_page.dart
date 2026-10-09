import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: _selectedGender,
      age: int.tryParse(_ageController.text),
    );
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🍱', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MBG Nutrition',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: Colors.white)),
                        Text('Daftarkan akun baru Anda',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Nama
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline,
                  color: AppColors.textHint, size: 20),
                validator: Validators.name,
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                label: 'Email',
                hint: 'email@contoh.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined,
                  color: AppColors.textHint, size: 20),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),

              // Password
              CustomTextField(
                label: 'Password',
                hint: 'Minimal 8 karakter',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textHint, size: 20),
                validator: Validators.password,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              CustomTextField(
                label: 'Konfirmasi Password',
                hint: 'Ulangi password',
                controller: _confirmPasswordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textHint, size: 20),
                validator: (v) => Validators.confirmPassword(
                  v, _passwordController.text),
              ),
              const SizedBox(height: 16),

              // Jenis Kelamin
              const Text('Jenis Kelamin', style: AppTextStyles.labelMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  _GenderChip(
                    label: 'Laki-laki',
                    value: 'L',
                    selected: _selectedGender == 'L',
                    onTap: () => setState(() => _selectedGender = 'L'),
                  ),
                  const SizedBox(width: 12),
                  _GenderChip(
                    label: 'Perempuan',
                    value: 'P',
                    selected: _selectedGender == 'P',
                    onTap: () => setState(() => _selectedGender = 'P'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Umur
              CustomTextField(
                label: 'Umur',
                hint: 'Contoh: 12',
                controller: _ageController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.cake_outlined,
                  color: AppColors.textHint, size: 20),
                validator: Validators.age,
              ),
              const SizedBox(height: 32),

              // Register button
              Consumer<AuthProvider>(
                builder: (_, auth, __) => CustomButton(
                  label: 'Buat Akun',
                  onPressed: _handleRegister,
                  isLoading: auth.isLoading,
                ),
              ),
              const SizedBox(height: 16),

              // Login link
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Sudah punya akun? Masuk',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }
}
