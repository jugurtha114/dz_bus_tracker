/// lib/core/di/service_locator.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Config
import '../../config/app_config.dart';

// Core Layer
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../network/api_interceptor.dart';
import '../network/network_info.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/offline_sync_service.dart';
import '../services/storage_service.dart';

// Data Layer
import '../../data/data_sources/local/auth_local_data_source.dart';
import '../../data/data_sources/local/cache_local_data_source.dart';
import '../../data/data_sources/local/offline_local_data_source.dart';
import '../../data/data_sources/remote/auth_remote_data_source.dart';
import '../../data/data_sources/remote/bus_remote_data_source.dart';
import '../../data/data_sources/remote/driver_remote_data_source.dart';
import '../../data/data_sources/remote/eta_remote_data_source.dart';
import '../../data/data_sources/remote/favorite_remote_data_source.dart';
import '../../data/data_sources/remote/feedback_remote_data_source.dart';
import '../../data/data_sources/remote/line_remote_data_source.dart';
import '../../data/data_sources/remote/tracking_remote_data_source.dart';
import '../../data/data_sources/remote/user_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/bus_repository_impl.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../data/repositories/eta_repository_impl.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../data/repositories/line_repository_impl.dart';
import '../../data/repositories/tracking_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';

// Domain Layer
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/bus_repository.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../domain/repositories/eta_repository.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../../domain/repositories/line_repository.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/request_password_reset_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/bus/add_bus_photo_usecase.dart';
import '../../domain/usecases/bus/add_bus_usecase.dart';
import '../../domain/usecases/bus/get_bus_details_usecase.dart';
import '../../domain/usecases/bus/get_driver_buses_usecase.dart';
import '../../domain/usecases/bus/update_bus_usecase.dart';
import '../../domain/usecases/driver/get_driver_profile_usecase.dart';
import '../../domain/usecases/driver/update_driver_details_usecase.dart';
import '../../domain/usecases/eta/get_etas_for_line_usecase.dart';
import '../../domain/usecases/eta/get_etas_for_stop_usecase.dart';
import '../../domain/usecases/eta/subscribe_eta_notifications_usecase.dart';
import '../../domain/usecases/favorite/add_favorite_line_usecase.dart';
import '../../domain/usecases/favorite/get_favorite_lines_usecase.dart';
import '../../domain/usecases/favorite/remove_favorite_line_usecase.dart';
import '../../domain/usecases/favorite/update_favorite_threshold_usecase.dart';
import '../../domain/usecases/feedback/submit_abuse_report_usecase.dart';
import '../../domain/usecases/feedback/submit_feedback_usecase.dart';
import '../../domain/usecases/line/get_buses_for_line_usecase.dart';
import '../../domain/usecases/line/get_line_details_usecase.dart';
import '../../domain/usecases/line/get_lines_for_stop_usecase.dart';
import '../../domain/usecases/line/get_lines_usecase.dart';
import '../../domain/usecases/line/get_stops_for_line_usecase.dart';
import '../../domain/usecases/stop/get_nearest_stops_usecase.dart';
import '../../domain/usecases/stop/get_stop_details_usecase.dart';
import '../../domain/usecases/stop/search_stops_usecase.dart';
import '../../domain/usecases/tracking/get_active_tracking_session_usecase.dart';
import '../../domain/usecases/tracking/pause_tracking_session_usecase.dart';
import '../../domain/usecases/tracking/resume_tracking_session_usecase.dart';
import '../../domain/usecases/tracking/send_batch_location_updates_usecase.dart';
import '../../domain/usecases/tracking/send_location_update_usecase.dart';
import '../../domain/usecases/tracking/start_tracking_session_usecase.dart';
import '../../domain/usecases/tracking/stop_tracking_session_usecase.dart';
import '../../domain/usecases/user/change_password_usecase.dart';
import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/user/update_fcm_token_usecase.dart';
import '../../domain/usecases/user/update_user_profile_usecase.dart';
import '../../domain/usecases/base_usecase.dart';

