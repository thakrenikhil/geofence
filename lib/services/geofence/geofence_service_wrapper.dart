import 'dart:async';

// Placeholder for geofencing integration. Replace with actual package integration.
class GeofenceServiceWrapper {
  final StreamController<bool> _insideFenceController = StreamController<bool>.broadcast();

  Stream<bool> get onFenceStateChanged => _insideFenceController.stream;

  Future<void> start() async {
    // TODO: Initialize geofencing and emit events
  }

  Future<void> stop() async {
    await _insideFenceController.close();
  }
}


