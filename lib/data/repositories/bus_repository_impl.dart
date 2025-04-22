/// lib/data/repositories/bus_repository_impl.dart

import 'dart:io'; // For File type
import 'package:flutter/foundation.dart'; // For Uint8List
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // For guessing mime type
import 'package:path/path.dart' as p; // For file path operations

import 'package:collection/collection.dart'; // For mapNotNull
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // For FormData and MultipartFile

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/maintenance_type.dart';
import '../../../core/enums/photo_type.dart';
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/network_info.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/entities/bus_photo_entity.dart';
import '../../domain/entities/driver_entity.dart'; // Needed for mapping BusEntity
import '../../domain/entities/paginated_list_entity.dart';
import '../../domain/entities/user_entity.dart'; // Needed for mapping DriverEntity
import '../../domain/repositories/bus_repository.dart';
import '../data_sources/remote/bus_remote_data_source.dart';
import '../models/api_response.dart';
import '../models/bus_model.dart';
import '../models/bus_photo_model.dart';
import '../models/driver_model.dart'; // Needed for mapping BusEntity
import '../models/user_model.dart'; // Needed for mapping DriverEntity

/// Implementation of the [BusRepository] interface.
///
/// Orchestrates bus-related data operations by interacting with the remote
/// data source, handling network status checks, and mapping data/exceptions
/// between layers.
class BusRepositoryImpl implements BusRepository {
  final BusRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  /// Creates an instance of [BusRepositoryImpl].
  const BusRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Helper function to safely execute network-dependent operations.
  /// Checks connectivity and handles common exceptions, mapping them to Failures.
  Future<Either<Failure, T>> _performNetworkOperation<T>(
      Future<T> Function() operation) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await operation();
        return Right(result);
      } on AuthenticationException catch (e) {
        Log.w('AuthenticationException caught in BusRepository', error: e);
        return Left(AuthenticationFailure(message: e.message, code: e.code));
      } on AuthorizationException catch (e) {
        Log.w('AuthorizationException caught in BusRepository', error: e);
        return Left(AuthorizationFailure(message: e.message, code: e.code));
      } on ServerException catch (e) {
        Log.e('ServerException caught in BusRepository', error: e);
        return Left(ServerFailure(message: e.message, code: e.statusCode?.toString()));
      } on NetworkException catch (e) {
        Log.e('NetworkException caught in BusRepository', error: e);
        return Left(NetworkFailure(message: e.message, code: e.code));
      } on DataParsingException catch (e) {
        Log.e('DataParsingException caught in BusRepository', error: e);
        return Left(DataParsingFailure(message: e.message, code: e.code));
      } catch (e, stackTrace) {
        Log.e('Unexpected exception caught in BusRepository operation', error: e, stackTrace: stackTrace);
        return Left(UnexpectedFailure(message: e.toString()));
      }
    } else {
      Log.w('BusRepository: Network operation skipped. No internet connection.');
      return Left(NetworkFailure(message: 'No internet connection.')); // TODO: Localize
    }
  }

  @override
  Future<Either<Failure, PaginatedListEntity<BusEntity>>> getBuses({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
    String? driverId,
    bool? isVerified,
    bool? isActive,
    String? searchQuery,
  }) async {
    return _performNetworkOperation(() async {
      final apiResponse = await remoteDataSource.getBuses(
        page: page,
        pageSize: pageSize,
        driverId: driverId,
        isVerified: isVerified,
        isActive: isActive,
        searchQuery: searchQuery,
      );
      return _mapApiResponseToPaginatedList<BusModel, BusEntity>(
          apiResponse, _mapBusModelToEntity);
    });
  }

  @override
  Future<Either<Failure, List<BusEntity>>> getDriverBuses() async {
     return _performNetworkOperation<List<BusEntity>>(() async {
      final busModels = await remoteDataSource.getDriverBuses();
      return busModels.map(_mapBusModelToEntity).toList();
    });
  }

  @override
  Future<Either<Failure, BusEntity>> getBusDetails(String busId) async {
      return _performNetworkOperation<BusEntity>(() async {
        final busModel = await remoteDataSource.getBusDetails(busId);
        return _mapBusModelToEntity(busModel);
    });
  }

  @override
  Future<Either<Failure, BusEntity>> addBus({
    required String driverId,
    required String matricule,
    required String brand,
    required String model,
    int? year,
    int? capacity,
    String? description,
    List<dynamic>? photos, // List of File/Uint8List
  }) async {
      return _performNetworkOperation<BusEntity>(() async {
        // Construct FormData
        final formDataMap = <String, dynamic>{
          'driver': driverId,
          'matricule': matricule,
          'brand': brand,
          'model': model,
          if (year != null) 'year': year,
          if (capacity != null) 'capacity': capacity,
          if (description != null) 'description': description,
        };

        // Add photos if provided
        if (photos != null && photos.isNotEmpty) {
            formDataMap['photos'] = await Future.wait(
              photos.mapIndexed((index, photoData) =>
                  _createMultipartFile(photoData, 'photo_$index'))
            );
        }

        final formData = FormData.fromMap(formDataMap);

        final newBusModel = await remoteDataSource.addBus(formData);
        return _mapBusModelToEntity(newBusModel);
    });
  }

  @override
  Future<Either<Failure, BusEntity>> updateBus({
    required String busId,
    String? brand,
    String? model,
    int? year,
    int? capacity,
    String? description,
    bool? isActive,
    DateTime? nextMaintenance,
  }) async {
      return _performNetworkOperation<BusEntity>(() async {
         // Construct update data map, only including non-null fields
         final updateData = <String, dynamic>{};
         if (brand != null) updateData['brand'] = brand;
         if (model != null) updateData['model'] = model;
         if (year != null) updateData['year'] = year;
         if (capacity != null) updateData['capacity'] = capacity;
         if (description != null) updateData['description'] = description;
         if (isActive != null) updateData['is_active'] = isActive;
         if (nextMaintenance != null) {
            updateData['next_maintenance'] = nextMaintenance.toIso8601String().substring(0, 10); // YYYY-MM-DD format
         }

         if (updateData.isEmpty) {
             Log.w('UpdateBus called with no fields to update for Bus ID: $busId.');
             // Fetch and return current details if nothing to update? Or return failure?
             // Returning failure for now as the intent was likely to update something.
             return Future.error(InvalidInputFailure(message: 'No fields provided for bus update.'));
         }

         final updatedBusModel = await remoteDataSource.updateBus(busId, updateData);
         return _mapBusModelToEntity(updatedBusModel);
      });
  }

  @override
  Future<Either<Failure, BusPhotoEntity>> addBusPhoto({
    required String busId,
    required dynamic photo, // File or Uint8List
    required PhotoType photoType,
    String? description,
  }) async {
       return _performNetworkOperation<BusPhotoEntity>(() async {
          final formData = FormData.fromMap({
             'type': photoType.value,
             'photo': await _createMultipartFile(photo, 'bus_photo'),
             if (description != null) 'description': description,
             // 'bus' ID is in the URL path for this endpoint
          });
          final newPhotoModel = await remoteDataSource.addBusPhoto(busId, formData);
          return _mapBusPhotoModelToEntity(newPhotoModel);
       });
  }

  @override
  Future<Either<Failure, void>> deleteBusPhoto({required String busId, required String photoId}) async {
      // Note: API uses DELETE /bus-photos/{photoId}/, busId might not be needed by remote source.
       return _performNetworkOperation<void>(() async {
          await remoteDataSource.deleteBusPhoto(photoId);
          return Future.value();
       });
  }

  @override
  Future<Either<Failure, void>> recordBusMaintenance({
    required String busId,
    required MaintenanceType maintenanceType,
    required DateTime datePerformed,
    required String description,
    double? cost,
    DateTime? nextMaintenanceDue,
  }) async {
      return _performNetworkOperation<void>(() async {
         final maintenanceData = <String, dynamic>{
            'maintenance_type': maintenanceType.value,
            'date_performed': datePerformed.toIso8601String().substring(0, 10), // YYYY-MM-DD
            'description': description,
            if (cost != null) 'cost': cost.toStringAsFixed(2), // Send as string matching API? Check spec.
            if (nextMaintenanceDue != null) 'next_maintenance_due': nextMaintenanceDue.toIso8601String().substring(0, 10),
         };
         // Although remote returns the model, repo returns void
         await remoteDataSource.recordBusMaintenance(busId, maintenanceData);
         return Future.value();
      });
  }

  @override
  Future<Either<Failure, void>> verifyBus({required String busId, required bool isVerified, String? comments}) async {
      return _performNetworkOperation<void>(() async {
        // Although remote returns the verification model, repo returns void
        await remoteDataSource.verifyBus(busId: busId, isVerified: isVerified, comments: comments);
        return Future.value();
      });
  }

  @override
  Future<Either<Failure, void>> deactivateBus(String busId) async {
      return _performNetworkOperation<void>(() async {
        await remoteDataSource.deactivateBus(busId);
        return Future.value();
      });
  }

   @override
  Future<Either<Failure, void>> reactivateBus(String busId) async {
     return _performNetworkOperation<void>(() async {
        await remoteDataSource.reactivateBus(busId);
        return Future.value();
      });
  }

  @override
  Future<Either<Failure, PaginatedListEntity<BusEntity>>> getBusesPendingVerification({
    int page = 1,
    int pageSize = AppConstants.defaultPaginationSize,
  }) async {
     return _performNetworkOperation(() async {
       final apiResponse = await remoteDataSource.getBusesPendingVerification(
         page: page,
         pageSize: pageSize,
       );
       return _mapApiResponseToPaginatedList<BusModel, BusEntity>(
           apiResponse, _mapBusModelToEntity);
     });
  }

  // --- Helper Mappers ---

  /// Maps a [BusModel] DTO to a [BusEntity] domain object.
  BusEntity _mapBusModelToEntity(BusModel model) {
    return BusEntity(
      id: model.id,
      driverDetails: _mapDriverModelToEntity(model.driverDetails), // Requires nested mapping
      matricule: model.matricule,
      brand: model.brand,
      model: model.model,
      year: model.year,
      capacity: model.capacity,
      description: model.description,
      isVerified: model.isVerified,
      verificationDate: model.verificationDate,
      lastMaintenance: model.lastMaintenance,
      nextMaintenance: model.nextMaintenance,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      photos: model.photos.map(_mapBusPhotoModelToEntity).toList(),
      isTracking: model.isTracking,
    );
  }

  /// Maps a [BusPhotoModel] DTO to a [BusPhotoEntity] domain object.
  BusPhotoEntity _mapBusPhotoModelToEntity(BusPhotoModel model) {
    return BusPhotoEntity(
      id: model.id,
      busId: model.bus, // Map 'bus' (UUID string) to 'busId'
      photoUrl: model.photo, // Map 'photo' (URL string) to 'photoUrl'
      photoType: model.type, // Map 'type' to 'photoType'
      description: model.description,
      createdAt: model.createdAt,
    );
  }

  /// Simple mapper from [DriverModel] (Data Layer) to [DriverEntity] (Domain Layer).
  /// Assumes underlying UserModel mapping is also done or available.
  DriverEntity _mapDriverModelToEntity(DriverModel model) {
    // Basic mapping, assumes UserModel is correctly mapped within DriverModel if needed downstream
    // Note: Need to parse averageRating string to double
    double? avgRating;
    if(model.averageRating != null) {
        avgRating = double.tryParse(model.averageRating!);
    }

    return DriverEntity(
      id: model.id,
      userDetails: _mapUserModelToEntity(model.userDetails), // Map nested user details
      idNumber: model.idNumber,
      idPhotoUrl: model.idPhoto,
      licenseNumber: model.licenseNumber,
      licensePhotoUrl: model.licensePhoto,
      isVerified: model.isVerified,
      verificationDate: model.verificationDate,
      experienceYears: model.experienceYears,
      dateOfBirth: model.dateOfBirth,
      address: model.address,
      emergencyContact: model.emergencyContact,
      notes: model.notes,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      averageRating: avgRating,
    );
  }

    /// Simple mapper from [UserModel] (Data Layer) to [UserEntity] (Domain Layer).
    /// Copied from AuthRepositoryImpl for convenience, consider centralizing mappers later.
    UserEntity _mapUserModelToEntity(UserModel model) {
      return UserEntity(
        id: model.id,
        email: model.email,
        firstName: model.firstName,
        lastName: model.lastName,
        phoneNumber: model.phoneNumber,
        userType: model.userType,
        language: model.language,
        isActive: model.isActive,
        isEmailVerified: model.isEmailVerified,
        isPhoneVerified: model.isPhoneVerified,
        dateJoined: model.dateJoined,
        lastLogin: model.lastLogin,
      );
    }

  /// Maps an [ApiResponse] DTO containing models of type [M] to a [PaginatedListEntity]
  /// containing entities of type [E], using the provided [mapper] function.
  PaginatedListEntity<E> _mapApiResponseToPaginatedList<M, E>(
      ApiResponse<M> apiResponse, E Function(M model) mapper) {
    return PaginatedListEntity<E>(
      items: apiResponse.results.map(mapper).toList(),
      totalCount: apiResponse.count,
      hasMore: apiResponse.next != null,
    );
  }

   /// Helper to create MultipartFile from File or Uint8List.
   /// Copied from AuthRepositoryImpl - consider moving to a shared utility.
  Future<MultipartFile> _createMultipartFile(dynamic fileData, String defaultFilename) async {
      if (fileData is File) {
         String fileName = p.basename(fileData.path);
         String? contentType = lookupMimeType(fileData.path);
         Log.d('Creating MultipartFile from File: path=${fileData.path}, name=$fileName, type=$contentType');
         return await MultipartFile.fromFile(
            fileData.path,
            filename: fileName,
            contentType: contentType != null ? MediaType.parse(contentType) : null,
         );
      } else if (fileData is Uint8List) {
          // Need a filename, try to guess type or use default
          String extension = '.jpg'; // Default extension
          String? contentType = lookupMimeType('', headerBytes: fileData);
          if (contentType != null) {
             extension = extensionFromMime(contentType) ?? extension;
          }
          final tempFilename = '${defaultFilename}_${DateTime.now().millisecondsSinceEpoch}$extension';
          Log.d('Creating MultipartFile from Bytes: name=$tempFilename, type=$contentType');
         return MultipartFile.fromBytes(
            fileData,
            filename: tempFilename,
            contentType: contentType != null ? MediaType.parse(contentType) : null,
         );
      } else {
          Log.e('Unsupported file type for MultipartFile: ${fileData?.runtimeType}');
         throw ArgumentError('Unsupported file type for MultipartFile: ${fileData?.runtimeType}');
      }
   }
}
