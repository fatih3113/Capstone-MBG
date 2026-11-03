import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../data/models/school_model.dart';
import '../../data/models/sppg_model.dart';
import '../../data/services/sppg_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sppg_provider.dart';
import '../../shared/widgets/allergy_selector.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

/// Level institusi yang dianggap fasilitas kesehatan.
const _kHealthLevels = {'posyandu', 'puskesmas'};
bool _isHealthFacility(SchoolModel s) =>
    _kHealthLevels.contains(s.level.trim().toLowerCase());

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

  // Akun posyandu/puskesmas (ditentukan dari data awal, tidak berubah saat edit)
  late final bool _isHealth;

  // Sekolah & SPPG — provider lokal agar tidak bentrok dengan halaman Register
  final SppgProvider _sppg = SppgProvider(SppgService());
  String? _originalSppgId;
  String? _originalSchoolId;
  // false = pilih sekolah dari SPPG saat ini, true = pindah SPPG/wilayah lain
  bool _changeSppg = false;
  String? _schoolError;

  // Alergi makanan
  late AllergySelection _allergy;
  // Pengguna lama yang belum pernah mengisi tidak dipaksa mengisi saat edit profil
  late bool _allergyRequired;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _classController = TextEditingController(text: user?.className);
    _ageController = TextEditingController(text: user?.age?.toString());
    _selectedGender = user?.gender;
    _selectedLevel = user?.schoolLevel;
    _isHealth = _kHealthLevels.contains(user?.schoolLevel?.toLowerCase());
    _allergy = AllergySelection.fromUser(
      filled: user?.allergyFilled ?? false,
      allergies: user?.allergies ?? const [],
      other: user?.allergyOther,
    );
    _allergyRequired = user?.allergyFilled ?? false;

    _originalSppgId = user?.sppgId;
    _originalSchoolId = user?.schoolId;
    if (_originalSppgId != null && _originalSppgId!.isNotEmpty) {
      // Muat sekolah milik SPPG user saat ini
      _sppg.loadSchoolsBySppgId(
        _originalSppgId!,
        preselectSchoolId: _originalSchoolId,
      );
    } else {
      // Belum punya SPPG → langsung pilih wilayah dari awal
      _changeSppg = true;
      _sppg.loadProvinces();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _ageController.dispose();
    _sppg.dispose();
    super.dispose();
  }

  void _toggleChangeSppg() {
    setState(() {
      _changeSppg = !_changeSppg;
      _schoolError = null;
    });
    if (_changeSppg) {
      _sppg.resetAll();
      _sppg.loadProvinces();
    } else {
      // Kembali ke SPPG semula
      _sppg.resetAll();
      if (_originalSppgId != null) {
        _sppg.loadSchoolsBySppgId(
          _originalSppgId!,
          preselectSchoolId: _originalSchoolId,
        );
      }
    }
  }

  void _onSchoolChanged(SchoolModel? school) {
    _sppg.selectSchool(school);
    setState(() {
      _schoolError = null;
      // Jenjang mengikuti sekolah yang dipilih
      if (school != null && school.level.isNotEmpty) {
        _selectedLevel = school.level;
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final school = _sppg.selectedSchool;
    final sppg = _changeSppg ? _sppg.selectedSppg : null;

    // Validasi sekolah
    String? schoolError;
    if (_changeSppg && sppg == null) {
      schoolError = 'Harap pilih SPPG terlebih dahulu';
    } else if (school == null) {
      schoolError =
          _isHealth ? 'Harap pilih posyandu Anda' : 'Harap pilih sekolah Anda';
    }
    if (schoolError != null) {
      setState(() => _schoolError = schoolError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(schoolError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    final className = _classController.text.trim();
    final error = await auth.updateProfile(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      gender: _selectedGender,
      className: (_isHealth || className.isEmpty) ? null : className,
      school: school,
      sppg: sppg,
      sppgId: _originalSppgId,
      // Alergi hanya dikirim jika sudah dipilih
      allergies: _allergy.isEmpty ? null : _allergy.allergyList,
      allergyOther: _allergy.isEmpty ? null : _allergy.otherOrNull,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui!'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
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

              // ── Sekolah / Posyandu ───────────────────────────────
              ChangeNotifierProvider<SppgProvider>.value(
                value: _sppg,
                child: _SchoolSection(
                  isHealth: _isHealth,
                  currentSppgName:
                      context.read<AuthProvider>().user?.sppgName,
                  changeSppg: _changeSppg,
                  canGoBack:
                      _originalSppgId != null && _originalSppgId!.isNotEmpty,
                  errorText: _schoolError,
                  onToggleChange: _toggleChangeSppg,
                  onSchoolChanged: _onSchoolChanged,
                ),
              ),
              const SizedBox(height: 16),

              if (!_isHealth) ...[
                CustomTextField(
                  label: 'Kelas',
                  hint: 'Contoh: 6A',
                  controller: _classController,
                  prefixIcon: const Icon(Icons.class_outlined,
                      color: AppColors.textHint, size: 20),
                  validator: (v) => Validators.required(v, fieldName: 'Kelas'),
                ),
                const SizedBox(height: 16),
              ],
              CustomTextField(
                label: 'Umur',
                controller: _ageController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.cake_outlined,
                    color: AppColors.textHint, size: 20),
                validator: (v) => Validators.age(v, min: _isHealth ? 0 : 5),
              ),
              const SizedBox(height: 16),
              const Text('Jenis Kelamin', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: ['L', 'P']
                    .map((g) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedGender = g),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedGender == g
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _selectedGender == g
                                        ? AppColors.primary
                                        : AppColors.cardBorder),
                              ),
                              child: Text(
                                g == 'L' ? 'Laki-laki' : 'Perempuan',
                                style: AppTextStyles.labelMedium.copyWith(
                                    color: _selectedGender == g
                                        ? Colors.white
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Jenjang otomatis mengikuti sekolah yang dipilih
              if (!_isHealth) ...[
                const Text('Jenjang Sekolah',
                    style: AppTextStyles.labelMedium),
                const SizedBox(height: 4),
                Text(
                  'Otomatis mengikuti sekolah yang dipilih',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['SD', 'SMP', 'SMA', 'SMK']
                      .map(
                        (lvl) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedLevel == lvl
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _selectedLevel == lvl
                                    ? AppColors.primary
                                    : AppColors.cardBorder),
                          ),
                          child: Text(lvl,
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: _selectedLevel == lvl
                                      ? Colors.white
                                      : AppColors.textSecondary)),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              AllergySelector(
                initialValue: _allergy,
                required: _allergyRequired,
                onChanged: (value) => _allergy = value,
              ),
              const SizedBox(height: 16),
              const AllergyConsentNote(),
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

// ── Section pilih sekolah / posyandu ─────────────────────────────────────

class _SchoolSection extends StatelessWidget {
  final bool isHealth;
  final String? currentSppgName;
  final bool changeSppg;
  final bool canGoBack;
  final String? errorText;
  final VoidCallback onToggleChange;
  final ValueChanged<SchoolModel?> onSchoolChanged;

  const _SchoolSection({
    required this.isHealth,
    required this.currentSppgName,
    required this.changeSppg,
    required this.canGoBack,
    required this.errorText,
    required this.onToggleChange,
    required this.onSchoolChanged,
  });

  @override
  Widget build(BuildContext context) {
    final noun = isHealth ? 'Posyandu' : 'Sekolah';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorText != null ? AppColors.error : AppColors.cardBorder,
        ),
      ),
      child: Consumer<SppgProvider>(
        builder: (context, prov, _) {
          final institutions = prov.schoolList
              .where((s) => _isHealthFacility(s) == isHealth)
              .toList();
          final selected = institutions.contains(prov.selectedSchool)
              ? prov.selectedSchool
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(noun,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Text('*',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.error)),
                ],
              ),
              const SizedBox(height: 4),
              if (!changeSppg && (currentSppgName ?? '').isNotEmpty)
                Text(
                  'SPPG: $currentSppgName',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 12),

              // Cascade wilayah (hanya jika ingin pindah SPPG)
              if (changeSppg) ...[
                _Dropdown<String>(
                  label: 'Provinsi',
                  hint: 'Pilih provinsi',
                  value: prov.selectedProvinsi,
                  items: prov.provinces,
                  isLoading: prov.provinsiState == SppgLoadState.loading,
                  isEnabled: true,
                  errorMessage: prov.provinsiState == SppgLoadState.error
                      ? prov.provinsiError
                      : null,
                  onRetry: prov.loadProvinces,
                  itemLabel: (p) => p,
                  onChanged: prov.selectProvinsi,
                ),
                const SizedBox(height: 12),
                _Dropdown<String>(
                  label: 'Kabupaten / Kota',
                  hint: prov.selectedProvinsi == null
                      ? 'Pilih provinsi terlebih dahulu'
                      : 'Pilih kabupaten/kota',
                  value: prov.selectedKabupaten,
                  items: prov.kabupatenList,
                  isLoading: prov.kabupatenState == SppgLoadState.loading,
                  isEnabled: prov.selectedProvinsi != null,
                  errorMessage: prov.kabupatenState == SppgLoadState.error
                      ? prov.kabupatenError
                      : null,
                  itemLabel: (k) => k,
                  onChanged: prov.selectKabupaten,
                ),
                const SizedBox(height: 12),
                _Dropdown<String>(
                  label: 'Kecamatan',
                  hint: prov.selectedKabupaten == null
                      ? 'Pilih kabupaten/kota terlebih dahulu'
                      : 'Pilih kecamatan',
                  value: prov.selectedKecamatan,
                  items: prov.kecamatanList,
                  isLoading: prov.kecamatanState == SppgLoadState.loading,
                  isEnabled: prov.selectedKabupaten != null,
                  errorMessage: prov.kecamatanState == SppgLoadState.error
                      ? prov.kecamatanError
                      : null,
                  itemLabel: (k) => k,
                  onChanged: prov.selectKecamatan,
                ),
                const SizedBox(height: 12),
                _Dropdown<SppgModel>(
                  label: 'SPPG',
                  hint: prov.selectedKecamatan == null
                      ? 'Pilih kecamatan terlebih dahulu'
                      : 'Pilih SPPG',
                  value: prov.sppgList.contains(prov.selectedSppg)
                      ? prov.selectedSppg
                      : null,
                  items: prov.sppgList,
                  isLoading: prov.sppgState == SppgLoadState.loading,
                  isEnabled: prov.selectedKecamatan != null,
                  emptyMessage: 'Belum ada SPPG di kecamatan ini',
                  isEmpty: prov.selectedKecamatan != null &&
                      prov.sppgState == SppgLoadState.loaded &&
                      prov.sppgList.isEmpty,
                  errorMessage: prov.sppgState == SppgLoadState.error
                      ? prov.sppgError
                      : null,
                  itemLabel: (s) => s.displayLabel,
                  onChanged: prov.selectSppg,
                ),
                const SizedBox(height: 12),
              ],

              // Dropdown sekolah / posyandu
              _Dropdown<SchoolModel>(
                label: noun,
                hint: (changeSppg && prov.selectedSppg == null)
                    ? 'Pilih SPPG terlebih dahulu'
                    : 'Pilih ${noun.toLowerCase()}',
                value: selected,
                items: institutions,
                isLoading: prov.schoolState == SppgLoadState.loading,
                isEnabled: !changeSppg || prov.selectedSppg != null,
                isEmpty: prov.schoolState == SppgLoadState.loaded &&
                    institutions.isEmpty &&
                    (!changeSppg || prov.selectedSppg != null),
                emptyMessage:
                    'Belum ada ${noun.toLowerCase()} untuk SPPG ini',
                errorMessage: prov.schoolState == SppgLoadState.error
                    ? prov.schoolError
                    : null,
                itemLabel: (s) => s.displayLabel,
                onChanged: onSchoolChanged,
              ),

              if (errorText != null) ...[
                const SizedBox(height: 8),
                Text(errorText!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error)),
              ],

              const SizedBox(height: 8),
              if (!changeSppg || canGoBack)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onToggleChange,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      changeSppg
                          ? Icons.undo_rounded
                          : Icons.swap_horiz_rounded,
                      size: 18,
                    ),
                    label: Text(changeSppg
                        ? 'Batal ganti SPPG'
                        : 'Pindah ke SPPG / wilayah lain'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Dropdown generik ─────────────────────────────────────────────────────

class _Dropdown<T> extends StatelessWidget {
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

  const _Dropdown({
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

  BoxDecoration _box({Color? color, Color? border}) => BoxDecoration(
        color: color ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border ?? AppColors.cardBorder),
      );

  @override
  Widget build(BuildContext context) {
    Widget field;
    if (isLoading) {
      field = Container(
        height: 48,
        decoration: _box(),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (errorMessage != null) {
      field = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: _box(
          color: AppColors.error.withValues(alpha: 0.05),
          border: AppColors.error.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
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
      );
    } else if (isEmpty) {
      field = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: _box(),
        child: Row(
          children: [
            const Icon(Icons.info_outline,
                color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(emptyMessage,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      );
    } else {
      field = IgnorePointer(
        ignoring: !isEnabled,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            decoration: _box(
                color: isEnabled ? Colors.white : AppColors.surfaceVariant),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(hint,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textHint)),
                ),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}