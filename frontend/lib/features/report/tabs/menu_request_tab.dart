import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/report_models.dart';
import '../../../data/services/report_service.dart';
import '../../../shared/widgets/custom_button.dart';

/// Tab A: Permintaan Menu Makanan
class MenuRequestTab extends StatefulWidget {
  const MenuRequestTab({super.key});

  @override
  State<MenuRequestTab> createState() => _MenuRequestTabState();
}

class _MenuRequestTabState extends State<MenuRequestTab> {
  final _service = ReportService();
  final _menuNameController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<MenuRequestModel> _myRequests = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMyRequests();
  }

  @override
  void dispose() {
    _menuNameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadMyRequests() async {
    setState(() => _isLoading = true);
    final result = await _service.getMyMenuRequests();
    if (mounted) {
      setState(() {
        _myRequests = result.data ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final String? reason = _reasonController.text.trim().isEmpty
        ? null
        : _reasonController.text.trim();
    final result = await _service.submitMenuRequest(
      menuName: _menuNameController.text.trim(),
      reason: reason,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      _menuNameController.clear();
      _reasonController.clear();
      _loadMyRequests();
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
          // Form usulan
          _buildForm(),
          const SizedBox(height: 24),

          // Riwayat usulan
          _buildHistorySection(),
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
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant_menu_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Text('Usulkan Menu Baru',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('menu_request_name_field'),
              controller: _menuNameController,
              decoration: InputDecoration(
                labelText: 'Nama Menu yang Diusulkan *',
                hintText: 'Contoh: Soto Ayam, Pecel Lele',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.fastfood_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nama menu wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('menu_request_reason_field'),
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Alasan atau Keterangan (opsional)',
                hintText: 'Mengapa kamu mengusulkan menu ini?',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.info_outline_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: _isSubmitting ? 'Mengirim...' : 'Kirim Usulan',
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
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Riwayat Usulan Saya',
                style: AppTextStyles.headlineSmall),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadMyRequests,
              tooltip: 'Perbarui',
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_myRequests.isEmpty)
          _buildEmptyState(
            icon: Icons.restaurant_menu_rounded,
            message: 'Belum ada usulan menu.\nKirim usulan pertamamu di atas!',
          )
        else
          ..._myRequests.map((req) => _buildRequestCard(req)),
      ],
    );
  }

  Widget _buildRequestCard(MenuRequestModel req) {
    final statusColor = _statusColor(req.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(req.menuName,
                    style: AppTextStyles.titleSmall),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(req.statusLabel,
                    style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (req.reason != null) ...[
            const SizedBox(height: 6),
            Text(req.reason!,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 8),
          Text(
            DateFormat('d MMM y, HH:mm', 'id_ID').format(req.submittedAt),
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
          if (req.adminNote != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(req.adminNote!,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'received':
        return AppColors.info;
      case 'reviewing':
        return AppColors.warning;
      case 'considered':
        return AppColors.primary;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
