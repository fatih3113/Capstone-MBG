// Halaman evaluasi makanan: tempat siswa mengisi survei rasa, aroma, porsi yang dimakan, dan sisa makanan sebelum melihat laporan gizi akhir.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/evaluation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_provider.dart';
import '../../shared/widgets/custom_button.dart';

// StatefulWidget: dipakai karena halaman ini menyimpan nilai input formulir evaluasi (rasa, porsi, sisa makanan) dan animasi transisi.
class FoodEvaluationPage extends StatefulWidget {
  const FoodEvaluationPage({super.key});

  @override
  State<FoodEvaluationPage> createState() => _FoodEvaluationPageState();
}

class _FoodEvaluationPageState extends State<FoodEvaluationPage>
    with TickerProviderStateMixin {
  // ─── Sensorik State ────────────────────────────────────────────────────────
  String _taste = 'Enak';
  String _saltLevel = 'Pas';
  String _sweetLevel = 'Pas';
  String _texture = 'Pas';
  String _aroma = 'Sedap';

  // ─── Konsumsi State ────────────────────────────────────────────────────────
  String _portionSize = 'Penuh (100%)';
  String _leftoverAmount = 'Tidak ada';
  bool _isFinished = true;

  // AnimationController: mengatur jalannya animasi pergeseran form dari bawah ke atas saat halaman dibuka.
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
    // Tween: menentukan titik awal pergeseran sedikit ke bawah agar formulir muncul perlahan dan halus.
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  // ─── Pilihan Dropdown ──────────────────────────────────────────────────────
  static const _tasteOptions = ['Sangat Enak', 'Enak', 'Biasa', 'Kurang Enak', 'Tidak Enak'];
  static const _saltOptions = ['Terlalu Asin', 'Agak Asin', 'Pas', 'Kurang Asin', 'Tidak Asin'];
  static const _sweetOptions = ['Terlalu Manis', 'Agak Manis', 'Pas', 'Kurang Manis', 'Tidak Manis'];
  static const _textureOptions = ['Sangat Baik', 'Baik', 'Pas', 'Kurang Baik', 'Tidak Baik'];
  static const _aromaOptions = ['Sangat Sedap', 'Sedap', 'Biasa', 'Kurang Sedap', 'Tidak Sedap'];
  static const _portionOptions = [
    'Penuh (100%)',
    '3/4 Porsi (75%)',
    '1/2 Porsi (50%)',
    '1/4 Porsi (25%)',
    'Sedikit (<25%)',
  ];
  static const _leftoverOptions = ['Tidak ada', 'Sedikit', 'Setengah', 'Banyak', 'Semua'];

  // Fungsi pengiriman evaluasi dan pemicu kalkulasi nutrisi lengkap berdasarkan porsi yang dimakan.
  void _submit() async {
    final scan = context.read<ScanProvider>();
    final auth = context.read<AuthProvider>();

    // Simpan data sensorik
    scan.setSensoryData(SensoryData(
      taste: _taste,
      saltLevel: _saltLevel,
      sweetLevel: _sweetLevel,
      texture: _texture,
      aroma: _aroma,
    ));

    // Simpan data konsumsi
    scan.setConsumptionData(ConsumptionData(
      portionSize: _portionSize,
      leftoverAmount: _leftoverAmount,
      isFinished: _isFinished,
    ));

    // Jalankan analisis lengkap
    final userId = auth.user?.id ?? 'user1';
    await scan.runFullAnalysis(userId);

    if (mounted && scan.isDone) {
      context.pushReplacement('/scan/analysis-result');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: kerangka halaman standar dengan AppBar judul dan tombol kembali ke hasil prediksi.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Evaluasi Makanan'),
        leading: IconButton(
          onPressed: () => context.go('/scan/result'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      // Consumer<ScanProvider>: memantau status pemrosesan analisis gizi agar tombol submit bisa menampilkan loading indicator.
      body: Consumer<ScanProvider>(
        builder: (context, scan, _) {
          // Stack: menumpuk isi formulir yang bisa digulir dengan tombol aksi yang menempel di bagian bawah layar.
          return Stack(
            children: [
              // SlideTransition: menggerakkan tampilan form ke atas secara mulus saat halaman pertama kali dirender.
              SlideTransition(
                position: _slideAnim,
                // SingleChildScrollView: memungkinkan seluruh form di-scroll agar tidak terpotong pada layar berukuran kecil.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  // Column: menyusun komponen evaluasi dari atas ke bawah secara vertikal dan teratur.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator tahapan alur scan makanan
                      _buildProgressIndicator(),
                      const SizedBox(height: 20),

                      // Makanan yang teridentifikasi (ringkasan)
                      _buildFoodSummary(scan),
                      const SizedBox(height: 24),

                      // Section DATA SENSORIK
                      _buildSectionHeader(
                        icon: Icons.star_rate_rounded,
                        iconColor: AppColors.warning,
                        title: 'Data Sensorik',
                        subtitle: 'Penilaian kualitas makanan berdasarkan indera',
                      ),
                      const SizedBox(height: 14),
                      _buildDropdown(
                        icon: '😋',
                        label: 'Rasa',
                        value: _taste,
                        options: _tasteOptions,
                        onChanged: (v) => setState(() => _taste = v!),
                      ),
                      _buildDropdown(
                        icon: '🧂',
                        label: 'Tingkat Asin',
                        value: _saltLevel,
                        options: _saltOptions,
                        onChanged: (v) => setState(() => _saltLevel = v!),
                      ),
                      _buildDropdown(
                        icon: '🍬',
                        label: 'Tingkat Manis',
                        value: _sweetLevel,
                        options: _sweetOptions,
                        onChanged: (v) => setState(() => _sweetLevel = v!),
                      ),
                      _buildDropdown(
                        icon: '🍽️',
                        label: 'Tekstur',
                        value: _texture,
                        options: _textureOptions,
                        onChanged: (v) => setState(() => _texture = v!),
                      ),
                      _buildDropdown(
                        icon: '👃',
                        label: 'Aroma',
                        value: _aroma,
                        options: _aromaOptions,
                        onChanged: (v) => setState(() => _aroma = v!),
                      ),
                      const SizedBox(height: 24),

                      // Section DATA KONSUMSI
                      _buildSectionHeader(
                        icon: Icons.restaurant_rounded,
                        iconColor: AppColors.primary,
                        title: 'Data Konsumsi',
                        subtitle: 'Seberapa banyak makanan yang dikonsumsi',
                      ),
                      const SizedBox(height: 14),
                      _buildDropdown(
                        icon: '🥘',
                        label: 'Porsi yang Dimakan',
                        value: _portionSize,
                        options: _portionOptions,
                        onChanged: (v) {
                          setState(() {
                            _portionSize = v!;
                            _isFinished = _portionSize == 'Penuh (100%)';
                            if (_isFinished) {
                              _leftoverAmount = 'Tidak ada';
                            }
                          });
                        },
                      ),
                      _buildDropdown(
                        icon: '🍱',
                        label: 'Sisa Makanan',
                        value: _leftoverAmount,
                        options: _leftoverOptions,
                        onChanged: (v) => setState(() {
                          _leftoverAmount = v!;
                          _isFinished = _leftoverAmount == 'Tidak ada';
                        }),
                      ),
                      const SizedBox(height: 12),
                      _buildFinishedToggle(),
                      const SizedBox(height: 12),

                      // Container info note: kotak pesan edukasi kecil tentang kegunaan data sensorik dan cara perhitungan gizi.
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.2)),
                        ),
                        // Row: meletakkan ikon info di samping paragraf penjelasan secara horizontal.
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                              color: AppColors.info, size: 16),
                            const SizedBox(width: 8),
                            // Expanded: membuat teks info fleksibel mengisi sisa lebar kontainer tanpa membuat layout overflow.
                            Expanded(
                              child: Text(
                                'Data sensorik digunakan sebagai indikator penerimaan makanan, '
                                'bukan kandungan gizi. Kandungan gizi dihitung berdasarkan '
                                'jenis makanan dan porsi konsumsi.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.info, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Align: menempatkan tombol kirim di sisi paling bawah layar agar posisinya permanen dan mudah dijangkau jari.
              Align(
                alignment: Alignment.bottomCenter,
                // Container dekorasi tombol bawah dengan shadow agar tampak mengambang di atas konten yang di-scroll.
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16, offset: const Offset(0, -4)),
                    ],
                  ),
                  // SafeArea: melindungi tombol dari potongan navigasi gestur bawaan sistem operasi.
                  child: SafeArea(
                    // CustomButton: tombol utama untuk mengirim form dan lanjut ke hasil analisis gizi.
                    child: CustomButton(
                      label: 'Lihat Analisis Gizi',
                      isLoading: scan.isProcessing,
                      onPressed: _submit,
                      icon: const Icon(Icons.analytics_rounded,
                        color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget bantuan untuk menampilkan diagram alur tahapan analisis makanan (Foto -> Identifikasi -> Gizi -> Evaluasi -> Analisis).
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alur Analisis', style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          // Row: menampilkan langkah-langkah dalam garis horizontal.
          Row(
            children: [
              _buildStep('📸', 'Foto', true),
              _buildStepConnector(true),
              _buildStep('🔍', 'Identifikasi', true),
              _buildStepConnector(true),
              _buildStep('📊', 'Gizi', true),
              _buildStepConnector(false),
              _buildStep('⭐', 'Evaluasi', false, isActive: true),
              _buildStepConnector(false),
              _buildStep('✅', 'Analisis', false),
            ],
          ),
        ],
      ),
    );
  }

  // Widget bantuan untuk menggambar lingkaran ikon dan nama tahapan scan.
  Widget _buildStep(String emoji, String label, bool isDone,
      {bool isActive = false}) {
    // Expanded: membagi ruang step secara merata di dalam baris progress.
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success
                  : isActive
                      ? AppColors.primary
                      : AppColors.cardBorder,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : Text(emoji, style: const TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
            style: AppTextStyles.caption.copyWith(
              color: isDone || isActive
                  ? AppColors.textPrimary
                  : AppColors.textHint,
              fontWeight: isActive
                  ? FontWeight.w700
                  : FontWeight.normal),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Widget garis penghubung antar bulatan tahapan pada indikator progress.
  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 16, height: 2,
      color: isActive ? AppColors.success : AppColors.cardBorder,
    );
  }

  // Widget kartu ringkasan makanan yang terdeteksi beserta estimasi kalori dan protein awalnya.
  Widget _buildFoodSummary(ScanProvider scan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      // Row: menyusun ikon makanan, nama makanan, dan info gizi secara sejajar mendatar.
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('🍽️',
              style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          // Expanded: memberikan area fleksibel bagi daftar nama makanan agar teks panjang tidak menabrak angka kalori.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Makanan Teridentifikasi',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  scan.predictions.isEmpty
                      ? '-'
                      : scan.predictions.map((p) => p.foodName).join(', '),
                  style: AppTextStyles.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${scan.totalNutrition.calories.toStringAsFixed(0)} kcal',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.calories),
              ),
              Text(
                '${scan.totalNutrition.protein.toStringAsFixed(1)}g protein',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Header judul bagian evaluasi (contoh: Sensorik atau Konsumsi) dengan ikon berwarna.
  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleMedium),
              Text(subtitle, style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  // Widget pemilih opsi dropdown khusus untuk setiap parameter sensorik dan konsumsi.
  Widget _buildDropdown({
    required String icon,
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          // Expanded: membentangkan DropdownButton agar mengisi seluruh sisa kolom input secara rapi.
          Expanded(
            // DropdownButtonHideUnderline: menghapus garis bawah default dropdown agar sesuai desain kartu kustom.
            child: DropdownButtonHideUnderline(
              // DropdownButton: daftar pilihan yang muncul saat pengguna mengetuk untuk memilih jawaban.
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary),
                hint: Text(label, style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary)),
                items: options.map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o),
                )).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          Text(label, style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // Widget tombol geser (Switch) untuk menyatakan apakah makanan dihabiskan sepenuhnya atau tidak.
  Widget _buildFinishedToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFinished
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Makanan Dihabiskan',
                  style: AppTextStyles.bodyMedium),
                Text('Apakah semua makanan dimakan?',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary)),
              ],
            ),
          ),
          // Switch: sakelar on/off cepat untuk mengubah status porsi makanan langsung menjadi 100% dan sisa 0%.
          Switch(
            value: _isFinished,
            activeThumbColor: AppColors.success,
            onChanged: (val) => setState(() {
              _isFinished = val;
              if (val) {
                _portionSize = 'Penuh (100%)';
                _leftoverAmount = 'Tidak ada';
              }
            }),
          ),
        ],
      ),
    );
  }
}
