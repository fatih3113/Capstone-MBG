import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _classController;
  late TextEditingController _ageController;
  String? _selectedGender;
  String? _selectedLevel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _classController = TextEditingController(text: user?.className);
    _ageController = TextEditingController(text: user?.age?.toString());
    _selectedGender = user?.gender;
    _selectedLevel = user?.schoolLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final updatedUser = auth.user!.copyWith(
      name: _nameController.text.trim(),
      className: _classController.text.trim(),
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
      schoolLevel: _selectedLevel,
    );
    auth.updateUser(updatedUser);

    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
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
              CustomTextField(
                label: 'Nama Lengkap',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline,
                  color: AppColors.textHint, size: 20),
                validator: Validators.name,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Kelas',
                hint: 'Contoh: 6A',
                controller: _classController,
                prefixIcon: const Icon(Icons.class_outlined,
                  color: AppColors.textHint, size: 20),
                validator: (v) => Validators.required(v, fieldName: 'Kelas'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Umur',
                controller: _ageController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.cake_outlined,
                  color: AppColors.textHint, size: 20),
                validator: Validators.age,
              ),
              const SizedBox(height: 16),
              const Text('Jenis Kelamin', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: ['L', 'P'].map((g) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedGender == g
                            ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedGender == g
                              ? AppColors.primary : AppColors.cardBorder),
                      ),
                      child: Text(
                        g == 'L' ? 'Laki-laki' : 'Perempuan',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: _selectedGender == g
                              ? Colors.white : AppColors.textSecondary),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Jenjang Sekolah', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['SD', 'SMP', 'SMA', 'SMK'].map((lvl) =>
                  GestureDetector(
                    onTap: () => setState(() => _selectedLevel = lvl),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedLevel == lvl
                            ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedLevel == lvl
                              ? AppColors.primary : AppColors.cardBorder),
                      ),
                      child: Text(lvl, style: AppTextStyles.labelMedium.copyWith(
                        color: _selectedLevel == lvl
                            ? Colors.white : AppColors.textSecondary)),
                    ),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Simpan Perubahan',
                onPressed: _handleSave,
                isLoading: _isLoading,
                icon: const Icon(Icons.save_rounded,
                  color: Colors.white, size: 18),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