// Presentation Layer
import '../../presentation/blocs/app_settings/app_settings_cubit.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/bus_tracking/bus_tracking_bloc.dart';
import '../../presentation/blocs/change_password/change_password_cubit.dart';
import '../../presentation/blocs/driver_bus/driver_bus_bloc.dart';
import '../../presentation/blocs/driver_dashboard/driver_dashboard_bloc.dart';
import '../../presentation/blocs/driver_profile/driver_profile_bloc.dart';
import '../../presentation/blocs/favorites/favorites_bloc.dart';
import '../../presentation/blocs/feedback/feedback_bloc.dart';
import '../../presentation/blocs/forgot_password/forgot_password_cubit.dart';
import '../../presentation/blocs/line_details/line_details_bloc.dart';
import '../../presentation/blocs/line_list/line_list_bloc.dart';
import '../../presentation/blocs/notification_list/notification_list_bloc.dart';
import '../../presentation/blocs/registration/registration_cubit.dart';
import '../../presentation/blocs/reset_password/reset_password_cubit.dart';
import '../../presentation/blocs/stop_details/stop_details_bloc.dart';
import '../../presentation/blocs/tracking_control/tracking_control_bloc.dart';
import '../../presentation/blocs/user_profile_edit/user_profile_edit_cubit.dart';
import '../utils/logger.dart';

// Mock implementation of NotificationService
class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    Log.i('Initializing Mock NotificationService...');
  }

  @override
  Future<String?> getFcmToken() async => null;

  @override
  Stream<ReceivedNotification> get notificationStream =>
      Stream<ReceivedNotification>.empty();

  @override
  Future<void> checkInitialMessage() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}

  @override
  Future<void> triggerBackendTokenUpdate(String token) async {}

  @override
  Future<String?> scheduleETANotification({
    required String stopId,
    required String stopName,
    required String lineId,
    required String lineName,
    required String busId,
    required String busMatricule,
    required DateTime estimatedArrivalTime,
    required int minutesBefore,
  }) async => null;

  @override
  Future<void> cancelNotification(String notificationId) async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  void dispose() {}
}

// Create a global instance of GetIt service locator
final GetIt sl = GetIt.instance;

/// Initializes the service locator and registers all dependencies.
/// Now with proper Firebase error handling.
Future<void> setupLocator() async {
  Log.i("Starting Service Locator setup...");

  try {
    // --- EXTERNAL ---
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
    sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
    sl.registerLazySingleton<Connectivity>(() => Connectivity());

    // --- CORE ---
    sl.registerSingleton<AppConfig>(AppConfig());
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Connectivity>()));
    sl.registerLazySingleton<StorageService>(() => StorageServiceImpl(
      prefs: sl<SharedPreferences>(),
      secureStorage: sl<FlutterSecureStorage>(),
    ));

    // Register ApiInterceptor BEFORE Dio
    sl.registerLazySingleton<ApiInterceptor>(() => ApiInterceptor(
        sl<NetworkInfo>(),
        sl<StorageService>()
    ));

    // Register Dio AFTER ApiInterceptor
    sl.registerLazySingleton<Dio>(() {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeoutMs),
        headers: {
          ApiConstants.acceptHeader: ApiConstants.jsonContentType,
        },
      ));
      dio.interceptors.add(sl<ApiInterceptor>());
      if (kDebugMode) {
        dio.interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ));
      }
      return dio;
    });

    // Register ApiClient AFTER Dio
    sl.registerLazySingleton<ApiClient>(() => ApiClientImpl(sl<Dio>()));

    // Register LocationService
    sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());

    // FIREBASE HANDLING - Check if Firebase is initialized before registering
    bool firebaseAvailable = false;
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isNotEmpty) {
        firebaseAvailable = true;
        Log.i("Firebase is available and initialized");

        // Only register real Firebase services if available
        sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
        sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(() => FlutterLocalNotificationsPlugin());
        sl.registerLazySingleton<NotificationService>(() => NotificationServiceImpl(
          firebaseMessaging: sl<FirebaseMessaging>(),
          localNotifications: sl<FlutterLocalNotificationsPlugin>(),
        ));
      } else {
        throw Exception("Firebase not initialized");
      }
    } catch (e) {
      // Firebase is not available or not initialized properly
      Log.w("Firebase is not properly initialized - using mock implementations", error: e);
      firebaseAvailable = false;

      // Register mock services
      sl.registerLazySingleton<NotificationService>(() => MockNotificationService());
    }

    // Register OfflineSyncService
    try {
      sl.registerLazySingleton<OfflineSyncService>(() => OfflineSyncServiceImpl(
        storageService: sl<StorageService>(),
        apiClient: sl<ApiClient>(),
        networkInfo: sl<NetworkInfo>(),
      ));
    } catch (e) {
      Log.e("Error registering OfflineSyncService", error: e);
    }

    // Register all other services
    registerDataSources();
    registerRepositories();
    registerUseCases();
    registerBlocs();

    Log.i("All remaining services registered successfully");
    Log.i("Service Locator setup complete.");
  } catch (e, stackTrace) {
    Log.e("Error during Service Locator setup", error: e, stackTrace: stackTrace);
    // Don't throw the error - allow app to continue with partial initialization
  }
}

