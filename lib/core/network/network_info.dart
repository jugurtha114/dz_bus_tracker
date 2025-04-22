/// lib/core/network/network_info.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart'; // For logging changes

/// Abstract interface for retrieving network connectivity information.
abstract class NetworkInfo {
  /// Checks if the device is currently connected to any network (WiFi or Mobile).
  Future<bool> get isConnected;

  /// Gets the current specific connectivity result (WiFi, Mobile, None, etc.).
  /// Returns the most relevant connection type if multiple are active.
  Future<ConnectivityResult> get connectivityResult;

  /// A stream that emits a **list** of [ConnectivityResult]s whenever the
  /// connection status changes. The list contains all active connection types.
  /// It emits reliably on all platforms except for Linux. Use [connectivityResult]
  /// or [isConnected] for single-point-in-time checks.
  Stream<List<ConnectivityResult>> get onConnectivityChanged; // CORRECTED Return Type

  /// Attempts to determine if the current connection might be low bandwidth.
  /// Note: This is often unreliable. Checks if mobile is the *only* connection.
  Future<bool> get isPotentiallyLowBandwidth;
}

/// Implementation of [NetworkInfo] using the `connectivity_plus` package.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription; // CORRECTED Stream Type
  List<ConnectivityResult> _lastResultList = const [ConnectivityResult.none]; // Store last known list

  NetworkInfoImpl(this._connectivity) {
    // Initialize last known result and start listening immediately
    _connectivity.checkConnectivity().then((result) {
      // checkConnectivity now also returns a List<ConnectivityResult>
      _lastResultList = result;
      Log.d('Initial connectivity status: $_lastResultList');
    });
    _listenToChanges();
  }

  /// Starts listening to connectivity changes and logs them.
  void _listenToChanges() {
    _subscription?.cancel(); // Cancel previous listener if any
    _subscription = _connectivity.onConnectivityChanged.listen(
            (List<ConnectivityResult> resultList) { // CORRECTED: Handle list
          Log.i('Network Connectivity changed: $resultList');
          _lastResultList = resultList;
        }, onError: (error) {
      Log.e('Error listening to connectivity status', error: error);
    });
  }

  @override
  Future<bool> get isConnected async {
    final resultList = await _connectivity.checkConnectivity();
    _lastResultList = resultList;
    // Consider connected if the list is not empty and doesn't contain *only* none.
    return resultList.isNotEmpty && !resultList.contains(ConnectivityResult.none);
  }

  @override
  Future<ConnectivityResult> get connectivityResult async {
    _lastResultList = await _connectivity.checkConnectivity();
    // Determine the 'best' or most relevant connection type from the list.
    // Prioritize Ethernet > WiFi > Mobile > Other > None. VPN is tricky.
    if (_lastResultList.contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    } else if (_lastResultList.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    } else if (_lastResultList.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    } else if (_lastResultList.contains(ConnectivityResult.vpn)) {
      // VPN usually runs over another connection, report the underlying if possible?
      // Or report VPN? Let's report VPN if present.
      return ConnectivityResult.vpn;
    } else if (_lastResultList.contains(ConnectivityResult.bluetooth)) {
      return ConnectivityResult.bluetooth; // Less common for general internet
    } else if (_lastResultList.contains(ConnectivityResult.other)) {
      return ConnectivityResult.other;
    } else {
      return ConnectivityResult.none;
    }
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged { // CORRECTED Return Type
    if (_subscription == null) {
      _listenToChanges(); // Ensure listener is active
    }
    return _connectivity.onConnectivityChanged;
  }

  @override
  Future<bool> get isPotentiallyLowBandwidth async {
    final resultList = await _connectivity.checkConnectivity();
    _lastResultList = resultList;
    // Consider low bandwidth only if the *sole* connection is mobile.
    // This is still a very rough estimate.
    return resultList.length == 1 && resultList.first == ConnectivityResult.mobile;
  }

  /// Call this method if the NetworkInfoImpl instance needs to be disposed.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    Log.d('NetworkInfo listener disposed.');
  }
}