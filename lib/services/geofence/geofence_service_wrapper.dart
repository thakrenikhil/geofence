import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class GeofenceServiceWrapper {
  GeofenceServiceWrapper({
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusMeters,
  });

  final double centerLatitude;
  final double centerLongitude;
  final double radiusMeters;

  final StreamController<bool> _insideFenceController =
      StreamController<bool>.broadcast();
  Stream<bool> get onFenceStateChanged => _insideFenceController.stream;

  StreamSubscription<Position>? _positionSub;
  bool? _lastInside;

  Future<void> start() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Emit initial position state to avoid waiting for first stream sample
    try {
      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final initialInside = _isInside(current.latitude, current.longitude);
      _lastInside = initialInside;
      _insideFenceController.add(initialInside);
    } catch (_) {}

    _positionSub?.cancel();
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 1,
          ),
        ).listen((pos) {
          final inside = _isInside(pos.latitude, pos.longitude);
          if (_lastInside != inside) {
            _lastInside = inside;
            _insideFenceController.add(inside);
          }
        });
  }

  bool _isInside(double lat, double lng) {
    const double earthRadius = 6371000; // meters
    double dLat = _deg2rad(lat - centerLatitude);
    double dLon = _deg2rad(lng - centerLongitude);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(centerLatitude)) *
            cos(_deg2rad(lat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance <= radiusMeters;
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);

  Future<void> stop() async {
    await _positionSub?.cancel();
    await _insideFenceController.close();
  }
}
