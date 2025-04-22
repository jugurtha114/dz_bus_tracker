/// lib/presentation/widgets/common/profile_picture_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../config/themes/app_theme.dart';
import '../../../core/utils/logger.dart'; // For logging image errors

/// A widget to display a user's profile picture in a CircleAvatar.
/// Falls back to displaying initials or a default icon if no image URL is provided.
class ProfilePictureWidget extends StatelessWidget {
  /// Optional URL of the user's profile picture.
  final String? imageUrl;

  /// The user's full name, used to generate initials if [imageUrl] is null or invalid.
  final String? fullName;

  /// The radius of the circular avatar. Defaults to 24.0.
  final double radius;

  /// Optional callback when the avatar is tapped.
  final VoidCallback? onTap;

  /// Optional border color for the avatar.
  final Color? borderColor;

  /// Optional border width for the avatar. Defaults to 1.0 if borderColor is set.
  final double borderWidth;

   /// Optional background color, primarily used for the initials/icon fallback.
   /// Defaults to theme's primary container color.
  final Color? backgroundColor;

   /// Optional text color for the initials. Defaults to theme's onPrimaryContainer.
  final Color? foregroundColor;


  const ProfilePictureWidget({
    super.key,
    this.imageUrl,
    this.fullName,
    this.radius = 24.0, // Default size
    this.onTap,
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Generates initials from a full name (e.g., "John Doe" -> "JD").
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '';
    }
    final nameParts = name.trim().split(' ').where((part) => part.isNotEmpty);
    if (nameParts.isEmpty) {
      return '';
    }
    if (nameParts.length == 1) {
      return nameParts.first[0].toUpperCase();
    }
    return (nameParts.first[0] + nameParts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final effectiveForegroundColor = foregroundColor ?? theme.colorScheme.onPrimaryContainer;
    final initials = _getInitials(fullName);
    // Calculate a reasonable font size based on radius
    final fontSize = radius * 0.8;

    Widget avatarContent;

    // Determine content: Image > Initials > Icon
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackgroundColor, // Show background during image load
        foregroundColor: effectiveForegroundColor, // For potential error icon color
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          Log.w("Failed to load profile image: $imageUrl", error: exception, stackTrace: stackTrace);
          // Error is handled by CircleAvatar showing fallback (child or background)
          // No need to setState here as CachedNetworkImageProvider handles errors internally.
        },
         // Child shown if image fails AND backgroundImage is specified
         // Since initials are the next fallback, don't set a child here initially.
        // child: Icon(Icons.person, size: fontSize), // Fallback icon if needed AND initials unavailable
      );
    } else if (initials.isNotEmpty) {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackgroundColor,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize.clamp(10.0, 40.0), // Clamp font size
            fontWeight: FontWeight.w500,
            color: effectiveForegroundColor,
          ),
        ),
      );
    } else {
      // Fallback default icon
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackgroundColor,
        child: Icon(
          Icons.person_outline,
          size: fontSize * 1.2, // Make icon slightly larger than text
          color: effectiveForegroundColor,
        ),
      );
    }

    // Apply border if specified
    Widget potentiallyBorderedAvatar = avatarContent;
    if (borderColor != null) {
       potentiallyBorderedAvatar = CircleAvatar(
          radius: radius + borderWidth, // Outer radius includes border
          backgroundColor: borderColor,
          child: avatarContent, // Place original avatar inside border
       );
    }


    // Make tappable if needed
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: potentiallyBorderedAvatar,
      );
    } else {
      return potentiallyBorderedAvatar;
    }
  }
}
