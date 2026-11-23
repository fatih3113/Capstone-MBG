// Halaman Registrasi Bertahap: 4 langkah (Akun → Data Diri → Alergi → SPPG & Lembaga).
// Setiap langkah divalidasi secara terpisah sebelum lanjut ke langkah berikutnya.
// Isian tidak hilang saat menekan tombol Kembali.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/allergy_selector.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

// ─── Konstanta level institusi kesehatan ─────────────────────────────────────
const _kHealthLevels = {'posyandu', 'puskesmas'};

// ─── Model SPPG sederhana ────────────────────────────────────────────────────
class _SppgInfo {
  final String id;
  final String kode;
  final String nama;
  final String provinsi;
  final String kabupatenKota;
  final String kecamatan;

  const _SppgInfo({
    required this.id,
    required this.kode,
    required this.nama,
    required this.provinsi,
    required this.kabupatenKota,
    required this.kecamatan,
  });

  factory _SppgInfo.fromJson(Map<String, dynamic> j) => _SppgInfo(
        id: j['id'] as String,
        kode: j['kode'] as String? ?? '',
        nama: j['nama'] as String? ?? '',
        provinsi: j['provinsi'] as String? ?? '',
        kabupatenKota:
            (j['kabupaten_kota'] ?? j['kabupatenKota']) as String? ?? '',
        kecamatan: j['kecamatan'] as String? ?? '',
      );
}

class _SchoolItem {
  final String id;
  final String name;
  final String level;

  const _SchoolItem(
      {required this.id, required this.name, required this.level});

  factory _SchoolItem.fromJson(Map<String, dynamic> j) => _SchoolItem(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        level: j['level'] as String? ?? '',
      );
}

