/// lib/data/repositories/driver_repository_impl.dart

import 'dart:io'; // For File type
import 'package:flutter/foundation.dart'; // For Uint8List
import 'package:mime/mime.dart'; // For guessing mime type
import 'package:path/path.dart' as p; // For file path operations
import 'package:http_parser/http_parser.dart'; // For MediaType

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/language.dart';
import '../../../core/enums/user_type.dart';
import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/network/network_info.dart';
import '../../../core/typedefs/common_types.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/driver_rating_entity.dart';
import '../../domain/entities/driver_verification_entity.dart';
import '../../domain/entities/paginated_list_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import '../data_sources/remote/driver_remote_data_source.dart';
import '../models/api_response.dart';
import '../models/driver_model.dart';
// Import the actual models (ensure they are generated)
import '../models/driver_rating_model.dart';
import '../models/driver_verification_model.dart';
import '../models/user_model.dart';
// Import models needed for nested mapping in helpers
import '../models/bus_model.dart';
import '../models/line_model.dart';
import '../models/stop_model.dart';
import '../models/bus_photo_model.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/entities/line_entity.dart';
import '../../domain/entities/stop_entity.dart';
import '../../domain/entities/bus_photo_entity.dart';
import '../../core/enums/photo_type.dart';
import '../../core/enums/maintenance_type.dart';
import '../../core/enums/tracking_status.dart';

