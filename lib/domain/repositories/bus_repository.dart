/// lib/domain/repositories/bus_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/photo_type.dart';
import '../../core/enums/maintenance_type.dart';
import '../../core/error/failures.dart';
import '../entities/bus_entity.dart';
import '../entities/bus_photo_entity.dart';
import '../entities/paginated_list_entity.dart';

/// Abstract interface defining the contract for bus-related data operations.
///
/// This contract specifies methods for fetching bus lists (paginated, filtered),
/// getting details of a specific bus, adding/updating buses, managing photos,
/// recording maintenance, and handling verification status. Implementations
/// in the data layer will interact with the corresponding backend API endpoints.
abstract class BusRepository {
  /// Fetches a paginated list of buses, potentially filtered or searched.
  /// Corresponds to GET /api/v1/buses/.
  ///
  /// - [page]: The page number to retrieve.
  /// - [pageSize]: The number of items per page.
  /// - [driverId]: Optional filter to get buses for a specific driver.
  /// - [isVerified]: Optional filter for verification status.
  /// - [isActive]: Optional filter for active status.
  /// - [searchQuery]: Optional search term for matricule, brand, model.
  ///
  /// Returns a [PaginatedListEntity] containing [BusEntity] objects on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, PaginatedListEntity<BusEntity>>> getBuses({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize, // Use constant
    String? driverId,
    bool? isVerified,
    bool? isActive,
    String? searchQuery,
  });

  /// Fetches the list of buses specifically assigned to the currently authenticated driver.
  /// Corresponds to GET /api/v1/buses/for_driver/.
  ///
  /// Returns a list of [BusEntity] objects on success.
  /// Returns a [Failure] on error (e.g., not authenticated as a driver).
  Future<Either<Failure, List<BusEntity>>> getDriverBuses();

  /// Fetches the detailed information for a specific bus by its ID.
  /// Corresponds to GET /api/v1/buses/{id}/.
  ///
  /// - [busId]: The unique identifier of the bus to retrieve.
  ///
  /// Returns a [BusEntity] with full details on success.
  /// Returns a [Failure] if the bus is not found or another error occurs.
  Future<Either<Failure, BusEntity>> getBusDetails(String busId);

  /// Adds a new bus associated with the current driver (or specified driver by admin).
  /// Corresponds to POST /api/v1/buses/.
  ///
  /// - [driverId]: ID of the driver this bus belongs to.
  /// - [matricule]: Vehicle registration number.
  /// - [brand]: Manufacturer brand.
  /// - [model]: Vehicle model.
  /// - [year]: Manufacturing year.
  /// - [capacity]: Passenger capacity.
  /// - [description]: Optional description.
  /// - [photos]: List of photos (File/Uint8List) to upload initially.
  ///
  /// Returns the created [BusEntity] on success.
  /// Returns a [Failure] if creation fails (e.g., validation error, network issue).
  Future<Either<Failure, BusEntity>> addBus({
    required String driverId, // Usually current driver, maybe admin specifies
    required String matricule,
    required String brand,
    required String model,
    int? year,
    int? capacity,
    String? description,
    List<dynamic>? photos, // List of File/Uint8List from presentation
  });

  /// Updates details for an existing bus.
  /// Corresponds to PUT or PATCH /api/v1/buses/{id}/.
  ///
  /// - [busId]: The ID of the bus to update.
  /// - Provide only the fields to be updated (matricule typically cannot be changed).
  ///
  /// Returns the updated [BusEntity] on success.
  /// Returns a [Failure] if the update fails.
  Future<Either<Failure, BusEntity>> updateBus({
    required String busId,
    String? brand,
    String? model,
    int? year,
    int? capacity,
    String? description,
    bool? isActive, // Admin/Driver might change active status
    DateTime? nextMaintenance,
  });

  /// Adds a photo to an existing bus.
  /// Corresponds to POST /api/v1/buses/{id}/add_photo/.
  ///
  /// - [busId]: The ID of the bus to add the photo to.
  /// - [photo]: The photo file (File/Uint8List) to upload.
  /// - [photoType]: The type of the photo (Exterior, Interior, etc.).
  /// - [description]: Optional description for the photo.
  ///
  /// Returns the created [BusPhotoEntity] on success.
  /// Returns a [Failure] if the upload fails.
  Future<Either<Failure, BusPhotoEntity>> addBusPhoto({
    required String busId,
    required dynamic photo, // File or Uint8List
    required PhotoType photoType,
    String? description,
  });

  /// Deletes a specific photo associated with a bus.
  /// Corresponds to DELETE /api/v1/bus-photos/{id}/ (requires photo ID).
  ///
  /// - [busId]: ID of the bus (may not be needed by API but good for context).
  /// - [photoId]: The ID of the photo to delete.
  ///
  /// Returns `void` represented as `Right(null)` on successful deletion.
  /// Returns a [Failure] on error.
  Future<Either<Failure, void>> deleteBusPhoto({
    required String busId,
    required String photoId,
  });

  /// Records a maintenance event for a specific bus.
  /// Corresponds to POST /api/v1/buses/{id}/maintenance/.
  ///
  /// - [busId]: The ID of the bus.
  /// - [maintenanceType]: The type of maintenance performed.
  /// - [datePerformed]: Date the maintenance occurred.
  /// - [description]: Details of the maintenance.
  /// - [cost]: Optional cost of the maintenance.
  /// - [nextMaintenanceDue]: Optional date for the next scheduled maintenance.
  ///
  /// Returns `void` represented as `Right(null)` on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, void>> recordBusMaintenance({
    required String busId,
    required MaintenanceType maintenanceType,
    required DateTime datePerformed,
    required String description,
    double? cost,
    DateTime? nextMaintenanceDue,
  });

  /// Verifies or rejects a bus (Admin action).
  /// Corresponds to POST /api/v1/buses/{id}/verify/.
  ///
  /// - [busId]: The ID of the bus to verify/reject.
  /// - [isVerified]: Set to true to verify, false to reject.
  /// - [comments]: Optional comments regarding the verification decision.
  ///
  /// Returns `void` represented as `Right(null)` on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, void>> verifyBus({
    required String busId,
    required bool isVerified, // True for verify, False for reject
    String? comments,
  });

  /// Deactivates a bus.
  /// Corresponds to POST /api/v1/buses/{id}/deactivate/.
  ///
  /// - [busId]: The ID of the bus to deactivate.
  ///
  /// Returns `void` represented as `Right(null)` on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, void>> deactivateBus(String busId);

  /// Reactivates a previously deactivated bus.
  /// Corresponds to POST /api/v1/buses/{id}/reactivate/.
  ///
  /// - [busId]: The ID of the bus to reactivate.
  ///
  /// Returns `void` represented as `Right(null)` on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, void>> reactivateBus(String busId);

  /// Fetches a paginated list of buses that are pending verification (Admin).
  /// Corresponds to GET /api/v1/buses/pending_verification/.
  ///
  /// - [page]: The page number to retrieve.
  /// - [pageSize]: The number of items per page.
  ///
  /// Returns a [PaginatedListEntity] containing [BusEntity] objects on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, PaginatedListEntity<BusEntity>>> getBusesPendingVerification({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize, // Use constant
  });
}
