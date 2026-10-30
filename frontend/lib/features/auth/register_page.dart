import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sppg_provider.dart';
import '../../data/models/sppg_model.dart';
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

  // Validasi SPPG
  bool _sppgTouched = false;
  String? _sppgValidationError;

  @override
  void initState() {
    super.initState();
    // Muat daftar provinsi saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SppgProvider>().loadProvinces();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String? _validateSppg() {
    final sppgProv = context.read<SppgProvider>();
    if (sppgProv.selectedSppg == null) {
      return 'Harap pilih SPPG tempat Anda terdaftar';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    setState(() => _sppgTouched = true);
    final sppgError = _validateSppg();
    setState(() => _sppgValidationError = sppgError);

    if (!_formKey.currentState!.validate()) return;
    if (sppgError != null) return;

    final authProvider = context.read<AuthProvider>();
    final sppgProvider = context.read<SppgProvider>();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: _selectedGender,
      age: int.tryParse(_ageController.text),
      sppgId: sppgProvider.selectedSppg?.id,
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
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
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
                            style: AppTextStyles.headlineSmall
                                .copyWith(color: Colors.white)),
                        Text('Daftarkan akun baru Anda',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70)),
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
                validator: (v) =>
                    Validators.confirmPassword(v, _passwordController.text),
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
              const SizedBox(height: 24),

              // ── SECTION WILAYAH SPPG ────────────────────────────────────
              _SppgSection(
                sppgValidationError:
                    _sppgTouched ? _sppgValidationError : null,
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
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.primary),
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

// ── SPPG Section Widget ────────────────────────────────────────────────────

class _SppgSection extends StatelessWidget {
  final String? sppgValidationError;

  const _SppgSection({this.sppgValidationError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sppgValidationError != null
              ? AppColors.error
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Wilayah SPPG',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary)),
              const SizedBox(width: 4),
              Text('*',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih SPPG (Satuan Pelayanan Pemenuhan Gizi) tempat Anda terdaftar',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Dropdown Provinsi
          Consumer<SppgProvider>(
            builder: (_, prov, __) => _WilayahDropdown<String>(
              label: 'Provinsi',
              hint: 'Pilih provinsi',
              value: prov.selectedProvinsi,
              items: prov.provinces,
              isLoading: prov.provinsiState == SppgLoadState.loading,
              isEnabled: true,
              errorMessage: prov.provinsiState == SppgLoadState.error
                  ? prov.provinsiError
                  : null,
              onRetry: () => prov.loadProvinces(),
              itemLabel: (p) => p,
              onChanged: (val) => prov.selectProvinsi(val),
            ),
          ),
          const SizedBox(height: 12),

          // Dropdown Kabupaten/Kota
          Consumer<SppgProvider>(
            builder: (_, prov, __) => _WilayahDropdown<String>(
              label: 'Kabupaten / Kota',
              hint: prov.selectedProvinsi == null
                  ? 'Pilih provinsi terlebih dahulu'
                  : 'Pilih kabupaten/kota',
              value: prov.selectedKabupaten,
              items: prov.kabupatenList,
              isLoading: prov.kabupatenState == SppgLoadState.loading,
              isEnabled: prov.selectedProvinsi != null &&
                  prov.kabupatenState != SppgLoadState.loading,
              isEmpty: prov.selectedProvinsi != null &&
                  prov.kabupatenState == SppgLoadState.loaded &&
                  prov.kabupatenList.isEmpty,
              errorMessage: prov.kabupatenState == SppgLoadState.error
                  ? prov.kabupatenError
                  : null,
              onRetry: prov.selectedProvinsi != null
                  ? () => prov.selectProvinsi(prov.selectedProvinsi)
                  : null,
              itemLabel: (k) => k,
              onChanged: (val) => prov.selectKabupaten(val),
            ),
          ),
          const SizedBox(height: 12),

          // Dropdown Kecamatan
          Consumer<SppgProvider>(
            builder: (_, prov, __) => _WilayahDropdown<String>(
              label: 'Kecamatan',
              hint: prov.selectedKabupaten == null
                  ? 'Pilih kabupaten/kota terlebih dahulu'
                  : 'Pilih kecamatan',
              value: prov.selectedKecamatan,
              items: prov.kecamatanList,
              isLoading: prov.kecamatanState == SppgLoadState.loading,
              isEnabled: prov.selectedKabupaten != null &&
                  prov.kecamatanState != SppgLoadState.loading,
              isEmpty: prov.selectedKabupaten != null &&
                  prov.kecamatanState == SppgLoadState.loaded &&
                  prov.kecamatanList.isEmpty,
              errorMessage: prov.kecamatanState == SppgLoadState.error
                  ? prov.kecamatanError
                  : null,
              onRetry: prov.selectedKabupaten != null
                  ? () => prov.selectKabupaten(prov.selectedKabupaten)
                  : null,
              itemLabel: (k) => k,
              onChanged: (val) => prov.selectKecamatan(val),
            ),
          ),
          const SizedBox(height: 12),

          // Dropdown SPPG
          Consumer<SppgProvider>(
            builder: (_, prov, __) => _WilayahDropdown<SppgModel>(
              label: 'SPPG',
              hint: prov.selectedKecamatan == null
                  ? 'Pilih kecamatan terlebih dahulu'
                  : 'Pilih SPPG',
              value: prov.selectedSppg,
              items: prov.sppgList,
              isLoading: prov.sppgState == SppgLoadState.loading,
              isEnabled: prov.selectedKecamatan != null &&
                  prov.sppgState != SppgLoadState.loading,
              isEmpty: prov.selectedKecamatan != null &&
                  prov.sppgState == SppgLoadState.loaded &&
                  prov.sppgList.isEmpty,
              emptyMessage: 'Belum ada SPPG di kecamatan ini',
              errorMessage: prov.sppgState == SppgLoadState.error
                  ? prov.sppgError
                  : null,
              onRetry: prov.selectedKecamatan != null
                  ? () => prov.selectKecamatan(prov.selectedKecamatan)
                  : null,
              itemLabel: (s) => s.displayLabel,
              onChanged: (val) => prov.selectSppg(val),
            ),
          ),

          // Error pesan validasi
          if (sppgValidationError != null) ...[
            const SizedBox(height: 8),
            Text(
              sppgValidationError!,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Generic Dropdown Wilayah ───────────────────────────────────────────────

class _WilayahDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final bool isLoading;
  final bool isEnabled;
  final bool isEmpty;
  final String emptyMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _WilayahDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.isLoading,
    required this.isEnabled,
    required this.itemLabel,
    required this.onChanged,
    this.isEmpty = false,
    this.emptyMessage = 'Tidak ada data',
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        if (isLoading)
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (errorMessage != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(errorMessage!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error)),
                ),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text('Coba lagi',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary)),
                  ),
              ],
            ),
          )
        else if (isEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text(emptyMessage,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          IgnorePointer(
            ignoring: !isEnabled,
            child: Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: isEnabled
                      ? Colors.white
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    hint: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(hint,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textHint)),
                    ),
                    isExpanded: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    borderRadius: BorderRadius.circular(10),
                    items: items
                        .map((item) => DropdownMenuItem<T>(
                              value: item,
                              child: Text(itemLabel(item),
                                  style: AppTextStyles.bodyMedium,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: isEnabled ? onChanged : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Gender Chip (tidak berubah) ──────────────────────────────────────────

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
              color:
                  selected ? AppColors.primary : AppColors.cardBorder),
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
