/// lib/domain/usecases/eta/subscribe_eta_notifications_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/exceptions/app_exceptions.dart'; // Import specific exception type
import '../../../core/services/notification_service.dart'; // Import NotificationService
import '../base_usecase.dart';

/// Use Case for scheduling a local notification for an upcoming bus arrival (ETA).
///
/// This class encapsulates the business logic required to schedule a reminder
/// notification via the [NotificationService] based on provided ETA details.
class SubscribeEtaNotificationsUseCase
    implements UseCase<String?, SubscribeEtaNotificationsParams> {
  // Note: Returns String? representing the scheduled notification ID if successful.

  /// The service responsible for handling notification scheduling.
  final NotificationService notificationService;

  /// Creates a [SubscribeEtaNotificationsUseCase] instance that requires a [NotificationService].
  const SubscribeEtaNotificationsUseCase(this.notificationService);

  /// Executes the logic to schedule an ETA notification.
  ///
  /// Takes [SubscribeEtaNotificationsParams] containing all necessary details
  /// about the ETA event, calls the notificationService's scheduleETANotification method,
  /// and returns the result.
  /// The result is an [Either] type, containing a [Failure] on error
  /// or the scheduled notification ID String (nullable) on success. A null ID might
  /// indicate scheduling wasn't possible (e.g., time in the past).
  @override
  Future<Either<Failure, String?>> call(
      SubscribeEtaNotificationsParams params) async {
    try {
      final notificationId = await notificationService.scheduleETANotification(
        stopId: params.stopId,
        stopName: params.stopName,
        lineId: params.lineId,
        lineName: params.lineName,
        busId: params.busId,
        busMatricule: params.busMatricule,
        estimatedArrivalTime: params.estimatedArrivalTime,
        minutesBefore: params.minutesBefore,
      );
      // Return the ID (which could be null if scheduling failed or wasn't needed by service)
      return Right(notificationId);
    } on NotificationException catch (e) { // CORRECTED: Catch specific exception
      // Map specific notification exceptions to a specific Failure
      return Left(NotificationFailure(message: e.message, code: e.code)); // CORRECTED: Use concrete Failure
    } catch (e) {
      // Catch any other unexpected errors
      // CORRECTED: Use concrete UnexpectedFailure
      return Left(UnexpectedFailure(
          message: 'Failed to schedule ETA notification: ${e.toString()}'));
    }
  }
}

/// Parameters required for the [SubscribeEtaNotificationsUseCase].
///
/// Contains all the details needed by the NotificationService to schedule
/// an ETA reminder notification.
class SubscribeEtaNotificationsParams extends Equatable {
  final String stopId;
  final String stopName; // Needed for notification text
  final String lineId;
  final String lineName; // Needed for notification text
  final String busId;
  final String busMatricule; // Needed for notification text
  final DateTime estimatedArrivalTime;
  final int minutesBefore; // How many minutes before ETA to notify

  /// Creates a [SubscribeEtaNotificationsParams] instance.
  const SubscribeEtaNotificationsParams({
    required this.stopId,
    required this.stopName,
    required this.lineId,
    required this.lineName,
    required this.busId,
    required this.busMatricule,
    required this.estimatedArrivalTime,
    required this.minutesBefore,
  });

  @override
  List<Object?> get props => [
    stopId,
    stopName,
    lineId,
    lineName,
    busId,
    busMatricule,
    estimatedArrivalTime,
    minutesBefore,
  ];
}