// ─── Halaman utama ────────────────────────────────────────────────────────────
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // ── Langkah 1: Akun ──────────────────────────────────────────────
  final _step1Key = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  String? _step1ServerError;

  // ── Langkah 2: Data Diri ──────────────────────────────────────────
  final _step2Key = GlobalKey<FormState>();
  bool _isPosyandu = false;
  final _nameCtrl = TextEditingController();
  String? _selectedGender;
  final _ageCtrl = TextEditingController();
  final _classCtrl = TextEditingController();

  // ── Langkah 3: Alergi ─────────────────────────────────────────────
  final _step3Key = GlobalKey<FormState>();
  AllergySelection _allergy = const AllergySelection.empty();

  // ── Langkah 4: SPPG & Lembaga ────────────────────────────────────
  final _step4Key = GlobalKey<FormState>();
  final _sppgCodeCtrl = TextEditingController();
  _SppgInfo? _foundSppg;
  String? _sppgError;
  bool _checkingCode = false;
  List<_SchoolItem> _schools = [];
  bool _loadingSchools = false;
  _SchoolItem? _selectedSchool;
  bool _newInstitution = false;
  final _instNameCtrl = TextEditingController();
  String? _instLevel;
  final _instCityCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _classCtrl.dispose();
    _sppgCodeCtrl.dispose();
    _instNameCtrl.dispose();
    _instCityCtrl.dispose();
    super.dispose();
  }

  // ── Navigasi ──────────────────────────────────────────────────────
  void _nextStep() {
    final keys = [_step1Key, _step2Key, _step3Key, _step4Key];
    if (!keys[_currentStep].currentState!.validate()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  // ── Cek Kode SPPG ────────────────────────────────────────────────
  Future<void> _checkSppgCode() async {
    final code = _sppgCodeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _sppgError = 'Masukkan kode SPPG terlebih dahulu');
      return;
    }
    setState(() {
      _checkingCode = true;
      _sppgError = null;
      _foundSppg = null;
      _schools = [];
      _selectedSchool = null;
      _newInstitution = false;
    });
    try {
      final resp = await DioClient.instance.get(
        '${ApiConstants.sppg}/by-code/$code',
      );
      final data = resp.data['data'] as Map<String, dynamic>;
      final sppg = _SppgInfo.fromJson(data);
      setState(() => _foundSppg = sppg);
      await _loadSchools(sppg.id);
    } on DioException catch (e) {
      final respData = e.response?.data;
      String? msg;
      if (respData is Map) {
        final msgRaw = respData['message'];
        msg = msgRaw is String ? msgRaw : null;
      }
      setState(
          () => _sppgError = msg ?? 'Kode SPPG tidak ditemukan atau belum aktif');
    } catch (_) {
      setState(() => _sppgError = 'Gagal memverifikasi kode SPPG');
    } finally {
      setState(() => _checkingCode = false);
    }
  }

  Future<void> _loadSchools(String sppgId) async {
    setState(() => _loadingSchools = true);
    try {
      final resp = await DioClient.instance.get(
        ApiConstants.schools,
        queryParameters: {'sppg_id': sppgId},
      );
      final list = (resp.data['data'] as List<dynamic>)
          .map((e) => _SchoolItem.fromJson(e as Map<String, dynamic>))
          .where((s) {
            final lvl = s.level.toLowerCase();
            return _isPosyandu
                ? _kHealthLevels.contains(lvl)
                : !_kHealthLevels.contains(lvl);
          })
          .toList();
      setState(() => _schools = list);
    } catch (_) {
      setState(() => _schools = []);
    } finally {
      setState(() => _loadingSchools = false);
    }
  }

  // ── Daftar ───────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_step4Key.currentState!.validate()) return;

    if (_foundSppg == null) {
      setState(() => _sppgError = 'Verifikasi kode SPPG terlebih dahulu');
      return;
    }
    if (!_newInstitution && _selectedSchool == null) {
      _showError('Pilih lembaga atau tambahkan lembaga baru');
      return;
    }
    if (_newInstitution) {
      if (_instNameCtrl.text.trim().isEmpty) {
        _showError('Nama lembaga wajib diisi');
        return;
      }
      if (!_isPosyandu && _instLevel == null) {
        _showError('Pilih jenjang lembaga');
        return;
      }
    }

    final authProvider = context.read<AuthProvider>();

    Map<String, dynamic>? newInst;
    if (_newInstitution) {
      newInst = {
        'name': _instNameCtrl.text.trim(),
        'level': _isPosyandu ? 'Posyandu' : _instLevel!,
        if (_instCityCtrl.text.trim().isNotEmpty)
          'city': _instCityCtrl.text.trim(),
      };
    }

    final success = await authProvider.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      gender: _selectedGender,
      age: int.tryParse(_ageCtrl.text),
      sppgCode: _foundSppg!.kode,
      schoolId: _newInstitution ? null : _selectedSchool?.id,
      newInstitution: newInst,
      className: (_isPosyandu || _classCtrl.text.trim().isEmpty)
          ? null
          : _classCtrl.text.trim(),
      allergies: _allergy.allergyList,
      allergyOther: _allergy.otherOrNull,
      allergyFilled: true,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final err = authProvider.errorMessage ?? 'Registrasi gagal';
      // Jika email duplikat → kembali ke langkah 1
      if (err.toLowerCase().contains('email')) {
        setState(() {
          _step1ServerError = err;
          _currentStep = 0;
        });
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      _showError(err);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) _prevStep();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Langkah ${_currentStep + 1} dari $_totalSteps'),
          leading: IconButton(
            onPressed: _prevStep,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: Column(
          children: [
            _StepIndicator(current: _currentStep, total: _totalSteps),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Account(
                    formKey: _step1Key,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    confirmPasswordCtrl: _confirmPasswordCtrl,
                    serverError: _step1ServerError,
                  ),
                  _Step2Profile(
                    formKey: _step2Key,
                    isPosyandu: _isPosyandu,
                    onUserTypeChanged: (v) =>
                        setState(() {
                          _isPosyandu = v;
                          _classCtrl.clear();
                        }),
                    nameCtrl: _nameCtrl,
                    selectedGender: _selectedGender,
                    onGenderChanged: (v) =>
                        setState(() => _selectedGender = v),
                    ageCtrl: _ageCtrl,
                    classCtrl: _classCtrl,
                  ),
                  _Step3Allergy(
                    formKey: _step3Key,
                    allergy: _allergy,
                    onAllergyChanged: (v) => setState(() => _allergy = v),
                  ),
                  _Step4Sppg(
                    formKey: _step4Key,
                    sppgCodeCtrl: _sppgCodeCtrl,
                    foundSppg: _foundSppg,
                    sppgError: _sppgError,
                    checkingCode: _checkingCode,
                    onCheckCode: _checkSppgCode,
                    schools: _schools,
                    loadingSchools: _loadingSchools,
                    selectedSchool: _selectedSchool,
                    onSchoolSelected: (s) => setState(() {
                      _selectedSchool = s;
                      _newInstitution = false;
                    }),
                    newInstitution: _newInstitution,
                    onNewInstitutionToggled: (v) => setState(() {
                      _newInstitution = v;
                      if (v) _selectedSchool = null;
                    }),
                    instNameCtrl: _instNameCtrl,
                    instLevel: _instLevel,
                    onInstLevelChanged: (v) =>
                        setState(() => _instLevel = v),
                    instCityCtrl: _instCityCtrl,
                    isPosyandu: _isPosyandu,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _currentStep < _totalSteps - 1
                  ? CustomButton(label: 'Lanjut', onPressed: _nextStep)
                  : CustomButton(
                      label: 'Daftar',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleRegister,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Indikator Langkah ────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Langkah ${current + 1} dari $total',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (current + 1) / total,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Langkah 1: Akun ─────────────────────────────────────────────────────────
class _Step1Account extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPasswordCtrl;
  final String? serverError;

  const _Step1Account({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmPasswordCtrl,
    this.serverError,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerBanner(),
            const SizedBox(height: 24),
            if (serverError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  serverError!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Data Akun', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Email dan password untuk masuk ke aplikasi',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email',
              hint: 'email@contoh.com',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined,
                  color: AppColors.textHint, size: 20),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              hint: 'Minimal 8 karakter',
              controller: passwordCtrl,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textHint, size: 20),
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Konfirmasi Password',
              hint: 'Ulangi password',
              controller: confirmPasswordCtrl,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textHint, size: 20),
              validator: (v) =>
                  Validators.confirmPassword(v, passwordCtrl.text),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Langkah 2: Data Diri ─────────────────────────────────────────────────────
class _Step2Profile extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isPosyandu;
  final ValueChanged<bool> onUserTypeChanged;
  final TextEditingController nameCtrl;
  final String? selectedGender;
  final ValueChanged<String> onGenderChanged;
  final TextEditingController ageCtrl;
  final TextEditingController classCtrl;

  const _Step2Profile({
    required this.formKey,
    required this.isPosyandu,
    required this.onUserTypeChanged,
    required this.nameCtrl,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.ageCtrl,
    required this.classCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data Diri', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Informasi tentang Anda',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text('Daftar sebagai', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _UserTypeCard(
                    emoji: '🏫',
                    title: 'Siswa Sekolah',
                    subtitle: 'Penerima MBG di sekolah',
                    selected: !isPosyandu,
                    onTap: () => onUserTypeChanged(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _UserTypeCard(
                    emoji: '👶',
                    title: 'Peserta Posyandu',
                    subtitle: 'Balita / ibu di posyandu',
                    selected: isPosyandu,
                    onTap: () => onUserTypeChanged(true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
              controller: nameCtrl,
              prefixIcon: const Icon(Icons.person_outline,
                  color: AppColors.textHint, size: 20),
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
            const Text('Jenis Kelamin', style: AppTextStyles.labelMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                _GenderChip(
                  label: 'Laki-laki',
                  value: 'L',
                  selected: selectedGender == 'L',
                  onTap: () => onGenderChanged('L'),
                ),
                const SizedBox(width: 12),
                _GenderChip(
                  label: 'Perempuan',
                  value: 'P',
                  selected: selectedGender == 'P',
                  onTap: () => onGenderChanged('P'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Umur',
              hint: isPosyandu ? 'Contoh: 3 (tahun)' : 'Contoh: 12',
              controller: ageCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.cake_outlined,
                  color: AppColors.textHint, size: 20),
              validator:
                  isPosyandu ? (v) => Validators.age(v, min: 0) : Validators.age,
            ),
            if (!isPosyandu) ...[
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Kelas',
                hint: 'Contoh: 7A atau VII',
                controller: classCtrl,
                prefixIcon: const Icon(Icons.class_outlined,
                    color: AppColors.textHint, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Langkah 3: Alergi ───────────────────────────────────────────────────────
class _Step3Allergy extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AllergySelection allergy;
  final ValueChanged<AllergySelection> onAllergyChanged;

  const _Step3Allergy({
    required this.formKey,
    required this.allergy,
    required this.onAllergyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data Alergi', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Pilih alergi makanan yang Anda miliki',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            AllergySelector(
              initialValue: allergy,
              onChanged: onAllergyChanged,
              required: true,
            ),
            const SizedBox(height: 16),
            const AllergyConsentNote(),
          ],
        ),
      ),
    );
  }
}

// ─── Langkah 4: SPPG & Lembaga ───────────────────────────────────────────────
class _Step4Sppg extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController sppgCodeCtrl;
  final _SppgInfo? foundSppg;
  final String? sppgError;
  final bool checkingCode;
  final VoidCallback onCheckCode;
  final List<_SchoolItem> schools;
  final bool loadingSchools;
  final _SchoolItem? selectedSchool;
  final ValueChanged<_SchoolItem?> onSchoolSelected;
  final bool newInstitution;
  final ValueChanged<bool> onNewInstitutionToggled;
  final TextEditingController instNameCtrl;
  final String? instLevel;
  final ValueChanged<String?> onInstLevelChanged;
  final TextEditingController instCityCtrl;
  final bool isPosyandu;

  const _Step4Sppg({
    required this.formKey,
    required this.sppgCodeCtrl,
    this.foundSppg,
    this.sppgError,
    required this.checkingCode,
    required this.onCheckCode,
    required this.schools,
    required this.loadingSchools,
    this.selectedSchool,
    required this.onSchoolSelected,
    required this.newInstitution,
    required this.onNewInstitutionToggled,
    required this.instNameCtrl,
    this.instLevel,
    required this.onInstLevelChanged,
    required this.instCityCtrl,
    required this.isPosyandu,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SPPG & Lembaga', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Masukkan kode SPPG yang membina sekolah/posyandu Anda',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // ── Input Kode SPPG ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: sppgCodeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [_UpperCaseFormatter()],
                    decoration: InputDecoration(
                      labelText: 'Kode SPPG',
                      hintText: 'Contoh: SPPG-3374-001',
                      prefixIcon: const Icon(Icons.qr_code_outlined,
                          color: AppColors.textHint, size: 20),
                      errorText: sppgError,
                    ),
                    validator: (_) {
                      if (foundSppg == null) {
                        return 'Verifikasi kode SPPG terlebih dahulu';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ElevatedButton(
                    onPressed: checkingCode ? null : onCheckCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: checkingCode
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Cek',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),

            // ── Kartu Info SPPG ───────────────────────────────────
            if (foundSppg != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.verified_outlined,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foundSppg!.nama,
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${foundSppg!.kecamatan}, ${foundSppg!.kabupatenKota}',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary),
                          ),
                          Text(
                            foundSppg!.provinsi,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                isPosyandu ? 'Pilih Posyandu Anda' : 'Pilih Sekolah Anda',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: 8),

              if (loadingSchools)
                const Center(child: CircularProgressIndicator())
              else ...[
                ...schools.map(
                  (school) {
                    final isSelected = selectedSchool?.id == school.id;
                    return ListTile(
                      title: Text(school.name, style: AppTextStyles.bodyMedium),
                      subtitle: Text(
                        school.level,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                      onTap: () {
                        onSchoolSelected(school);
                        onNewInstitutionToggled(false);
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  },
                ),

                // ── Opsi tambah lembaga baru ───────────────────
                InkWell(
                  onTap: () => onNewInstitutionToggled(!newInstitution),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          newInstitution
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isPosyandu
                              ? 'Posyandu saya belum terdaftar'
                              : 'Sekolah saya belum terdaftar',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Form lembaga baru ──────────────────────────
                if (newInstitution) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Lembaga Baru',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: instNameCtrl,
                          decoration: InputDecoration(
                            labelText: isPosyandu
                                ? 'Nama Posyandu *'
                                : 'Nama Sekolah *',
                            hintText: isPosyandu
                                ? 'Contoh: Posyandu Melati'
                                : 'Contoh: SDN 01 Jakarta',
                          ),
                          validator: (v) {
                            if (newInstitution &&
                                (v == null || v.trim().isEmpty)) {
                              return 'Nama lembaga wajib diisi';
                            }
                            return null;
                          },
                        ),
                        if (!isPosyandu) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: instLevel,
                            decoration:
                                const InputDecoration(labelText: 'Jenjang *'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'SD', child: Text('SD')),
                              DropdownMenuItem(
                                  value: 'SMP', child: Text('SMP')),
                              DropdownMenuItem(
                                  value: 'SMA', child: Text('SMA')),
                              DropdownMenuItem(
                                  value: 'SMK', child: Text('SMK')),
                            ],
                            onChanged: onInstLevelChanged,
                            validator: (v) {
                              if (newInstitution && !isPosyandu && v == null) {
                                return 'Pilih jenjang';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: instCityCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Kota (opsional)',
                            hintText: 'Contoh: Jakarta Selatan',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Widget helper: Banner header ────────────────────────────────────────────
Widget _headerBanner() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const AppLogo(size: 56),
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
    );

// ─── _UserTypeCard ────────────────────────────────────────────────────────────
class _UserTypeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _GenderChip ──────────────────────────────────────────────────────────────
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
          color:
              selected ? AppColors.primary : AppColors.surfaceVariant,
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

// ─── Formatter huruf besar otomatis ──────────────────────────────────────────
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