// Split registration into separate functions for better error handling
void registerDataSources() {
  try {
    // Data Sources (Local)
    sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(storageService: sl<StorageService>()));
    sl.registerLazySingleton<CacheLocalDataSource>(() => CacheLocalDataSourceImpl(storageService: sl<StorageService>()));
    sl.registerLazySingleton<OfflineLocalDataSource>(() => OfflineLocalDataSourceImpl(storageService: sl<StorageService>()));

    // Data Sources (Remote)
    sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()));
    sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(apiClient: sl<ApiClient>()));
    sl.registerLazySingleton<DriverRemoteDataSource>(() => DriverRemoteDataSourceImpl(apiClient: sl<ApiClient>()));
    sl.registerLazySingleton<BusRemoteDataSource>(() => BusRemoteDataSourceImpl(apiClient: sl<ApiClient>()));
    sl.registerLazySingleton<LineRemoteDataSource>(() => LineRemoteDataSourceImpl(apiClient: sl<ApiClient>()));
    sl.registerLazySingleton<TrackingRemoteDataSource>(() => TrackingRemoteDataSourceImpl(apiClient: sl<ApiClient>()));
    sl.registerLazySingleton<EtaRemoteDataSource>(() => EtaRemoteDataSourceImpl(apiClient: sl<ApiClient>()));
    sl.registerLazySingleton<FeedbackRemoteDataSource>(() => FeedbackRemoteDataSourceImpl(apiClient: sl<ApiClient>()));
    sl.registerLazySingleton<FavoriteRemoteDataSource>(() => FavoriteRemoteDataSourceImpl(apiClient: sl<ApiClient>()));

    Log.d("Data sources registered successfully");
  } catch (e, stackTrace) {
    Log.e("Error registering data sources", error: e, stackTrace: stackTrace);
  }
}

void registerRepositories() {
  try {
    // Repositories
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ));
    sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
      remoteDataSource: sl<UserRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ));
    sl.registerLazySingleton<DriverRepository>(() => DriverRepositoryImpl(
      remoteDataSource: sl<DriverRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ));
    sl.registerLazySingleton<BusRepository>(() => BusRepositoryImpl(
      remoteDataSource: sl<BusRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ));
    sl.registerLazySingleton<LineRepository>(() => LineRepositoryImpl(
      remoteDataSource: sl<LineRemoteDataSource>(),
      localDataSource: sl<CacheLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ));
    sl.registerLazySingleton<TrackingRepository>(() => TrackingRepositoryImpl(
      remoteDataSource: sl<TrackingRemoteDataSource>(),
      offlineSyncService: sl<OfflineSyncService>(),
      networkInfo: sl<NetworkInfo>(),
    ));
    sl.registerLazySingleton<EtaRepository>(() => EtaRepositoryImpl(
      remoteDataSource: sl<EtaRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ));
    sl.registerLazySingleton<FavoriteRepository>(() => FavoriteRepositoryImpl(
      remoteDataSource: sl<FavoriteRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ));
    sl.registerLazySingleton<FeedbackRepository>(() => FeedbackRepositoryImpl(
      remoteDataSource: sl<FeedbackRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ));

    Log.d("Repositories registered successfully");
  } catch (e, stackTrace) {
    Log.e("Error registering repositories", error: e, stackTrace: stackTrace);
  }
}