/// Implementation of the [DriverRepository] interface.
///
/// Orchestrates driver-related data operations by interacting with the remote
/// data source, handling network status checks, and mapping data/exceptions.
class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  /// Creates an instance of [DriverRepositoryImpl].
  const DriverRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Helper function to safely execute network-dependent operations.
  Future<Either<Failure, T>> _performNetworkOperation<T>(Future<T> Function() operation) async {
    if (await networkInfo.isConnected) { try { final result = await operation(); return Right(result); } on AuthenticationException catch (e) { Log.w('AuthException in DriverRepo', error: e); return Left(AuthenticationFailure(message: e.message, code: e.code)); } on AuthorizationException catch (e) { Log.w('AuthzException in DriverRepo', error: e); return Left(AuthorizationFailure(message: e.message, code: e.code)); } on ServerException catch (e) { Log.e('ServerException in DriverRepo', error: e); return Left(ServerFailure(message: e.message, code: e.statusCode?.toString())); } on NetworkException catch (e) { Log.e('NetworkException in DriverRepo', error: e); return Left(NetworkFailure(message: e.message, code: e.code)); } on DataParsingException catch (e) { Log.e('DataParsingException in DriverRepo', error: e); return Left(DataParsingFailure(message: e.message, code: e.code)); } catch (e, s) { Log.e('Unexpected exception in DriverRepo', error: e, stackTrace: s); return Left(UnexpectedFailure(message: e.toString())); } } else { Log.w('DriverRepo: Network operation skipped. Offline.'); return Left(NetworkFailure(message: 'No internet connection.')); }
  }

  @override
  Future<Either<Failure, DriverEntity>> getDriverProfile() async {
    return _performNetworkOperation(() async {
      final model = await remoteDataSource.getDriverProfile();
      return _mapDriverModelToEntity(model);
    });
  }

  @override
  Future<Either<Failure, DriverEntity>> updateDriverDetails({ String? driverId, dynamic idPhoto, dynamic licensePhoto, int? experienceYears, DateTime? dateOfBirth, String? address, String? emergencyContact, String? notes, bool? isActive, }) async {
    return _performNetworkOperation(() async {
      final updateData = <String, dynamic>{};
      if (experienceYears != null) updateData['experience_years'] = experienceYears;
      if (dateOfBirth != null) updateData['date_of_birth'] = dateOfBirth.toIso8601String().substring(0, 10);
      if (address != null) updateData['address'] = address.isEmpty ? null : address;
      if (emergencyContact != null) updateData['emergency_contact'] = emergencyContact.isEmpty ? null : emergencyContact;
      if (notes != null) updateData['notes'] = notes.isEmpty ? null : notes;
      if (isActive != null) updateData['is_active'] = isActive;
      MultipartFile? idPhotoMultipart; MultipartFile? licensePhotoMultipart;
      if (idPhoto != null) { idPhotoMultipart = await _createMultipartFile(idPhoto, 'id_photo'); updateData['id_photo'] = idPhotoMultipart; }
      if (licensePhoto != null) { licensePhotoMultipart = await _createMultipartFile(licensePhoto, 'license_photo'); updateData['license_photo'] = licensePhotoMultipart; }
      if (updateData.isEmpty) { return Future.error(InvalidInputFailure(message: 'No fields provided for driver update.')); }
      final bool hasFiles = idPhotoMultipart != null || licensePhotoMultipart != null;
      dynamic dataPayload = hasFiles ? FormData.fromMap(updateData) : updateData;
      if (hasFiles) { Log.d("Updating driver details with FormData (Files included)."); } else { Log.d("Updating driver details with JSON data (No Files)."); }
      // TODO: Verify updateDriverDetails remote source handles PATCH with FormData if needed
      final model = await remoteDataSource.updateDriverDetails(driverId, dataPayload);
      return _mapDriverModelToEntity(model);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDriverStats(String driverId) async {
    return _performNetworkOperation(() => remoteDataSource.getDriverStats(driverId));
  }

  @override
  Future<Either<Failure, PaginatedListEntity<DriverRatingEntity>>> getDriverRatings({ required String driverId, int page = 1, int pageSize = AppConstants.defaultPaginationSize, }) async {
    return _performNetworkOperation(() async {
      final apiResponse = await remoteDataSource.getDriverRatings(driverId: driverId, page: page, pageSize: pageSize);
      // Use the actual generated DriverRatingModel for mapping
      return _mapApiResponseToPaginatedList<DriverRatingModel, DriverRatingEntity>( apiResponse, _mapDriverRatingModelToEntity);
    });
  }

  @override
  Future<Either<Failure, DriverRatingEntity>> rateDriver({required String driverId, required int rating, String? comment}) async {
    return _performNetworkOperation(() async {
      final model = await remoteDataSource.rateDriver(driverId: driverId, rating: rating, comment: comment);
      return _mapDriverRatingModelToEntity(model);
    });
  }

  // --- Admin Methods Implementation ---
  @override
  Future<Either<Failure, PaginatedListEntity<DriverEntity>>> getDrivers({ int page = 1, int pageSize = AppConstants.defaultPaginationSize, String? searchQuery, bool? isVerified, bool? isActive}) async {
    return _performNetworkOperation(() async {
      final apiResponse = await remoteDataSource.getDrivers(page: page, pageSize: pageSize, searchQuery: searchQuery, isVerified: isVerified, isActive: isActive);
      return _mapApiResponseToPaginatedList<DriverModel, DriverEntity>(apiResponse, _mapDriverModelToEntity);
    });
  }

  @override
  Future<Either<Failure, DriverEntity>> getDriverById(String driverId) async {
    return _performNetworkOperation(() async {
      final model = await remoteDataSource.getDriverById(driverId);
      return _mapDriverModelToEntity(model);
    });
  }

  @override
  Future<Either<Failure, DriverVerificationEntity>> verifyDriver({ // CORRECTED: Return Type matches interface
    required String driverId,
    required bool isVerified,
    String? verificationNotes,
  }) async {
    return _performNetworkOperation<DriverVerificationEntity>(() async { // CORRECTED: Return Type matches interface
      final model = await remoteDataSource.verifyDriver( // remoteDataSource returns DriverVerificationModel
          driverId: driverId,
          isVerified: isVerified,
          verificationNotes: verificationNotes);
      return _mapDriverVerificationModelToEntity(model); // CORRECTED: Map to Entity
    });
  }

  @override
  Future<Either<Failure, DriverEntity>> deactivateDriver(String driverId) async { // CORRECTED: Return Type matches interface
    return _performNetworkOperation<DriverEntity>(() async { // CORRECTED: Return Type matches interface
      final model = await remoteDataSource.deactivateDriver(driverId); // remoteDataSource returns DriverModel
      return _mapDriverModelToEntity(model); // CORRECTED: Map to Entity
    });
  }

  @override
  Future<Either<Failure, DriverEntity>> reactivateDriver(String driverId) async { // CORRECTED: Return Type matches interface
    return _performNetworkOperation<DriverEntity>(() async { // CORRECTED: Return Type matches interface
      final model = await remoteDataSource.reactivateDriver(driverId); // remoteDataSource returns DriverModel
      return _mapDriverModelToEntity(model); // CORRECTED: Map to Entity
    });
  }

  @override
  Future<Either<Failure, PaginatedListEntity<DriverEntity>>> getDriversPendingVerification({
    int page = 1, int pageSize = AppConstants.defaultPaginationSize}) async {
    return _performNetworkOperation(() async {
      final apiResponse = await remoteDataSource.getDriversPendingVerification(page: page, pageSize: pageSize);
      return _mapApiResponseToPaginatedList<DriverModel, DriverEntity>(apiResponse, _mapDriverModelToEntity);
    });
  }


  // --- Helper Mappers (Copied/adapted - centralize later) ---
  PaginatedListEntity<E> _mapApiResponseToPaginatedList<M, E>(ApiResponse<M> apiResponse, E Function(M model) mapper) { return PaginatedListEntity<E>(items: apiResponse.results.map(mapper).toList(), totalCount: apiResponse.count, hasMore: apiResponse.next != null); }
  UserEntity _mapUserModelToEntity(UserModel model) { return UserEntity( id: model.id, email: model.email, firstName: model.firstName, lastName: model.lastName, phoneNumber: model.phoneNumber, userType: model.userType, language: model.language, isActive: model.isActive, isEmailVerified: model.isEmailVerified, isPhoneVerified: model.isPhoneVerified, dateJoined: model.dateJoined, lastLogin: model.lastLogin, ); }
  DriverEntity _mapDriverModelToEntity(DriverModel model) { double? avgRating; if(model.averageRating != null) { avgRating = double.tryParse(model.averageRating!); } return DriverEntity( id: model.id, userDetails: _mapUserModelToEntity(model.userDetails), idNumber: model.idNumber, idPhotoUrl: model.idPhoto, licenseNumber: model.licenseNumber, licensePhotoUrl: model.licensePhoto, isVerified: model.isVerified, verificationDate: model.verificationDate, experienceYears: model.experienceYears, dateOfBirth: model.dateOfBirth, address: model.address, emergencyContact: model.emergencyContact, notes: model.notes, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt, averageRating: avgRating, ); }
  // Mapper for DriverRating (ensure DriverRatingModel generated with these fields)
  DriverRatingEntity _mapDriverRatingModelToEntity(DriverRatingModel model) {
    return DriverRatingEntity(
      id: model.id,
      driverId: model.driver,
      userDetails: model.userDetails == null ? null : _mapUserModelToEntity(model.userDetails!),
      rating: model.rating,
      comment: model.comment,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
  /// Mapper for DriverVerification
  DriverVerificationEntity _mapDriverVerificationModelToEntity(DriverVerificationModel model) {
    return DriverVerificationEntity(
      id: model.id,
      driverId: model.driver, // CORRECTED: Use model.driver
      verifiedByDetails: model.verifiedByDetails == null ? null : _mapUserModelToEntity(model.verifiedByDetails!),
      isVerified: model.isVerified,
      comments: model.comments,
      verificationDate: model.verificationDate,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
  // --- Assume other necessary mappers exist (BusPhoto, Bus, Line, Stop) ---
  BusPhotoEntity _mapBusPhotoModelToEntity(BusPhotoModel model) { return BusPhotoEntity( id: model.id, busId: model.bus, photoUrl: model.photo, photoType: model.type, description: model.description, createdAt: model.createdAt, ); }
  BusEntity _mapBusModelToEntity(BusModel model) { return BusEntity( id: model.id, driverDetails: _mapDriverModelToEntity(model.driverDetails), matricule: model.matricule, brand: model.brand, model: model.model, year: model.year, capacity: model.capacity, description: model.description, isVerified: model.isVerified, verificationDate: model.verificationDate, lastMaintenance: model.lastMaintenance, nextMaintenance: model.nextMaintenance, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt, photos: model.photos.map(_mapBusPhotoModelToEntity).toList(), isTracking: model.isTracking, ); }
  StopEntity _mapStopModelToEntity(StopModel model) { final lat = double.tryParse(model.latitude) ?? 0.0; final lon = double.tryParse(model.longitude) ?? 0.0; return StopEntity( id: model.id, name: model.name, code: model.code, address: model.address, imageUrl: model.image, description: model.description, latitude: lat, longitude: lon, accuracy: model.accuracy, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt, ); }
  LineEntity _mapLineModelToEntity(LineModel model) { final startStop = model.startLocationDetails != null ? _mapStopModelToEntity(model.startLocationDetails!) : StopEntity.empty().copyWith(id: model.startLocation); final endStop = model.endLocationDetails != null ? _mapStopModelToEntity(model.endLocationDetails!) : StopEntity.empty().copyWith(id: model.endLocation); return LineEntity( id: model.id, name: model.name, description: model.description, color: model.color, startLocationDetails: startStop, endLocationDetails: endStop, path: model.path, estimatedDurationMinutes: model.estimatedDuration, distanceMeters: model.distance, isActive: model.isActive, createdAt: model.createdAt, updatedAt: model.updatedAt, stopsCount: model.stopsCount, activeBusesCount: model.activeBusesCount, ); }


  /// Helper to create MultipartFile (copied/adapted)
  Future<MultipartFile> _createMultipartFile(dynamic fileData, String defaultFilename) async { if (fileData is File) { String fileName = p.basename(fileData.path); String? contentType = lookupMimeType(fileData.path); MediaType? mediaType = contentType != null ? MediaType.parse(contentType) : null; Log.d('Creating MultipartFile from File: path=${fileData.path}, name=$fileName, type=$mediaType'); return await MultipartFile.fromFile( fileData.path, filename: fileName, contentType: mediaType ); } else if (fileData is Uint8List) { String extension = '.jpg'; String? contentType = lookupMimeType('', headerBytes: fileData); if (contentType != null) { extension = extensionFromMime(contentType) ?? extension; } final tempFilename = '${defaultFilename}_${DateTime.now().millisecondsSinceEpoch}$extension'; MediaType? mediaType = contentType != null ? MediaType.parse(contentType) : null; Log.d('Creating MultipartFile from Bytes: name=$tempFilename, type=$mediaType'); return MultipartFile.fromBytes( fileData, filename: tempFilename, contentType: mediaType ); } else { Log.e('Unsupported file type for MultipartFile: ${fileData?.runtimeType}'); throw ArgumentError('Unsupported file type for MultipartFile: ${fileData?.runtimeType}'); } }

}

// REMOVED Placeholder Models - Ensure DriverRatingModel & DriverVerificationModel generated