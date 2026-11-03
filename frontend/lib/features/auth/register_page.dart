// Halaman Registrasi: formulir pembuatan akun baru bagi siswa sekolah atau peserta posyandu lengkap dengan wilayah SPPG dan data alergi.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sppg_provider.dart';
import '../../data/models/school_model.dart';
import '../../data/models/sppg_model.dart';
import '../../shared/widgets/allergy_selector.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

/// Level institusi yang dianggap fasilitas kesehatan (dikelompokkan ke "Posyandu").
const _kHealthLevels = {'posyandu', 'puskesmas'};
bool _isHealthFacility(SchoolModel s) =>
    _kHealthLevels.contains(s.level.trim().toLowerCase());

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // GlobalKey<FormState>: kunci untuk memvalidasi seluruh field formulir sekaligus sebelum dikirim.
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;
  final _ageController = TextEditingController();
  final _classController = TextEditingController();

  // Alergi makanan (dikelola oleh AllergySelector)
  AllergySelection _allergy = const AllergySelection.empty();

  // Jenis pengguna: false = siswa sekolah, true = peserta posyandu
  bool _isPosyandu = false;

  // Validasi SPPG
  bool _sppgTouched = false;
  String? _sppgValidationError;

  @override
  void initState() {
    super.initState();
    // Muat daftar provinsi saat halaman dibuka agar pilihan dropdown pertama langsung siap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SppgProvider>().loadProvinces();
    });
  }

  @override
  void dispose() {
    // Membebaskan seluruh controller agar tidak membebani memori saat pengguna keluar halaman.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _classController.dispose();
    super.dispose();
  }

  // Memastikan pengguna sudah memilih SPPG dan institusi sebelum form disubmit.
  String? _validateSppg() {
    final sppgProv = context.read<SppgProvider>();
    if (sppgProv.selectedSppg == null) {
      return 'Harap pilih SPPG tempat Anda terdaftar';
    }
    if (sppgProv.selectedSchool == null) {
      return _isPosyandu
          ? 'Harap pilih posyandu Anda'
          : 'Harap pilih sekolah Anda';
    }
    return null;
  }

  // Mengubah tipe pengguna antara Siswa Sekolah dan Peserta Posyandu serta mereset input sekolah/posyandu.
  void _onUserTypeChanged(bool posyandu) {
    if (posyandu == _isPosyandu) return;
    setState(() {
      _isPosyandu = posyandu;
      _classController.clear();
      _sppgValidationError = null;
    });
    // daftar institusi berbeda → pilihan lama harus direset
    context.read<SppgProvider>().selectSchool(null);
  }

  // Memvalidasi seluruh isian lalu memanggil API registrasi akun baru.
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
      schoolId: sppgProvider.selectedSchool?.id,
      className: (_isPosyandu || _classController.text.trim().isEmpty)
          ? null
          : _classController.text.trim(),
      allergies: _allergy.allergyList,
      allergyOther: _allergy.otherOrNull,
      allergyFilled: true, // sudah divalidasi: ada pilihan atau "Tidak ada alergi"
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
    // Scaffold: kerangka halaman standar dengan tombol panah kembali pada AppBar.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      // SingleChildScrollView: memungkinkan formulir yang panjang digeser ke atas terutama saat keyboard aktif.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        // Form: mengikat seluruh field teks agar validasi dapat dilakukan terpusat.
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header banner: kartu gradasi hijau sebagai identitas aplikasi MBG Nutrition.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: AppColors.primaryGradient),
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
              ),
              const SizedBox(height: 24),

              // Pilihan tipe akun: menentukan apakah pengguna adalah siswa sekolah atau peserta posyandu.
              const Text('Daftar sebagai', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _UserTypeCard(
                      emoji: '🏫',
                      title: 'Siswa Sekolah',
                      subtitle: 'Penerima MBG di sekolah',
                      selected: !_isPosyandu,
                      onTap: () => _onUserTypeChanged(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UserTypeCard(
                      emoji: '👶',
                      title: 'Peserta Posyandu',
                      subtitle: 'Balita / ibu di posyandu',
                      selected: _isPosyandu,
                      onTap: () => _onUserTypeChanged(true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // CustomTextField Nama: field input nama lengkap pengguna.
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline,
                    color: AppColors.textHint, size: 20),
                validator: Validators.name,
              ),
              const SizedBox(height: 16),

              // CustomTextField Email: field input alamat email dengan validasi email.
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

              // CustomTextField Password: field input kata sandi dengan proteksi sembunyi teks.
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

              // CustomTextField Konfirmasi Password: mencocokkan kembali password yang diinput.
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

              // Pilihan Jenis Kelamin: tombol chip untuk memilih Laki-laki atau Perempuan.
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

              // CustomTextField Umur: input angka usia pengguna.
              CustomTextField(
                label: 'Umur',
                hint: _isPosyandu ? 'Contoh: 3 (tahun)' : 'Contoh: 12',
                controller: _ageController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.cake_outlined,
                    color: AppColors.textHint, size: 20),
                validator: _isPosyandu
                    ? (v) => Validators.age(v, min: 0)
                    : Validators.age,
              ),
              const SizedBox(height: 16),

              // CustomTextField Kelas: opsional hanya untuk siswa sekolah penerima MBG.
              if (!_isPosyandu) ...[
                CustomTextField(
                  label: 'Kelas',
                  hint: 'Contoh: 7A (boleh dikosongkan)',
                  controller: _classController,
                  prefixIcon: const Icon(Icons.class_outlined,
                      color: AppColors.textHint, size: 20),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),

              // AllergySelector: komponen pilihan ganda alergi makanan yang terintegrasi form.
              AllergySelector(
                onChanged: (value) => _allergy = value,
              ),
              const SizedBox(height: 24),

              // _SppgSection: bagian pilihan bertingkat wilayah dan nama SPPG serta sekolah/posyandu.
              _SppgSection(
                isPosyandu: _isPosyandu,
                sppgValidationError:
                    _sppgTouched ? _sppgValidationError : null,
              ),
              const SizedBox(height: 20),
              // AllergyConsentNote: teks catatan persetujuan privasi data alergi pengguna.
              const AllergyConsentNote(),
              const SizedBox(height: 20),

              // Consumer<AuthProvider>: tombol kirim form yang otomatis menampilkan loading saat proses register.
              Consumer<AuthProvider>(
                builder: (_, auth, __) => CustomButton(
                  label: 'Buat Akun',
                  onPressed: _handleRegister,
                  isLoading: auth.isLoading,
                ),
              ),
              const SizedBox(height: 16),

              // TextButton masuk: pintasan kembali ke login bagi yang sudah punya akun.
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

// Bagian formulir pemilihan berjenjang: Provinsi -> Kab/Kota -> Kecamatan -> SPPG -> Sekolah/Posyandu.
class _SppgSection extends StatelessWidget {
  final bool isPosyandu;
  final String? sppgValidationError;

  const _SppgSection({required this.isPosyandu, this.sppgValidationError});

  @override
  Widget build(BuildContext context) {
    // Container: wadah kartu berbatas abu-abu/merah untuk membedakan bagian wilayah dari data diri.
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
          // Header bagian wilayah SPPG
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
            isPosyandu
                ? 'Pilih SPPG (Satuan Pelayanan Pemenuhan Gizi), lalu posyandu Anda'
                : 'Pilih SPPG (Satuan Pelayanan Pemenuhan Gizi), lalu sekolah Anda',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Consumer<SppgProvider>: dropdown provinsi yang merespons perubahan data provinsi di provider.
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

          // Consumer<SppgProvider>: dropdown kabupaten/kota yang aktif setelah provinsi terpilih.
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

          // Consumer<SppgProvider>: dropdown kecamatan yang aktif setelah kabupaten/kota terpilih.
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

          // Consumer<SppgProvider>: dropdown daftar unit SPPG pada kecamatan terpilih.
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
          const SizedBox(height: 12),

          // Consumer<SppgProvider>: dropdown memilih institusi sekolah atau posyandu di bawah naungan SPPG tersebut.
          Consumer<SppgProvider>(
            builder: (_, prov, __) {
              // hanya tampilkan institusi sesuai jenis pengguna
              final institutions = prov.schoolList
                  .where((s) => _isHealthFacility(s) == isPosyandu)
                  .toList();
              final noun = isPosyandu ? 'posyandu' : 'sekolah';
              return _WilayahDropdown<SchoolModel>(
                label: isPosyandu ? 'Posyandu' : 'Sekolah',
                hint: prov.selectedSppg == null
                    ? 'Pilih SPPG terlebih dahulu'
                    : 'Pilih $noun',
                value: prov.selectedSchool,
                items: institutions,
                isLoading: prov.schoolState == SppgLoadState.loading,
                isEnabled: prov.selectedSppg != null &&
                    prov.schoolState != SppgLoadState.loading,
                isEmpty: prov.selectedSppg != null &&
                    prov.schoolState == SppgLoadState.loaded &&
                    institutions.isEmpty,
                emptyMessage: 'Belum ada $noun untuk SPPG ini',
                errorMessage: prov.schoolState == SppgLoadState.error
                    ? prov.schoolError
                    : null,
                onRetry: prov.selectedSppg != null
                    ? () => prov.selectSppg(prov.selectedSppg)
                    : null,
                itemLabel: (s) => s.displayLabel,
                onChanged: (val) => prov.selectSchool(val),
              );
            },
          ),

          // Pesan error validasi jika bagian wilayah belum lengkap diisi
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

// Komponen generik untuk menampilkan dropdown pilihan berstatus loading, error, atau kosong.
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
    // Column: menata label dropdown dan kotak pilihan secara vertikal.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        // Menampilkan animasi loading putar saat data wilayah sedang diunduh dari API.
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
        // Menampilkan kotak error dan tombol coba lagi jika gagal mengambil data.
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
        // Menampilkan pesan jika tidak ada opsi pilihan yang tersedia.
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
        // DropdownButton: tombol dropdown pilihan item ketika data berhasil dimuat.
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

// ── Kartu pilihan jenis pengguna ───────────────────────────────────────────

// Kartu interaktif untuk memilih peran akun (Siswa atau Posyandu) dengan efek animasi border aktif.
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
    // GestureDetector: menangkap sentuhan pengguna saat mengetuk kartu tipe akun.
    return GestureDetector(
      onTap: onTap,
      // AnimatedContainer: memberikan transisi warna dan ketebalan garis tepi saat dipilih.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                if (selected)
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                style: AppTextStyles.labelMedium.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ── Gender Chip (tidak berubah) ──────────────────────────────────────────

// Tombol chip sederhana untuk memilih jenis kelamin Laki-laki / Perempuan.
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
    // GestureDetector: mendeteksi klik pada chip pilihan jenis kelamin.
    return GestureDetector(
      onTap: onTap,
      // AnimatedContainer: mengubah warna latar jadi hijau pekat saat opsi aktif dipilih.
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
