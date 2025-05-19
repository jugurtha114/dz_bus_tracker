// lib/widgets/common/app_bar.dart

import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import 'glassy_container.dart';

class DzAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool isTransparent;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final bool useGlassEffect;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;

  const DzAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.isTransparent = false,
    this.height = kToolbarHeight,
    this.backgroundColor,
    this.textColor,
    this.useGlassEffect = true,
    this.onBackPressed,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ??
        (isTransparent ? Colors.transparent : AppColors.primary);

    final effectiveTextColor = textColor ??
        (isTransparent ? AppColors.primary : AppColors.white);

    if (useGlassEffect && !isTransparent) {
      return PreferredSize(
        preferredSize: preferredSize,
        child: ClipRRect(
          child: Stack(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: height,
                title: Text(
                  title,
                  style: AppTextStyles.h2.copyWith(color: effectiveTextColor),
                ),
                centerTitle: centerTitle,
                leading: leading ??
                    (Navigator.canPop(context)
                        ? IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: effectiveTextColor),
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                    )
                        : null),
                actions: actions,
                bottom: bottom,
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: effectiveBackgroundColor.withOpacity(0.7),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      elevation: isTransparent ? 0 : 4,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: AppTextStyles.h2.copyWith(color: effectiveTextColor),
      ),
      leading: leading ??
          (Navigator.canPop(context)
              ? IconButton(
            icon: Icon(Icons.arrow_back_ios, color: effectiveTextColor),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }
}