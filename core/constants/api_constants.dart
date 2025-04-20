/// lib/core/constants/api_constants.dart

import '../../config/app_config.dart'; // To get the base URL
import 'app_constants.dart'; // For default timeout

/// Contains constants related to the backend API configuration and endpoints.
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // --- Base Configuration ---
  static final String baseUrl = AppConfig.apiBaseUrl; // Base URL from AppConfig
  static const String apiVersionPath = '/api/v1'; // API version prefix
  static final String baseApiUrl = '$baseUrl$apiVersionPath'; // Full base API URL

  // --- Timeouts ---
  static const int connectTimeoutMs = AppConstants.defaultApiTimeoutMs;
  static const int receiveTimeoutMs = AppConstants.defaultApiTimeoutMs;
  static const int sendTimeoutMs = AppConstants.defaultApiTimeoutMs;

  // --- Headers ---
  static const String acceptHeader = 'Accept';
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String msgpackContentType = 'application/x-msgpack'; // Or application/msgpack
  static const String jsonContentType = 'application/json';
  static const String formUrlEncodedContentType = 'application/x-www-form-urlencoded';
  static const String multipartFormDataContentType = 'multipart/form-data';


  // --- Authentication Endpoints ---
  static final String login = '$baseApiUrl/login/'; // [cite: 532]
  static final String register = '$baseApiUrl/users/'; // POST to users for registration [cite: 704]
  static final String refreshToken = '$baseApiUrl/token/refresh/'; // [cite: 625]
  static final String resetPasswordRequest = '$baseApiUrl/users/reset_password_request/'; // [cite: 746]
  static final String resetPassword = '$baseApiUrl/users/reset_password/'; // [cite: 743]
  static final String changePassword = '$baseApiUrl/users/change_password/'; // [cite: 720]
  static final String verifyEmail = '$baseApiUrl/users/verify_email/'; // [cite: 752]
  static final String resendVerificationEmail = '$baseApiUrl/users/resend_verification_email/'; // [cite: 740]
  static final String verifyPhone = '$baseApiUrl/users/verify_phone/'; // [cite: 755]
  static final String sendPhoneVerification = '$baseApiUrl/users/send_phone_verification/'; // [cite: 749]

  // --- User Endpoints ---
  static final String users = '$baseApiUrl/users/'; // List/Create Users [cite: 698, 704]
  static String userDetail(String userId) => '$baseApiUrl/users/$userId/'; // Retrieve/Update/Delete User [cite: 707, 710, 714, 718]
  static final String userProfile = '$baseApiUrl/users/profile/'; // Get/Update Current User Profile [cite: 732, 734, 737]
  static final String userNotificationPreferences = '$baseApiUrl/users/notification_preferences/'; // Update prefs [cite: 726, 729]
  static final String userFcmToken = '$baseApiUrl/users/fcm_token/'; // Update FCM Token [cite: 723]

  // --- Driver Endpoints ---
  static final String drivers = '$baseApiUrl/drivers/'; // List/Create Drivers [cite: 200, 207]
  static String driverDetail(String driverId) => '$baseApiUrl/drivers/$driverId/'; // Retrieve/Update/Delete Driver [cite: 210, 213, 217, 221]
  static final String driverProfileMe = '$baseApiUrl/drivers/me/'; // Get Current Driver Profile [cite: 245]
  static String driverDeactivate(String driverId) => '$baseApiUrl/drivers/$driverId/deactivate/'; // [cite: 223]
  static String driverReactivate(String driverId) => '$baseApiUrl/drivers/$driverId/reactivate/'; // [cite: 234]
  static String driverRate(String driverId) => '$baseApiUrl/drivers/$driverId/rate/'; // POST Rating [cite: 227]
  static String driverRatings(String driverId) => '$baseApiUrl/drivers/$driverId/ratings/'; // GET Ratings [cite: 231]
  static String driverStats(String driverId) => '$baseApiUrl/drivers/$driverId/stats/'; // [cite: 238]
  static String driverVerify(String driverId) => '$baseApiUrl/drivers/$driverId/verify/'; // [cite: 241]
  static final String driversPendingVerification = '$baseApiUrl/drivers/pending_verification/'; // [cite: 247]

  // --- Driver Application Endpoints ---
  static final String driverApplications = '$baseApiUrl/driver-applications/'; // List/Create [cite: 156, 162]
  static String driverApplicationDetail(String appId) => '$baseApiUrl/driver-applications/$appId/'; // Retrieve/Update/Delete [cite: 165, 168, 172, 176]

  // --- Driver Rating Endpoints ---
  static final String driverRatingsBase = '$baseApiUrl/driver-ratings/'; // List/Create [cite: 178, 184]
  static String driverRatingDetail(String ratingId) => '$baseApiUrl/driver-ratings/$ratingId/'; // Retrieve/Update/Delete [cite: 187, 190, 194, 198]

  // --- Bus Endpoints ---
  static final String buses = '$baseApiUrl/buses/'; // List/Create Buses [cite: 103, 110]
  static String busDetail(String busId) => '$baseApiUrl/buses/$busId/'; // Retrieve/Update/Delete Bus [cite: 113, 116, 120, 124]
  static String busAddPhoto(String busId) => '$baseApiUrl/buses/$busId/add_photo/'; // [cite: 126]
  static String busPhotos(String busId) => '$baseApiUrl/buses/$busId/photos/'; // GET Photos [cite: 138]
  static String busDeactivate(String busId) => '$baseApiUrl/buses/$busId/deactivate/'; // [cite: 130]
  static String busReactivate(String busId) => '$baseApiUrl/buses/$busId/reactivate/'; // [cite: 141]
  static String busMaintenance(String busId) => '$baseApiUrl/buses/$busId/maintenance/'; // POST Maintenance [cite: 134]
  static String busStatus(String busId) => '$baseApiUrl/buses/$busId/status/'; // GET Status [cite: 145]
  static String busVerify(String busId) => '$baseApiUrl/buses/$busId/verify/'; // POST Verification Action [cite: 148]
  static final String busesForDriver = '$baseApiUrl/buses/for_driver/'; // [cite: 152]
  static final String busesPendingVerification = '$baseApiUrl/buses/pending_verification/'; // [cite: 154]

  // --- Bus Photo Endpoints ---
  static final String busPhotosBase = '$baseApiUrl/bus-photos/'; // List/Create [cite: 59, 65]
  static String busPhotoDetail(String photoId) => '$baseApiUrl/bus-photos/$photoId/'; // Retrieve/Update/Delete [cite: 68, 71, 75, 79]

  // --- Bus Maintenance Endpoints ---
  static final String busMaintenances = '$baseApiUrl/bus-maintenances/'; // List/Create [cite: 37, 43]
  static String busMaintenanceDetail(String maintenanceId) => '$baseApiUrl/bus-maintenances/$maintenanceId/'; // Retrieve/Update/Delete [cite: 46, 49, 53, 57]

  // --- Bus Verification Endpoints ---
  static final String busVerifications = '$baseApiUrl/bus-verifications/'; // List/Create [cite: 81, 87]
  static String busVerificationDetail(String verificationId) => '$baseApiUrl/bus-verifications/$verificationId/'; // Retrieve/Update/Delete [cite: 90, 93, 97, 101]

  // --- Line Endpoints ---
  static final String lines = '$baseApiUrl/lines/'; // List/Create Lines [cite: 430, 436]
  static String lineDetail(String lineId) => '$baseApiUrl/lines/$lineId/'; // Retrieve/Update/Delete Line [cite: 439, 442, 446, 450]
  static String lineAddBus(String lineId) => '$baseApiUrl/lines/$lineId/add_bus/'; // [cite: 452]
  static String lineRemoveBus(String lineId) => '$baseApiUrl/lines/$lineId/remove_bus/'; // [cite: 478]
  static String lineAddStop(String lineId) => '$baseApiUrl/lines/$lineId/add_stop/'; // [cite: 456]
  static String lineRemoveStop(String lineId) => '$baseApiUrl/lines/$lineId/remove_stop/'; // [cite: 482]
  static String lineReorderStops(String lineId) => '$baseApiUrl/lines/$lineId/reorder_stops/'; // [cite: 486]
  static String lineBuses(String lineId) => '$baseApiUrl/lines/$lineId/buses/'; // GET Buses for Line [cite: 460]
  static String lineStops(String lineId) => '$baseApiUrl/lines/$lineId/stops/'; // GET Stops for Line [cite: 493]
  static String lineCalculateDistances(String lineId) => '$baseApiUrl/lines/$lineId/calculate_distances/'; // [cite: 463]
  static String lineCalculatePath(String lineId) => '$baseApiUrl/lines/$lineId/calculate_path/'; // [cite: 467]
  static String lineFavorite(String lineId) => '$baseApiUrl/lines/$lineId/favorite/'; // [cite: 471]
  static String lineUnfavorite(String lineId) => '$baseApiUrl/lines/$lineId/unfavorite/'; // [cite: 496]
  static String lineIsFavorite(String lineId) => '$baseApiUrl/lines/$lineId/is_favorite/'; // [cite: 475]
  static String lineStatus(String lineId) => '$baseApiUrl/lines/$lineId/status/'; // [cite: 490]
  static final String linesActive = '$baseApiUrl/lines/active/'; // [cite: 500]
  static final String linesConnecting = '$baseApiUrl/lines/connecting/'; // [cite: 502]
  static final String linesForStop = '$baseApiUrl/lines/for_stop/'; // Requires query param [cite: 504]
  static final String linesSearch = '$baseApiUrl/lines/search/'; // Requires query param [cite: 506]
  static final String linesWithActiveBuses = '$baseApiUrl/lines/with_active_buses/'; // [cite: 508]

  // --- LineBus (Association) Endpoints ---
  static final String lineBusesAssociation = '$baseApiUrl/line-buses/'; // List/Create [cite: 386, 392]
  static String lineBusDetail(String assocId) => '$baseApiUrl/line-buses/$assocId/'; // Retrieve/Update/Delete [cite: 395, 398, 402, 406]

  // --- Stop Endpoints ---
  static final String stops = '$baseApiUrl/stops/'; // List/Create Stops [cite: 596, 602]
  static String stopDetail(String stopId) => '$baseApiUrl/stops/$stopId/'; // Retrieve/Update/Delete Stop [cite: 605, 608, 612, 616]
  static String stopLines(String stopId) => '$baseApiUrl/stops/$stopId/lines/'; // GET Lines serving Stop [cite: 618]
  static final String stopsNearest = '$baseApiUrl/stops/nearest/'; // Requires query params (lat, lon) [cite: 621]
  static final String stopsSearch = '$baseApiUrl/stops/search/'; // Requires query param [cite: 623]

  // --- LineStop (Association) Endpoints ---
  static final String lineStopsAssociation = '$baseApiUrl/line-stops/'; // List/Create [cite: 408, 414]
  static String lineStopDetail(String assocId) => '$baseApiUrl/line-stops/$assocId/'; // Retrieve/Update/Delete [cite: 417, 420, 424, 428]

  // --- Tracking Session Endpoints ---
  static final String trackingSessions = '$baseApiUrl/tracking-sessions/'; // List/Create [cite: 650, 656]
  static String trackingSessionDetail(String sessionId) => '$baseApiUrl/tracking-sessions/$sessionId/'; // Retrieve/Update/Delete [cite: 659, 662, 666, 670]
  static final String trackingSessionStart = '$baseApiUrl/tracking-sessions/start_tracking/'; // [cite: 695]
  static String trackingSessionEnd(String sessionId) => '$baseApiUrl/tracking-sessions/$sessionId/end_tracking/'; // [cite: 675]
  static String trackingSessionPause(String sessionId) => '$baseApiUrl/tracking-sessions/$sessionId/pause_tracking/'; // [cite: 685]
  static String trackingSessionResume(String sessionId) => '$baseApiUrl/tracking-sessions/$sessionId/resume_tracking/'; // [cite: 689]
  static String trackingSessionLocationUpdates(String sessionId) => '$baseApiUrl/tracking-sessions/$sessionId/location_updates/'; // GET Updates [cite: 679]
  static String trackingSessionLogs(String sessionId) => '$baseApiUrl/tracking-sessions/$sessionId/logs/'; // GET Logs [cite: 682]
  static String trackingSessionCurrentLocation(String sessionId) => '$baseApiUrl/tracking-sessions/$sessionId/current_location/'; // GET Last Location [cite: 672]
  static final String trackingSessionsActive = '$baseApiUrl/tracking-sessions/active/'; // GET Active Sessions [cite: 693]

  // --- Location Update Endpoints ---
  static final String locationUpdates = '$baseApiUrl/location-updates/'; // List/Create Single Update [cite: 510, 516]
  static String locationUpdateDetail(String updateId) => '$baseApiUrl/location-updates/$updateId/'; // Retrieve/Update/Delete [cite: 519, 522, 526, 530]
  static final String batchLocationUpdate = '$baseApiUrl/batch-location-update/'; // POST Batch Updates [cite: 34]

  // --- Offline Batch Endpoints ---
  static final String offlineBatches = '$baseApiUrl/offline-batches/'; // List/Create Offline Batch [cite: 535, 541]
  static String offlineBatchDetail(String batchId) => '$baseApiUrl/offline-batches/$batchId/'; // Retrieve/Update/Delete [cite: 544, 547, 551, 555]
  static String offlineBatchProcess(String batchId) => '$baseApiUrl/offline-batches/$batchId/process/'; // POST to process [cite: 557]

  // --- ETA Endpoints ---
  static final String etas = '$baseApiUrl/etas/'; // List/Create ETA (manual?) [cite: 278, 284]
  static String etaDetail(String etaId) => '$baseApiUrl/etas/$etaId/'; // Retrieve/Update/Delete ETA [cite: 287, 290, 294, 298]
  static final String etaCalculate = '$baseApiUrl/etas/calculate/'; // POST to calculate [cite: 300]
  static final String etaRecalculateLine = '$baseApiUrl/etas/recalculate_line/'; // POST to recalc line [cite: 312]
  static final String etaDelayed = '$baseApiUrl/etas/delayed/'; // GET delayed ETAs [cite: 303]
  static final String etaForBus = '$baseApiUrl/etas/for_bus/'; // GET ETAs for a bus (needs query) [cite: 305]
  static final String etaForLine = '$baseApiUrl/etas/for_line/'; // GET ETAs for a line (needs query) [cite: 307]
  static final String etaForStop = '$baseApiUrl/etas/for_stop/'; // GET ETAs for a stop (needs query) [cite: 309]
  static final String etaNextArrivals = '$baseApiUrl/etas/next_arrivals/'; // GET next arrivals (needs query) [cite: 311]

  // --- ETA Notification Endpoints ---
  static final String etaNotifications = '$baseApiUrl/eta-notifications/'; // List/Create [cite: 249, 255]
  static String etaNotificationDetail(String notifId) => '$baseApiUrl/eta-notifications/$notifId/'; // Retrieve/Update/Delete [cite: 258, 261, 265, 269]
  static final String etaNotificationsPending = '$baseApiUrl/eta-notifications/pending/'; // GET pending [cite: 271]
  static final String etaNotificationsSent = '$baseApiUrl/eta-notifications/sent/'; // GET sent [cite: 276]
  static final String etaNotificationsSendPending = '$baseApiUrl/eta-notifications/send_pending/'; // POST to send [cite: 273]

  // --- Favorite Endpoints ---
  static final String favorites = '$baseApiUrl/favorites/'; // List/Create Favorites [cite: 316, 322]
  static String favoriteDetail(String favId) => '$baseApiUrl/favorites/$favId/'; // Retrieve/Update/Delete Fav [cite: 325, 328, 332, 336]
  static String favoriteUpdateThreshold(String favId) => '$baseApiUrl/favorites/$favId/update_threshold/'; // POST [cite: 338]

  // --- Feedback Endpoints ---
  static final String feedback = '$baseApiUrl/feedback/'; // List/Create Feedback [cite: 342, 348]
  static String feedbackDetail(String feedbackId) => '$baseApiUrl/feedback/$feedbackId/'; // Retrieve/Update/Delete [cite: 351, 354, 358, 362]
  static String feedbackAssign(String feedbackId) => '$baseApiUrl/feedback/$feedbackId/assign/'; // [cite: 364]
  static String feedbackRespond(String feedbackId) => '$baseApiUrl/feedback/$feedbackId/respond/'; // [cite: 368]
  static final String feedbackByStatus = '$baseApiUrl/feedback/by_status/'; // [cite: 372]
  static final String feedbackMyAssigned = '$baseApiUrl/feedback/my_assigned/'; // [cite: 374]
  static final String feedbackMyFeedback = '$baseApiUrl/feedback/my_feedback/'; // [cite: 376]
  static final String feedbackPending = '$baseApiUrl/feedback/pending/'; // [cite: 378]
  static final String feedbackSearch = '$baseApiUrl/feedback/search/'; // [cite: 380]
  static final String feedbackStatistics = '$baseApiUrl/feedback/statistics/'; // [cite: 382]
  static final String feedbackUnassigned = '$baseApiUrl/feedback/unassigned/'; // [cite: 384]

  // --- Abuse Report Endpoints ---
  static final String abuseReports = '$baseApiUrl/abuse-reports/'; // List/Create [cite: 1, 8]
  static String abuseReportDetail(String reportId) => '$baseApiUrl/abuse-reports/$reportId/'; // Retrieve/Update/Delete [cite: 11, 14, 18, 22]
  static String abuseReportResolve(String reportId) => '$baseApiUrl/abuse-reports/$reportId/resolve/'; // POST [cite: 24]
  static final String abuseReportsByStatus = '$baseApiUrl/abuse-reports/by_status/'; // [cite: 28]
  static final String abuseReportsMyReports = '$baseApiUrl/abuse-reports/my_reports/'; // [cite: 30]
  static final String abuseReportsUnresolved = '$baseApiUrl/abuse-reports/unresolved/'; // [cite: 32]

  // --- Stop Arrival Endpoints ---
  static final String stopArrivals = '$baseApiUrl/stop-arrivals/'; // List/Create [cite: 561, 567]
  static String stopArrivalDetail(String arrivalId) => '$baseApiUrl/stop-arrivals/$arrivalId/'; // Retrieve/Update/Delete [cite: 570, 573, 577, 581]
  static String stopArrivalRecordDeparture(String arrivalId) => '$baseApiUrl/stop-arrivals/$arrivalId/record_departure/'; // POST [cite: 583]
  static final String stopArrivalsForBus = '$baseApiUrl/stop-arrivals/for_bus/'; // GET (needs query) [cite: 587]
  static final String stopArrivalsForLine = '$baseApiUrl/stop-arrivals/for_line/'; // GET (needs query) [cite: 589]
  static final String stopArrivalsForStop = '$baseApiUrl/stop-arrivals/for_stop/'; // GET (needs query) [cite: 591]
  static final String stopArrivalsRecordArrival = '$baseApiUrl/stop-arrivals/record_arrival/'; // POST [cite: 593]

  // --- Tracking Log Endpoints ---
  static final String trackingLogs = '$baseApiUrl/tracking-logs/'; // List/Create [cite: 628, 634]
  static String trackingLogDetail(String logId) => '$baseApiUrl/tracking-logs/$logId/'; // Retrieve/Update/Delete [cite: 637, 640, 644, 648]

}
