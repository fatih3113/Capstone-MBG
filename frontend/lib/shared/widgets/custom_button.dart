// Komponen tombol kustom serbaguna: mendukung gaya solid (ElevatedButton) maupun bergaris tepi (OutlinedButton), indikator loading, dan ikon opsional.
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

// StatelessWidget: tombol aksi yang merender tampilan sesuai parameter input (warna, teks, status loading, dan callback tap).
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    // FittedBox: mengecilkan teks dan ikon tombol secara proporsional jika ruang sempit agar tidak terjadi overflow.
    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            // CircularProgressIndicator: indikator putaran pemuatan ketika tombol sedang dalam kondisi memproses data.
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isOutlined ? AppColors.primary : AppColors.white,
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            // Row: meletakkan ikon opsional di samping label teks tombol secara horizontal.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isOutlined
                        ? (textColor ?? AppColors.primary)
                        : (textColor ?? AppColors.white),
                  ),
                ),
              ],
            ),
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    const buttonPadding = EdgeInsets.symmetric(horizontal: 12);

    // OutlinedButton: varian tombol sekunder dengan garis tepi tipis dan latar belakang transparan.
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: buttonPadding,
            side: BorderSide(
              color: isEnabled ? AppColors.primary : AppColors.textHint,
              width: 1.5,
            ),
            shape: shape,
          ),
          child: child,
        ),
      );
    }

    // ElevatedButton: varian tombol utama dengan warna latar belakang penuh (solid).
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: buttonPadding,
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.textHint.withValues(alpha: 0.3),
          shape: shape,
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
