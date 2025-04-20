/// lib/domain/repositories/driver_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/failures.dart';
import '../entities/driver_entity.dart';
import '../entities/driver_rating_entity.dart';
import '../entities/paginated_list_entity.dart';
import '../entities/driver_verification_entity.dart'; // Import the verification entity

/// Abstract interface defining the contract for data operations related to Drivers.
abstract class DriverRepository {
  /// Fetches the detailed profile of the currently authenticated driver.
  Future<Either<Failure, DriverEntity>> getDriverProfile();

  /// Updates the profile details for the currently authenticated driver.
  Future<Either<Failure, DriverEntity>> updateDriverDetails({
    String? driverId, dynamic idPhoto, dynamic licensePhoto, int? experienceYears,
    DateTime? dateOfBirth, String? address, String? emergencyContact, String? notes,
    bool? isActive,
  });

  /// Fetches statistics for a specific driver.
  Future<Either<Failure, Map<String, dynamic>>> getDriverStats(String driverId);

  /// Fetches ratings submitted for a specific driver, paginated.
  Future<Either<Failure, PaginatedListEntity<DriverRatingEntity>>> getDriverRatings({
    required String driverId, int page = 1, int pageSize = AppConstants.defaultPaginationSize,
  });

  /// Submits a rating for a specific driver.
  Future<Either<Failure, DriverRatingEntity>> rateDriver({
    required String driverId, required int rating, String? comment,
  });

  // --- Admin / Driver Management Methods ---

  /// Fetches a paginated list of all drivers (Admin only).
  Future<Either<Failure, PaginatedListEntity<DriverEntity>>> getDrivers({
    int page = 1, int pageSize = AppConstants.defaultPaginationSize, String? searchQuery,
    bool? isVerified, bool? isActive,
  });

  /// Fetches details for a specific driver by ID (Admin only).
  Future<Either<Failure, DriverEntity>> getDriverById(String driverId);

  /// Verifies or rejects a driver's application/profile (Admin only).
  /// Returns the [DriverVerificationEntity] on success.
  Future<Either<Failure, DriverVerificationEntity>> verifyDriver({ // CORRECTED: Return Type
    required String driverId, required bool isVerified, String? verificationNotes,
  });

  /// Deactivates a driver's account (Admin only).
  /// Returns the updated [DriverEntity] on success.
  Future<Either<Failure, DriverEntity>> deactivateDriver(String driverId); // CORRECTED: Return Type

  /// Reactivates a driver's account (Admin only).
  /// Returns the updated [DriverEntity] on success.
  Future<Either<Failure, DriverEntity>> reactivateDriver(String driverId); // CORRECTED: Return Type

  /// Fetches a paginated list of drivers pending verification (Admin only).
  Future<Either<Failure, PaginatedListEntity<DriverEntity>>> getDriversPendingVerification({
    int page = 1, int pageSize = AppConstants.defaultPaginationSize,
  });
}