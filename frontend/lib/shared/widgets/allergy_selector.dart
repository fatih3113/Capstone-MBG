import 'package:flutter/material.dart';
import '../../core/constants/allergy_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Hasil pilihan alergi pengguna pada form.
///
/// - [allergies]    : nilai alergi terpilih (lihat AllergyConstants.options)
/// - [noneSelected] : pengguna memilih "Tidak ada alergi"
/// - [other]        : teks untuk pilihan "Lainnya"
class AllergySelection {
  final Set<String> allergies;
  final bool noneSelected;
  final String other;

  const AllergySelection({
    this.allergies = const {},
    this.noneSelected = false,
    this.other = '',
  });

  const AllergySelection.empty() : this();

  /// Membuat pilihan awal dari data pengguna yang tersimpan.
  /// Jika belum pernah diisi ([filled] false) hasilnya kosong.
  factory AllergySelection.fromUser({
    required bool filled,
    required List<String> allergies,
    String? other,
  }) {
    if (!filled) return const AllergySelection.empty();
    return AllergySelection(
      allergies: allergies.toSet(),
      noneSelected: allergies.isEmpty,
      other: other ?? '',
    );
  }

  /// Belum memilih apa pun (bukan alergi, bukan "Tidak ada alergi").
  bool get isEmpty => allergies.isEmpty && !noneSelected;

  bool get hasOther => allergies.contains(AllergyConstants.otherValue);

  /// Daftar nilai untuk dikirim ke server, urut sesuai daftar pilihan.
  List<String> get allergyList => [
        for (final option in AllergyConstants.options)
          if (allergies.contains(option.value)) option.value,
      ];

  /// Teks "Lainnya" yang sudah di-trim; null jika "Lainnya" tidak dipilih.
  String? get otherOrNull => hasOther ? other.trim() : null;

  AllergySelection copyWith({
    Set<String>? allergies,
    bool? noneSelected,
    String? other,
  }) {
    return AllergySelection(
      allergies: allergies ?? this.allergies,
      noneSelected: noneSelected ?? this.noneSelected,
      other: other ?? this.other,
    );
  }
}

/// Bagian form "Alergi Makanan" (chip pilihan ganda).
/// Dipakai bersama oleh halaman Registrasi dan Edit Profil.
///
/// Terhubung dengan [Form] sehingga `formKey.currentState!.validate()`
/// ikut memeriksa: minimal satu pilihan (jika [required]) dan teks "Lainnya".
class AllergySelector extends StatefulWidget {
  final AllergySelection initialValue;
  final ValueChanged<AllergySelection> onChanged;

  /// Jika true, pengguna wajib memilih alergi atau "Tidak ada alergi".
  final bool required;

  const AllergySelector({
    super.key,
    required this.onChanged,
    this.initialValue = const AllergySelection.empty(),
    this.required = true,
  });

  @override
  State<AllergySelector> createState() => _AllergySelectorState();
}

class _AllergySelectorState extends State<AllergySelector> {
  late AllergySelection _value;
  late final TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _otherController = TextEditingController(text: _value.other);
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _commit(
    AllergySelection next,
    FormFieldState<AllergySelection> field,
  ) {
    setState(() => _value = next);
    field.didChange(next);
    widget.onChanged(next);
  }

  void _toggleNone(FormFieldState<AllergySelection> field) {
    if (_value.noneSelected) {
      _commit(const AllergySelection.empty(), field);
    } else {
      // Memilih "Tidak ada alergi" menghapus semua pilihan lain
      _otherController.clear();
      _commit(const AllergySelection(noneSelected: true), field);
    }
  }

  void _toggleAllergy(String value, FormFieldState<AllergySelection> field) {
    final next = {..._value.allergies};
    if (!next.remove(value)) next.add(value);

    final stillHasOther = next.contains(AllergyConstants.otherValue);
    if (!stillHasOther) _otherController.clear();

    _commit(
      AllergySelection(
        allergies: next,
        noneSelected: false, // memilih alergi melepas "Tidak ada alergi"
        other: stillHasOther ? _value.other : '',
      ),
      field,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<AllergySelection>(
      initialValue: _value,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) {
        if (widget.required && _value.isEmpty) {
          return 'Pilih alergi makanan atau Tidak ada alergi';
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alergi Makanan', style: AppTextStyles.labelMedium),
            const SizedBox(height: 4),
            Text(
              'Pilih semua yang sesuai',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in AllergyConstants.options)
                  _AllergyChip(
                    label: option.label,
                    selected: _value.allergies.contains(option.value),
                    onTap: () => _toggleAllergy(option.value, field),
                  ),
                _AllergyChip(
                  label: 'Tidak ada alergi',
                  selected: _value.noneSelected,
                  onTap: () => _toggleNone(field),
                ),
              ],
            ),
            if (_value.hasOther) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _otherController,
                maxLength: AllergyConstants.otherMaxLength,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Sebutkan alergi lainnya',
                ),
                onChanged: (text) {
                  _value = _value.copyWith(other: text);
                  widget.onChanged(_value);
                },
                validator: (text) {
                  if (_value.hasOther && (text ?? '').trim().isEmpty) {
                    return 'Sebutkan alergi lainnya';
                  }
                  return null;
                },
              ),
            ],
            if (field.hasError) ...[
              const SizedBox(height: 6),
              Text(
                field.errorText!,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _AllergyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AllergyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Teks persetujuan singkat di bawah form.
class AllergyConsentNote extends StatelessWidget {
  const AllergyConsentNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.lock_outline_rounded,
              size: 16, color: AppColors.textHint),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Data alergi hanya dipakai untuk keperluan program MBG '
            'dan hanya dapat dilihat admin.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}