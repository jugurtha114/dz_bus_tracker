// lib/widgets/common/enhanced_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced text field types
enum TextFieldType {
  normal,
  search,
  email,
  password,
  phone,
  number,
  multiline,
  url,
  currency
}

/// Enhanced custom text field with comprehensive functionality
class EnhancedTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final TextFieldType type;
  final bool required;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
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
  final String? initialValue;
  final Color? fillColor;
  final Color? borderColor;
  final String? errorText;
  final bool showBorder;
  final bool showCounter;
  final double borderRadius;
  final bool autoFocus;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool isDense;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool expands;
  final double? height;

  const EnhancedTextField({
    Key? key,
    this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.type = TextFieldType.normal,
    this.required = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.contentPadding,
    this.initialValue,
    this.fillColor,
    this.borderColor,
    this.errorText,
    this.showBorder = true,
    this.showCounter = false,
    this.borderRadius = 8.0,
    this.autoFocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.isDense = false,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.expands = false,
    this.height,
  }) : super(key: key);

  /// Named constructors for specific field types
  const EnhancedTextField.email({
    Key? key,
    String? label,
    String? hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool required = false,
    bool enabled = true,
  }) : this(
         key: key,
         label: label ?? 'Email',
         hintText: hintText ?? 'Enter your email address',
         controller: controller,
         type: TextFieldType.email,
         validator: validator,
         onChanged: onChanged,
         required: required,
         enabled: enabled,
         prefixIcon: const Icon(Icons.email_outlined),
         textInputAction: TextInputAction.next,
       );

  const EnhancedTextField.password({
    Key? key,
    String? label,
    String? hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool required = false,
    bool enabled = true,
  }) : this(
         key: key,
         label: label ?? 'Password',
         hintText: hintText ?? 'Enter your password',
         controller: controller,
         type: TextFieldType.password,
         validator: validator,
         onChanged: onChanged,
         required: required,
         enabled: enabled,
         prefixIcon: const Icon(Icons.lock_outline),
         textInputAction: TextInputAction.done,
       );

  const EnhancedTextField.phone({
    Key? key,
    String? label,
    String? hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool required = false,
    bool enabled = true,
  }) : this(
         key: key,
         label: label ?? 'Phone Number',
         hintText: hintText ?? 'Enter your phone number',
         controller: controller,
         type: TextFieldType.phone,
         validator: validator,
         onChanged: onChanged,
         required: required,
         enabled: enabled,
         prefixIcon: const Icon(Icons.phone_outlined),
         textInputAction: TextInputAction.next,
       );

  const EnhancedTextField.search({
    Key? key,
    String? hintText,
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool enabled = true,
  }) : this(
         key: key,
         hintText: hintText ?? 'Search...',
         controller: controller,
         type: TextFieldType.search,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         enabled: enabled,
         prefixIcon: const Icon(Icons.search),
         textInputAction: TextInputAction.search,
         showBorder: true,
       );

  const EnhancedTextField.multiline({
    Key? key,
    String? label,
    String? hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int? maxLines = 3,
    int? maxLength,
    bool required = false,
    bool enabled = true,
  }) : this(
         key: key,
         label: label,
         hintText: hintText,
         controller: controller,
         type: TextFieldType.multiline,
         validator: validator,
         onChanged: onChanged,
         maxLines: maxLines,
         maxLength: maxLength,
         required: required,
         enabled: enabled,
         textInputAction: TextInputAction.newline,
       );

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    // Set initial obscure text state for password fields
    _obscureText = widget.type == TextFieldType.password;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget? suffixIcon = widget.suffixIcon;
    
    // Add password visibility toggle for password fields
    if (widget.type == TextFieldType.password) {
      suffixIcon = IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }

    // Add clear button for search fields
    if (widget.type == TextFieldType.search && 
        widget.controller != null && 
        widget.controller!.text.isNotEmpty) {
      suffixIcon = IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          widget.controller!.clear();
          widget.onChanged?.call('');
        },
      );
    }

    Widget textField = Container(
      height: widget.height,
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        autofocus: widget.autoFocus,
        obscureText: _obscureText,
        keyboardType: _getKeyboardType(),
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        textAlign: widget.textAlign,
        maxLines: widget.type == TextFieldType.password ? 1 : widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters ?? _getDefaultInputFormatters(),
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        expands: widget.expands,
        validator: _buildValidator(),
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        decoration: _buildInputDecoration(theme, colorScheme, suffixIcon),
      ),
    );

    // Add label if provided
    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(theme),
          SizedBox(height: 8),
          textField,
          if (widget.helperText != null) ...[
            SizedBox(height: 4),
            _buildHelperText(theme),
          ],
        ],
      );
    }

    return textField;
  }

  Widget _buildLabel(ThemeData theme) {
    return RichText(
      text: TextSpan(
        text: widget.label!,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        children: widget.required ? [
          TextSpan(
            text: ' *',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ] : null,
      ),
    );
  }

  Widget _buildHelperText(ThemeData theme) {
    return Text(
      widget.helperText!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme, ColorScheme colorScheme, Widget? suffixIcon) {
    final borderColor = widget.borderColor ?? colorScheme.outline;
    final fillColor = widget.fillColor ?? colorScheme.surface;
    final focusedBorderColor = colorScheme.primary;
    final errorBorderColor = colorScheme.error;

    OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: widget.showBorder 
        ? BorderSide(color: borderColor.withOpacity(0.5))
        : BorderSide.none,
    );

    OutlineInputBorder focusedBorder = baseBorder.copyWith(
      borderSide: BorderSide(color: focusedBorderColor, width: 2),
    );

    OutlineInputBorder errorBorder = baseBorder.copyWith(
      borderSide: BorderSide(color: errorBorderColor, width: 1),
    );

    return InputDecoration(
      hintText: widget.hintText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: suffixIcon,
      prefix: widget.prefix,
      suffix: widget.suffix,
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      filled: true,
      fillColor: fillColor,
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: focusedBorder.copyWith(
        borderSide: BorderSide(color: errorBorderColor, width: 2),
      ),
      disabledBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: borderColor.withOpacity(0.3)),
      ),
      contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
        horizontal: 16,
        vertical: widget.isDense ? 8 : 12,
      ),
      isDense: widget.isDense,
      counterText: widget.showCounter ? null : '',
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.currency:
        return TextInputType.numberWithOptions(decimal: true);
      case TextFieldType.url:
        return TextInputType.url;
      case TextFieldType.multiline:
        return TextInputType.multiline;
      case TextFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getDefaultInputFormatters() {
    switch (widget.type) {
      case TextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case TextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case TextFieldType.currency:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
      default:
        return null;
    }
  }

  String? Function(String?)? _buildValidator() {
    if (widget.validator != null) {
      return widget.validator;
    }

    return (value) {
      // Required validation
      if (widget.required && (value == null || value.trim().isEmpty)) {
        return '${widget.label ?? 'This field'} is required';
      }

      // Type-specific validation
      if (value != null && value.isNotEmpty) {
        switch (widget.type) {
          case TextFieldType.email:
            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            break;
          case TextFieldType.phone:
            if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
              return 'Please enter a valid phone number';
            }
            break;
          case TextFieldType.url:
            if (!RegExp(r'^https?:\/\/').hasMatch(value)) {
              return 'Please enter a valid URL';
            }
            break;
          default:
            break;
        }
      }

      return null;
    };
  }
}