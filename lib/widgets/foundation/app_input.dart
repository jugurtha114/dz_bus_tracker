// lib/widgets/foundation/app_input.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system.dart';

/// Modern, optimized input component following Material You design
/// Replaces all legacy input components with a single, consistent implementation
class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,
    this.variant = AppInputVariant.outlined,
  });

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final AppInputVariant variant;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.textStyles.labelMedium?.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: DesignSystem.space8),
        ],
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          autofocus: widget.autofocus,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurface,
          ),
          decoration: _buildDecoration(context),
        ),
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: DesignSystem.space4),
          Text(
            widget.helperText!,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final suffixIcon = _buildSuffixIcon();
    
    switch (widget.variant) {
      case AppInputVariant.outlined:
        return InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space16,
            vertical: DesignSystem.space16,
          ),
        );
      
      case AppInputVariant.filled:
        return InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: context.colors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space16,
            vertical: DesignSystem.space16,
          ),
        );
    }
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: context.colors.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }
}

/// Search input with built-in search functionality
class AppSearchInput extends StatelessWidget {
  const AppSearchInput({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppInput(
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      variant: AppInputVariant.filled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(
        Icons.search,
        color: context.colors.onSurfaceVariant,
      ),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: context.colors.onSurfaceVariant,
              ),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
    );
  }
}

/// Dropdown input with Material You styling
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.variant = AppInputVariant.outlined,
  });

  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final AppInputVariant variant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: context.textStyles.labelMedium?.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: DesignSystem.space8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurface,
          ),
          decoration: _buildDecoration(context),
        ),
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: DesignSystem.space4),
          Text(
            helperText!,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    switch (variant) {
      case AppInputVariant.outlined:
        return InputDecoration(
          hintText: hint,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide(color: context.colors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space16,
            vertical: DesignSystem.space16,
          ),
        );
      
      case AppInputVariant.filled:
        return InputDecoration(
          hintText: hint,
          errorText: errorText,
          filled: true,
          fillColor: context.colors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space16,
            vertical: DesignSystem.space16,
          ),
        );
    }
  }
}

/// Input variants following Material You design
enum AppInputVariant {
  outlined,
  filled,
}