void registerUseCases() {
  try {
    // Use Cases
    sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => GetUserProfileUseCase(sl<UserRepository>()));
    sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl<UserRepository>()));
    sl.registerLazySingleton(() => UpdateFcmTokenUseCase(sl<UserRepository>()));
    sl.registerLazySingleton(() => ChangePasswordUseCase(sl<UserRepository>()));
    sl.registerLazySingleton(() => GetDriverProfileUseCase(sl<DriverRepository>()));
    sl.registerLazySingleton(() => UpdateDriverDetailsUseCase(sl<DriverRepository>()));
    sl.registerLazySingleton(() => GetDriverBusesUseCase(sl<BusRepository>()));
    sl.registerLazySingleton(() => GetBusDetailsUseCase(sl<BusRepository>()));
    sl.registerLazySingleton(() => AddBusUseCase(sl<BusRepository>()));
    sl.registerLazySingleton(() => UpdateBusUseCase(sl<BusRepository>()));
    sl.registerLazySingleton(() => AddBusPhotoUseCase(sl<BusRepository>()));
    sl.registerLazySingleton(() => GetLinesUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => GetLineDetailsUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => GetStopsForLineUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => GetBusesForLineUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => GetLinesForStopUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => SearchStopsUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => GetNearestStopsUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => GetStopDetailsUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => StartTrackingSessionUseCase(sl<TrackingRepository>()));
    sl.registerLazySingleton(() => StopTrackingSessionUseCase(sl<TrackingRepository>()));
    sl.registerLazySingleton(() => PauseTrackingSessionUseCase(sl<TrackingRepository>()));
    sl.registerLazySingleton(() => ResumeTrackingSessionUseCase(sl<TrackingRepository>()));
    sl.registerLazySingleton(() => GetActiveTrackingSessionUseCase(sl<TrackingRepository>()));
    sl.registerLazySingleton(() => SendLocationUpdateUseCase(sl<TrackingRepository>()));
    sl.registerLazySingleton(() => SendBatchLocationUpdatesUseCase(sl<TrackingRepository>()));
    sl.registerLazySingleton(() => GetEtasForLineUseCase(sl<EtaRepository>()));
    sl.registerLazySingleton(() => GetEtasForStopUseCase(sl<EtaRepository>()));
    sl.registerLazySingleton(() => SubscribeEtaNotificationsUseCase(sl<NotificationService>()));
    sl.registerLazySingleton(() => AddFavoriteLineUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => RemoveFavoriteLineUseCase(sl<LineRepository>()));
    sl.registerLazySingleton(() => GetFavoriteLinesUseCase(sl<FavoriteRepository>()));
    sl.registerLazySingleton(() => UpdateFavoriteThresholdUseCase(sl<FavoriteRepository>()));
    sl.registerLazySingleton(() => SubmitFeedbackUseCase(sl<FeedbackRepository>()));
    sl.registerLazySingleton(() => SubmitAbuseReportUseCase(sl<FeedbackRepository>()));

    Log.d("Use cases registered successfully");
  } catch (e, stackTrace) {
    Log.e("Error registering use cases", error: e, stackTrace: stackTrace);
  }
}

