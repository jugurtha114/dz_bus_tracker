/// lib/presentation/widgets/common/image_picker_input.dart

import 'dart:io'; // For File type
import 'package:flutter/foundation.dart'; // For kIsWeb, Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For initial image URL

import '../../../config/themes/app_theme.dart';
import '../../../core/utils/logger.dart';
import 'loading_indicator.dart'; // Assuming a simple loading indicator widget exists

/// A widget for selecting a single image from gallery/camera,
/// optionally displaying an initial image from a URL and allowing replacement.
class ImagePickerInput extends StatefulWidget {
  /// Label displayed above the picker.
  final String label;
  /// Callback function when an image is picked or removed. Passes null when removed.
  final Function(File? imageFile) onImagePicked;
  /// An initial file (e.g., from previous selection in same session). Takes precedence over imageUrl.
  final File? initialImageFile;
  /// An initial image URL to display (e.g., current profile/document photo).
  final String? initialImageUrl;

  const ImagePickerInput({
    super.key,
    required this.label,
    required this.onImagePicked,
    this.initialImageFile,
    this.initialImageUrl,
  });

  @override
  State<ImagePickerInput> createState() => _ImagePickerInputState();
}

class _ImagePickerInputState extends State<ImagePickerInput> {
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _displayInitialUrl = false; // Flag to track if showing network image

  @override
  void initState() {
    super.initState();
    // Prioritize initialFile over initialImageUrl
    if (widget.initialImageFile != null) {
       _pickedImageFile = widget.initialImageFile;
       _displayInitialUrl = false;
    } else if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
        _pickedImageFile = null; // Ensure file is null if showing URL
       _displayInitialUrl = true;
    } else {
        _pickedImageFile = null;
        _displayInitialUrl = false;
    }
  }

   // Update state if initial props change (e.g., profile reloads)
  @override
  void didUpdateWidget(covariant ImagePickerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageFile != oldWidget.initialImageFile || widget.initialImageUrl != oldWidget.initialImageUrl) {
        if (widget.initialImageFile != null) {
           _pickedImageFile = widget.initialImageFile;
           _displayInitialUrl = false;
        } else if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
           _pickedImageFile = null;
           _displayInitialUrl = true;
        } else {
           _pickedImageFile = null;
           _displayInitialUrl = false;
        }
        // No need to call setState here usually, build method handles display logic
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // If currently showing initial URL, picking replaces it visually
    try {
      final pickedXFile = await _picker.pickImage(
        source: source, imageQuality: 70, maxWidth: 1024,
      );

      if (pickedXFile != null) {
        setState(() {
          _pickedImageFile = File(pickedXFile.path);
          _displayInitialUrl = false; // No longer showing initial URL
        });
        widget.onImagePicked(_pickedImageFile); // Pass the NEW file
        Log.d("Image picked: ${pickedXFile.path}");
      } else {
        Log.d("Image picking cancelled or failed.");
      }
    } catch (e, stackTrace) {
      Log.e("Error picking image", error: e, stackTrace: stackTrace);
      if(mounted) ScaffoldMessenger.maybeOf(context)?.showSnackBar( const SnackBar(content: Text('Failed to pick image.'), backgroundColor: Colors.red),); // TODO: Localize
    }
  }

  void _removePickedImage() {
    // This only removes the *newly picked* image, reverting to initial if available
    setState(() {
      _pickedImageFile = null;
       // Re-evaluate if we should show the initial URL now
       if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
          _displayInitialUrl = true;
       } else {
          _displayInitialUrl = false;
       }
    });
    widget.onImagePicked(null); // Notify parent that picked file is removed
    Log.d("Picked image selection removed.");
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface, // Themed background
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Gallery'), // TODO: Localize
                  onTap: () { _pickImage(ImageSource.gallery); Navigator.of(context).pop(); }),
              ListTile(
                leading: Icon(Icons.photo_camera, color: Theme.of(context).colorScheme.primary),
                title: const Text('Camera'), // TODO: Localize
                onTap: () { _pickImage(ImageSource.camera); Navigator.of(context).pop(); },
              ),
               // Option to remove the *newly picked* image
              if (_pickedImageFile != null)
                const Divider(height: 1),
              if (_pickedImageFile != null)
                 ListTile(
                   leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                   title: const Text('Remove Selection'), // TODO: Localize
                   onTap: () { _removePickedImage(); Navigator.of(context).pop(); },
                 ),
            ],
          ),
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color placeholderColor = isDark ? Colors.white.withOpacity(0.7) : AppTheme.neutralMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: placeholderColor,
            fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        // Stack allows overlaying edit/remove buttons on images
        Stack(
          alignment: Alignment.center,
          children: [
            // Base container for border and tap area
            InkWell(
              onTap: () => _showPickerOptions(context),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor ?? colorScheme.surface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  border: Border.all(
                    color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? AppTheme.neutralLight.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                // --- Display Logic ---
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium - 1),
                   child: _buildImageContent(context, placeholderColor),
                ),
              ),
            ),
            // --- Overlay Buttons ---
            // Show "Remove" only if a NEW file was picked
            if (_pickedImageFile != null)
              Positioned(
                top: 6, right: 6,
                child: _buildOverlayButton(
                   icon: Icons.close,
                   tooltip: 'Remove Selection', // TODO: Localize
                   onTap: _removePickedImage,
                ),
              ),
             // Show "Edit/Replace" if displaying initial URL OR if a file is picked
             // (allow replacing picked file too)
             if (_displayInitialUrl || _pickedImageFile != null)
                Positioned(
                   bottom: 6, right: 6,
                   child: _buildOverlayButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Change Image', // TODO: Localize
                      onTap: () => _showPickerOptions(context),
                    )
                 ),
          ],
        ),
      ],
    );
  }

  /// Builds the content inside the main container (placeholder, network image, or file image).
  Widget _buildImageContent(BuildContext context, Color placeholderColor) {
     if (_pickedImageFile != null) {
       // Display picked file
       return Image.file( _pickedImageFile!, width: double.infinity, height: double.infinity, fit: BoxFit.cover, );
     } else if (_displayInitialUrl && widget.initialImageUrl != null) {
       // Display network image
       return CachedNetworkImage(
          imageUrl: widget.initialImageUrl!,
          width: double.infinity, height: double.infinity, fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: LoadingIndicator(size: 20)),
          errorWidget: (context, url, error) => Icon(Icons.broken_image_outlined, size: 40, color: placeholderColor.withOpacity(0.7)),
        );
     } else {
       // Display placeholder "Tap to select"
       return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon( Icons.add_a_photo_outlined, size: 40, color: Theme.of(context).colorScheme.primary,),
            const SizedBox(height: AppTheme.spacingSmall),
            Text( 'Tap to select image', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: placeholderColor),), // TODO: Localize
          ],
       );
     }
  }

   /// Builds a small circular button with background, suitable for overlaying on images.
   Widget _buildOverlayButton({required IconData icon, required String tooltip, required VoidCallback onTap}) {
      return Material( // Provides InkWell splash effect
         color: Colors.black.withOpacity(0.5),
         shape: const CircleBorder(),
         child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
         ),
      );
   }
}
