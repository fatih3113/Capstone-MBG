import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/report_models.dart';
import '../../../data/services/report_service.dart';
import '../../../shared/widgets/custom_button.dart';

/// Tab B: Rating Makanan Favorit (skala 1-5)
class FoodRatingTab extends StatefulWidget {
  const FoodRatingTab({super.key});

  @override
  State<FoodRatingTab> createState() => _FoodRatingTabState();
}

class _FoodRatingTabState extends State<FoodRatingTab> {
  final _service = ReportService();
  final _foodNameController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedRating = 5;
  List<FoodRankingModel> _ranking = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadRanking() async {
    setState(() => _isLoading = true);
    final result = await _service.getFoodRanking();
    if (mounted) {
      setState(() {
        _ranking = result.data ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final result = await _service.submitFoodRating(
      foodName: _foodNameController.text.trim(),
      rating: _selectedRating,
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      _foodNameController.clear();
      _reasonController.clear();
      setState(() => _selectedRating = 5);
      _loadRanking();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForm(),
          const SizedBox(height: 24),
          _buildRankingSection(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 10),
                Text('Beri Rating Makanan',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('food_rating_name_field'),
              controller: _foodNameController,
              decoration: InputDecoration(
                labelText: 'Nama Makanan *',
                hintText: 'Contoh: Ayam Goreng, Tempe Bacem',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.fastfood_rounded),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Nama makanan wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            Text('Rating', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _selectedRating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < _selectedRating
                          ? AppColors.warning
                          : AppColors.cardBorder,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                _ratingLabel(_selectedRating),
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('food_rating_reason_field'),
              controller: _reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Alasan menyukai makanan ini (opsional)',
                hintText: 'Kenapa kamu suka makanan ini?',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: _isSubmitting ? 'Menyimpan...' : 'Simpan Rating',
                onPressed: _isSubmitting ? () {} : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded,
                        color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🏆 Ranking Makanan Favorit',
                style: AppTextStyles.headlineSmall),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadRanking,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_ranking.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Center(
              child: Text('Belum ada data ranking',
                  style: AppTextStyles.bodySmall),
            ),
          )
        else
          ..._ranking.map((item) => _buildRankingCard(item)),
      ],
    );
  }

  Widget _buildRankingCard(FoodRankingModel item) {
    final rankColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
      AppColors.primary,
      AppColors.primary,
    ];
    final color =
        item.rank <= 5 ? rankColors[item.rank - 1] : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Center(
              child: Text(
                '#${item.rank}',
                style: AppTextStyles.labelSmall.copyWith(
                    color: color, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.foodName, style: AppTextStyles.titleSmall),
                Text('${item.voteCount} suara',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.warning, size: 16),
              const SizedBox(width: 4),
              Text(
                item.avgRating.toStringAsFixed(1),
                style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return '⭐ Sangat Tidak Enak';
      case 2:
        return '⭐⭐ Kurang Enak';
      case 3:
        return '⭐⭐⭐ Biasa Saja';
      case 4:
        return '⭐⭐⭐⭐ Enak';
      case 5:
        return '⭐⭐⭐⭐⭐ Sangat Enak!';
      default:
        return '';
    }
  }
}
