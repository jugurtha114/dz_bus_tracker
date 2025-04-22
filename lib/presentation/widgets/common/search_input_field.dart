/// lib/presentation/widgets/common/search_input_field.dart

import 'package:flutter/material.dart';
// CORRECTED: Import AppTheme for constants
import '../../../config/themes/app_theme.dart';

/// A styled input field specifically designed for search functionality.
class SearchInputField extends StatefulWidget {
  /// Optional controller to manage the text field's content externally.
  final TextEditingController? controller;
  /// Callback function when the text content changes. Provides the new text.
  final ValueChanged<String>? onChanged;
  /// Callback function when the user submits the search (e.g., presses Enter).
  final ValueChanged<String>? onSubmitted;
  /// Hint text displayed when the field is empty.
  final String hintText;
  /// Padding around the text field.
  final EdgeInsetsGeometry padding;

  const SearchInputField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search...', // TODO: Localize
    this.padding = const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall), // Use AppTheme
  });

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  // Use a local controller ONLY if one is not provided by the parent widget.
  late final TextEditingController _controller;
  bool _isLocalController = false;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isLocalController = true;
    } else {
      _controller = widget.controller!;
      _isLocalController = false;
    }
    _showClearButton = _controller.text.isNotEmpty;
    // Always add listener to manage the clear button visibility internally
    _controller.addListener(_updateClearButtonVisibility);
  }

  @override
  void didUpdateWidget(SearchInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent switches between providing/not providing a controller, handle it.
    if (widget.controller != oldWidget.controller) {
      // Remove listener from old controller only if it wasn't the local one OR if we now have an external one
      if (!_isLocalController || widget.controller != null) {
        oldWidget.controller?.removeListener(_updateClearButtonVisibility);
      }

      // If we were using a local controller but now have an external one, dispose local.
      if (_isLocalController && widget.controller != null) {
        // Important: Check if the local controller was actually created before disposing.
        // This check avoids disposing the controller if initState was never called or failed.
        // A simple check like `if (_controller != null)` might suffice if initialized non-nullably.
        // However, the logic here ensures we only dispose if we allocated it.
        _controller.dispose(); // Dispose the one we created
      }

      // Assign new controller (external or new local)
      if (widget.controller == null) {
        _controller = TextEditingController(text: oldWidget.controller?.text ?? ''); // Create new local, preserve text
        _isLocalController = true;
      } else {
        _controller = widget.controller!;
        _isLocalController = false;
      }
      _showClearButton = _controller.text.isNotEmpty;
      // Add listener to the new controller
      _controller.addListener(_updateClearButtonVisibility);
    }
  }


  @override
  void dispose() {
    // Remove listener from the current controller
    _controller.removeListener(_updateClearButtonVisibility);
    // Dispose the controller ONLY if we created it locally
    if (_isLocalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// Updates the visibility of the clear button based on text input.
  void _updateClearButtonVisibility() {
    if (mounted) {
      final shouldShowClear = _controller.text.isNotEmpty;
      if (_showClearButton != shouldShowClear) {
        setState(() {
          _showClearButton = shouldShowClear;
        });
      }
    }
  }

  /// Clears the text field's content and notifies parent if applicable.
  void _clearText() {
    _controller.clear();
    // If parent provided onChanged, trigger it as text is now empty
    widget.onChanged?.call('');
    // Visibility update handled by listener
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        // CORRECTED: Directly pass the parent's onChanged callback
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          filled: true,
          fillColor: isDark
              ? AppTheme.neutralDark.withOpacity(0.5) // Use AppTheme
              : AppTheme.neutralLight.withOpacity(0.5), // Use AppTheme
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          suffixIcon: _showClearButton
              ? IconButton(
            icon: Icon(
              Icons.clear_rounded,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            onPressed: _clearText,
            tooltip: 'Clear', // TODO: Localize
          )
              : null,
          border: OutlineInputBorder(
            // Use AppTheme
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge * 2),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            // Use AppTheme
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge * 2),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            // Use AppTheme
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge * 2),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }
}