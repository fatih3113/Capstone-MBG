import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/report_service.dart';
import '../../../shared/widgets/custom_button.dart';

/// Tab C: Feedback Makanan & Status Konsumsi (bukan berat aktual)
class FoodFeedbackTab extends StatefulWidget {
  const FoodFeedbackTab({super.key});

  @override
  State<FoodFeedbackTab> createState() => _FoodFeedbackTabState();
}

class _FoodFeedbackTabState extends State<FoodFeedbackTab> {
  final _service = ReportService();
  final _foodNameController = TextEditingController();
  final _suggestionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _tasteRating;
  int? _textureRating;
  int? _aromaRating;
  int? _portionRating;
  int? _satisfactionRating;
  String? _consumptionStatus;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _foodNameController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final String? suggestion = _suggestionController.text.trim().isEmpty
        ? null
        : _suggestionController.text.trim();
    final result = await _service.submitFoodFeedback(
      foodName: _foodNameController.text.trim(),
      tasteRating: _tasteRating,
      textureRating: _textureRating,
      aromaRating: _aromaRating,
      portionRating: _portionRating,
      satisfactionRating: _satisfactionRating,
      consumptionStatus: _consumptionStatus,
      suggestion: suggestion,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      _resetForm();
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

  void _resetForm() {
    _foodNameController.clear();
    _suggestionController.clear();
    setState(() {
      _tasteRating = null;
      _textureRating = null;
      _aromaRating = null;
      _portionRating = null;
      _satisfactionRating = null;
      _consumptionStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catatan penting
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, color: AppColors.info, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status konsumsi di bawah adalah pilihan Anda, '
                      'bukan pengukuran berat sisa makanan yang sebenarnya.',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.fiber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.feedback_rounded,
                            color: AppColors.fiber, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('Feedback Makanan',
                          style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nama makanan
                  TextFormField(
                    key: const Key('feedback_food_name_field'),
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Makanan *',
                      hintText: 'Contoh: Ayam Goreng MBG',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.fastfood_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama makanan wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Penilaian sensorik
                  Text('Penilaian Sensorik',
                      style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _buildRatingRow(
                    emoji: '😋',
                    label: 'Rasa',
                    value: _tasteRating,
                    onChanged: (v) => setState(() => _tasteRating = v),
                    color: AppColors.warning,
                  ),
                  _buildRatingRow(
                    emoji: '🍽️',
                    label: 'Tekstur',
                    value: _textureRating,
                    onChanged: (v) => setState(() => _textureRating = v),
                    color: AppColors.protein,
                  ),
                  _buildRatingRow(
                    emoji: '👃',
                    label: 'Aroma',
                    value: _aromaRating,
                    onChanged: (v) => setState(() => _aromaRating = v),
                    color: AppColors.fiber,
                  ),
                  _buildRatingRow(
                    emoji: '🥘',
                    label: 'Porsi',
                    value: _portionRating,
                    onChanged: (v) => setState(() => _portionRating = v),
                    color: AppColors.carbs,
                  ),
                  _buildRatingRow(
                    emoji: '😊',
                    label: 'Kepuasan',
                    value: _satisfactionRating,
                    onChanged: (v) => setState(() => _satisfactionRating = v),
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),

                  // Status konsumsi
                  Text('Status Konsumsi (pilihan Anda)',
                      style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(
                    'Bukan pengukuran berat sisa yang sebenarnya',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  _buildConsumptionSelector(),
                  const SizedBox(height: 20),

                  // Saran / keluhan
                  TextFormField(
                    key: const Key('feedback_suggestion_field'),
                    controller: _suggestionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Saran atau Keluhan (opsional)',
                      hintText: 'Sampaikan saran untuk pengelola MBG...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: _isSubmitting ? 'Mengirim...' : 'Kirim Feedback',
                      onPressed: _isSubmitting ? () {} : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow({
    required String emoji,
    required String label,
    required int? value,
    required ValueChanged<int> onChanged,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          ...List.generate(5, (i) {
            final star = i + 1;
            return GestureDetector(
              onTap: () => onChanged(star),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  (value != null && star <= value)
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: (value != null && star <= value)
                      ? color
                      : AppColors.cardBorder,
                  size: 26,
                ),
              ),
            );
          }),
          if (value != null)
            Text(
              ' $value/5',
              style: AppTextStyles.caption.copyWith(color: color),
            ),
        ],
      ),
    );
  }

  Widget _buildConsumptionSelector() {
    final options = [
      ('habis', '✅ Habis Dimakan'),
      ('sebagian', '🍱 Sebagian Tersisa'),
      ('hampir_tidak', '❌ Hampir Tidak Dimakan'),
    ];

    return Row(
      children: options.map((opt) {
        final isSelected = _consumptionStatus == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _consumptionStatus = opt.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                opt.$2,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
