/// lib/presentation/pages/driver/driver_profile_page.dart

import 'package:cached_network_image/cached_network_image.dart'; // For displaying photos
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../../config/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/driver_entity.dart';
import '../../blocs/driver_profile/driver_profile_bloc.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/loading_indicator.dart';

/// Page displaying the details of the currently authenticated driver's profile.
class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Assuming DriverProfileBloc is provided higher up in the tree or globally registered.
    // If not, wrap with BlocProvider here.
    // Example:
    // return BlocProvider(
    //   create: (context) => DriverProfileBloc(
    //      getDriverProfileUseCase: sl(),
    //      updateDriverDetailsUseCase: sl(),
    //   )..add(const LoadDriverProfile()),
    //   child: const _DriverProfileView(),
    // );
    return const _DriverProfileView();
  }
}

class _DriverProfileView extends StatelessWidget {
  const _DriverProfileView();

   /// Refreshes the profile data.
  Future<void> _refreshProfile(BuildContext context) async {
     Log.d("DriverProfilePage: Refreshing profile.");
     context.read<DriverProfileBloc>().add(const LoadDriverProfile());
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder for localization
    String tr(String key) => key.replaceAll('_', ' ').split(' ').map(StringUtil.capitalizeFirst).join(' ');
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('my_driver_profile')), // TODO: Localize 'My Profile'
        leading: const BackButton(),
        actions: [
            IconButton(
               icon: const Icon(Icons.edit_outlined),
               tooltip: 'Edit Profile', // TODO: Localize
               onPressed: () {
                  final state = context.read<DriverProfileBloc>().state;
                  if (state is DriverProfileLoaded) {
                     Log.i('Navigating to Edit Driver Profile page.');
                      // TODO: Implement Driver Profile Edit page and navigation
                     // context.pushNamed(RouteNames.driverProfileEdit, extra: state.driverProfile);
                     Helpers.showSnackBar(context, message: 'Edit Profile page not implemented yet.');
                  } else {
                     Helpers.showSnackBar(context, message: 'Profile data not loaded yet.'); // TODO: Localize
                  }
               },
            ),
        ],
      ),
      body: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          if (state is DriverProfileInitial || state is DriverProfileLoading) {
            return const Center(child: LoadingIndicator(message: 'Loading Profile...')); // TODO: Localize
          }
          if (state is DriverProfileError && state.driverProfile == null) {
            // Show error display if initial load failed
             return Center(
               child: ErrorDisplay(
                  message: state.message,
                  onRetry: () => _refreshProfile(context),
               ),
            );
          }
          // If loaded or error occurred during update (previous data available)
          if (state is DriverProfileLoaded || (state is DriverProfileError && state.driverProfile != null)) {
              final driver = (state is DriverProfileLoaded)
                              ? state.driverProfile
                              : (state as DriverProfileError).driverProfile!;
              final user = driver.userDetails; // Convenience access

             return RefreshIndicator(
               onRefresh: () => _refreshProfile(context),
               child: ListView(
                 padding: const EdgeInsets.all(AppTheme.spacingMedium),
                 children: [
                     // --- Basic Info Card ---
                     _buildInfoCard(
                       context: context,
                       title: tr('personal_information'), // TODO: Localize
                       icon: Icons.person_pin_outlined,
                       children: [
                          _buildDetailRow(context, Icons.person_outline, tr('full_name'), driver.fullName.isNotEmpty ? driver.fullName : '-'), // TODO: Localize
                          _buildDetailRow(context, Icons.email_outlined, tr('email'), user.email), // TODO: Localize
                          _buildDetailRow(context, Icons.phone_outlined, tr('phone_number'), user.phoneNumber ?? '-'), // TODO: Localize
                          if (driver.dateOfBirth != null)
                            _buildDetailRow(context, Icons.cake_outlined, tr('date_of_birth'), DateFormat.yMMMd().format(driver.dateOfBirth!)), // TODO: Localize
                          if (driver.address != null && driver.address!.isNotEmpty)
                             _buildDetailRow(context, Icons.home_outlined, tr('address'), driver.address!), // TODO: Localize
                          if (driver.emergencyContact != null && driver.emergencyContact!.isNotEmpty)
                             _buildDetailRow(context, Icons.contact_emergency_outlined, tr('emergency_contact'), driver.emergencyContact!), // TODO: Localize
                       ]
                     ),
                     const SizedBox(height: AppTheme.spacingMedium),

                      // --- Driver Details Card ---
                     _buildInfoCard(
                       context: context,
                       title: tr('driver_details'), // TODO: Localize
                       icon: Icons.badge_outlined,
                       children: [
                          _buildDetailRow(context, Icons.badge_outlined, tr('id_number'), driver.idNumber), // TODO: Localize
                          _buildDetailRow(context, Icons.card_membership_outlined, tr('license_number'), driver.licenseNumber), // TODO: Localize
                          if (driver.experienceYears != null)
                             _buildDetailRow(context, Icons.star_border_outlined, tr('experience'), '${driver.experienceYears} years'), // TODO: Localize 'years'
                          _buildDetailRow(context, Icons.verified_user_outlined, tr('verification_status'), driver.isVerified ? 'Verified' : 'Pending', // TODO: Localize Verified/Pending
                              valueColor: driver.isVerified ? AppTheme.successColor : AppTheme.warningColor),
                          if (driver.verificationDate != null)
                             _buildDetailRow(context, Icons.event_available_outlined, tr('verification_date'), DateFormat.yMd().format(driver.verificationDate!)), // TODO: Localize
                          if (driver.averageRating != null)
                             _buildDetailRow(context, Icons.star_half_outlined, tr('average_rating'), driver.averageRating!.toStringAsFixed(1)), // TODO: Localize

                           // Optional notes if needed
                           if (driver.notes != null && driver.notes!.isNotEmpty)
                             _buildDetailRow(context, Icons.notes_outlined, tr('notes'), driver.notes!), // TODO: Localize
                       ]
                     ),
                     const SizedBox(height: AppTheme.spacingMedium),

                      // --- Documents Card ---
                      _buildInfoCard(
                          context: context,
                          title: tr('documents'), // TODO: Localize
                          icon: Icons.folder_copy_outlined,
                          children: [
                             Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                   _buildPhotoDisplay(context, 'ID Photo', driver.idPhotoUrl), // TODO: Localize
                                   _buildPhotoDisplay(context, 'License Photo', driver.licensePhotoUrl), // TODO: Localize
                                ],
                             )
                          ]
                       ),
                       const SizedBox(height: AppTheme.spacingMedium),
                 ],
               ),
             );
          }

          // Fallback
          return const Center(child: Text('Error: Unknown profile state.')); // TODO: Localize
        },
      ),
    );
  }

  /// Builds a styled card container for sections.
  Widget _buildInfoCard({
     required BuildContext context,
     required String title,
     required IconData icon,
     required List<Widget> children
   }) {
      final theme = Theme.of(context);
      return Card(
          elevation: AppTheme.elevationSmall / 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
          child: Padding(
             padding: const EdgeInsets.all(AppTheme.spacingMedium),
             child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Row(
                       children: [
                          Icon(icon, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                       ],
                    ),
                    const Divider(height: AppTheme.spacingMedium * 1.5),
                    ...children,
                 ]
             ),
          ),
      );
   }


  /// Builds a row for displaying a detail item (Label: Value).
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall / 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Icon(icon, size: 18, color: AppTheme.neutralMedium),
           const SizedBox(width: AppTheme.spacingMedium),
           Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
             )
           ),
           const SizedBox(width: AppTheme.spacingSmall),
           Expanded(
              flex: 2, // Give more space to value
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: textTheme.bodyMedium?.copyWith(
                   fontWeight: FontWeight.w500,
                   color: valueColor, // Use default if null
                ),
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
             ),
           ),
        ],
      ),
    );
  }

  /// Builds a display area for ID/License photos.
  Widget _buildPhotoDisplay(BuildContext context, String label, String imageUrl) {
     final theme = Theme.of(context);
     return Column(
        children: [
           Text(label, style: theme.textTheme.labelMedium),
           const SizedBox(height: AppTheme.spacingSmall),
           ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: CachedNetworkImage(
                 imageUrl: imageUrl,
                 height: 120, // Adjust size
                 width: 100, // Adjust size
                 fit: BoxFit.cover,
                 placeholder: (context, url) => const LoadingIndicator(size: 20),
                 errorWidget: (context, url, error) => Container(
                    height: 120, width: 100,
                    color: AppTheme.neutralLight.withOpacity(0.3),
                    child: const Icon(Icons.error_outline, color: AppTheme.neutralMedium)
                 ),
              ),
           ),
        ],
     );
  }
}

/// Helper class for capitalization (move to string_utils.dart if not already done)
class StringUtil {
   static String capitalizeFirst(String s) { if (s.isEmpty) return ''; return "${s[0].toUpperCase()}${s.substring(1)}"; }
}
