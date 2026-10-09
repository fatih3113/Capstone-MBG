import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

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

    // FIX: FittedBox(scaleDown) membuat ikon + teks mengecil otomatis
    // kalau ruang tombol sempit, sehingga tidak overflow.
    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isOutlined ? AppColors.primary : AppColors.white,
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
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

    // FIX: padding horizontal dikecilkan supaya isi tombol punya ruang lebih
    const buttonPadding = EdgeInsets.symmetric(horizontal: 12);

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