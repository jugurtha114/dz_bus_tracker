// lib/widgets/common/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme_config.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCounter;
  final String? initialValue;
  final Color? fillColor;
  final Color? borderColor;
  final String? errorText;
  final bool showBorder;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.contentPadding,
    this.showCounter = false,
    this.initialValue,
    this.fillColor,
    this.borderColor,
    this.errorText,
    this.showBorder = true,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: widget.enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: widget.enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : widget.suffixIcon,
            errorText: widget.errorText,
            errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary),
            border: widget.showBorder
                ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.borderColor ?? Theme.of(context).colorScheme.primary),
            )
                : InputBorder.none,
            enabledBorder: widget.showBorder
                ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.borderColor ?? Theme.of(context).colorScheme.primary),
            )
                : InputBorder.none,
            focusedBorder: widget.showBorder
                ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.borderColor ?? Theme.of(context).colorScheme.primary),
            )
                : InputBorder.none,
            errorBorder: widget.showBorder
                ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            )
                : InputBorder.none,
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: widget.fillColor ?? (widget.enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.1)),
            counterText: widget.showCounter ? null : '',
          ),
        ),
      ],
    );
  }
}