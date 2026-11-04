// Widget avatar pengguna: menampilkan foto profil asli pengguna (dari URL server) dengan cache, atau inisial nama jika belum ada foto profil.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final String? imageUrl;
  final String? initials;
  final double size;
  final double? borderRadius;
  final bool isCircle;
  final bool showBorder;
  final Border? customBorder;
  final bool showEditBadge;
  final bool isLoading;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.user,
    this.imageUrl,
    this.initials,
    this.size = 44,
    this.borderRadius,
    this.isCircle = true,
    this.showBorder = false,
    this.customBorder,
    this.showEditBadge = false,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = imageUrl ?? user?.fullProfileImageUrl;
    final effectiveInitials = initials ?? user?.initials ?? '?';
    final radius = borderRadius ?? (isCircle ? size / 2 : 12.0);

    Widget avatarContent;

    if (effectiveUrl != null && effectiveUrl.isNotEmpty) {
      avatarContent = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: effectiveUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: size,
            height: size,
            color: AppColors.primaryLighter,
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildInitialsFallback(effectiveInitials),
        ),
      );
    } else {
      avatarContent = _buildInitialsFallback(effectiveInitials);
    }

    Widget mainAvatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        border: customBorder ?? (showBorder ? Border.all(color: Colors.white, width: 2) : null),
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          avatarContent,
          if (isLoading)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircle ? null : BorderRadius.circular(radius),
              ),
              child: Center(
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (showEditBadge) {
      final badgeSize = (size * 0.32).clamp(24.0, 36.0);
      mainAvatar = Stack(
        clipBehavior: Clip.none,
        children: [
          mainAvatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: badgeSize * 0.55,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: isLoading ? null : onTap,
        child: mainAvatar,
      );
    }

    return mainAvatar;
  }

  Widget _buildInitialsFallback(String text) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius ?? 12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