void registerBlocs() {
  try {
    // Register core BLoCs and Cubits
    sl.registerFactory(() => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      checkAuthStatusUseCase: sl<CheckAuthStatusUseCase>(),
    ));

    sl.registerFactory(() => AppSettingsCubit(storageService: sl<StorageService>()));

    // Notification BLoC needs special handling since it depends on possibly unavailable services
    try {
      sl.registerFactory(() => NotificationListBloc(
        notificationService: sl<NotificationService>(),
        storageService: sl<StorageService>(),
      ));
    } catch (e) {
      Log.w("Failed to register NotificationListBloc, will be created when needed", error: e);
    }

    // Register remaining BLoCs
    sl.registerFactory(() => FavoritesBloc(
      getFavoriteLinesUseCase: sl<GetFavoriteLinesUseCase>(),
      addFavoriteLineUseCase: sl<AddFavoriteLineUseCase>(),
      removeFavoriteLineUseCase: sl<RemoveFavoriteLineUseCase>(),
      updateFavoriteThresholdUseCase: sl<UpdateFavoriteThresholdUseCase>(),
    ));

    sl.registerFactory(() => LineListBloc(getLinesUseCase: sl<GetLinesUseCase>()));

    sl.registerFactory(() => LineDetailsBloc(
      getLineDetailsUseCase: sl<GetLineDetailsUseCase>(),
      getStopsForLineUseCase: sl<GetStopsForLineUseCase>(),
      getBusesForLineUseCase: sl<GetBusesForLineUseCase>(),
      getEtasForLineUseCase: sl<GetEtasForLineUseCase>(),
      lineRepository: sl<LineRepository>(),
    ));

    sl.registerFactory(() => BusTrackingBloc(
      getLinesUseCase: sl<GetLinesUseCase>(),
      getStopsForLineUseCase: sl<GetStopsForLineUseCase>(),
      getBusesForLineUseCase: sl<GetBusesForLineUseCase>(),
      getLineDetailsUseCase: sl<GetLineDetailsUseCase>(),
    ));

    sl.registerFactory(() => DriverDashboardBloc(
      getActiveTrackingSessionUseCase: sl<GetActiveTrackingSessionUseCase>(),
    ));

    sl.registerFactory(() => TrackingControlBloc(
      getActiveTrackingSessionUseCase: sl<GetActiveTrackingSessionUseCase>(),
      startTrackingSessionUseCase: sl<StartTrackingSessionUseCase>(),
      stopTrackingSessionUseCase: sl<StopTrackingSessionUseCase>(),
      pauseTrackingSessionUseCase: sl<PauseTrackingSessionUseCase>(),
      resumeTrackingSessionUseCase: sl<ResumeTrackingSessionUseCase>(),
      locationService: sl<LocationService>(),
    ));

    sl.registerFactory(() => DriverBusBloc(
      getDriverBusesUseCase: sl<GetDriverBusesUseCase>(),
      addBusUseCase: sl<AddBusUseCase>(),
      updateBusUseCase: sl<UpdateBusUseCase>(),
    ));

    sl.registerFactory(() => DriverProfileBloc(
      getDriverProfileUseCase: sl<GetDriverProfileUseCase>(),
      updateDriverDetailsUseCase: sl<UpdateDriverDetailsUseCase>(),
    ));

    sl.registerFactory(() => FeedbackBloc(
      submitFeedbackUseCase: sl<SubmitFeedbackUseCase>(),
      submitAbuseReportUseCase: sl<SubmitAbuseReportUseCase>(),
    ));

    sl.registerFactory(() => RegistrationCubit(registerUseCase: sl<RegisterUseCase>()));
    sl.registerFactory(() => ForgotPasswordCubit(requestPasswordResetUseCase: sl<RequestPasswordResetUseCase>()));
    sl.registerFactory(() => ResetPasswordCubit(resetPasswordUseCase: sl<ResetPasswordUseCase>()));
    sl.registerFactory(() => ChangePasswordCubit(changePasswordUseCase: sl<ChangePasswordUseCase>()));

    sl.registerFactory(() => StopDetailsBloc(
      getStopDetailsUseCase: sl<GetStopDetailsUseCase>(),
      getLinesForStopUseCase: sl<GetLinesForStopUseCase>(),
      getEtasForStopUseCase: sl<GetEtasForStopUseCase>(),
    ));

    sl.registerFactory(() => UserProfileEditCubit(updateUserProfileUseCase: sl<UpdateUserProfileUseCase>()));

    Log.d("BLoCs and Cubits registered successfully");
  } catch (e, stackTrace) {
    Log.e("Error registering BLoCs and Cubits", error: e, stackTrace: stackTrace);
  }
}