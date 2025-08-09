import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/attendance/attendance_service.dart';
import '../../../services/geofence/geofence_service_wrapper.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  GeofenceServiceWrapper? _geofence;
  bool _inside = false;
  String? _activeRecordId;
  double? _officeLat;
  double? _officeLng;
  double? _officeRadius;
  double? _lastDistance;
  StreamSubscription<Position>? _posSub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final officeSnap = await FirebaseFirestore.instance
        .collection('offices')
        .limit(1)
        .get();
    if (officeSnap.docs.isEmpty) return;
    final office = officeSnap.docs.first.data();
    _officeLat = (office['latitude'] as num).toDouble();
    _officeLng = (office['longitude'] as num).toDouble();
    _officeRadius = (office['radiusMeters'] as num).toDouble();
    _geofence = GeofenceServiceWrapper(
      centerLatitude: _officeLat!,
      centerLongitude: _officeLng!,
      radiusMeters: _officeRadius!,
    );
    await _geofence!.start();
    _geofence!.onFenceStateChanged.listen((inside) async {
      setState(() => _inside = inside);
      if (!inside && _activeRecordId != null) {
        await AttendanceService(
          FirebaseFirestore.instance,
        ).checkOut(recordId: _activeRecordId!);
        setState(() => _activeRecordId = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Checked out on geofence exit')),
          );
        }
      }
    });

    _posSub?.cancel();
    _posSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 1,
          ),
        ).listen((p) {
          if (_officeLat == null || _officeLng == null) return;
          final d = const Distance().as(
            LengthUnit.Meter,
            LatLng(p.latitude, p.longitude),
            LatLng(_officeLat!, _officeLng!),
          );
          setState(() => _lastDistance = d);
        });
  }

  @override
  void dispose() {
    _geofence?.stop();
    _posSub?.cancel();
    super.dispose();
  }

  Future<void> _checkIn() async {
    const double tolerance = 20; // meters buffer for GPS drift
    final canCheckIn =
        _inside ||
        (_lastDistance != null &&
            _officeRadius != null &&
            _lastDistance! <= (_officeRadius! + tolerance));
    if (!canCheckIn) {
      if (mounted) {
        final msg = _lastDistance != null && _officeRadius != null
            ? 'Outside geofence: ${_lastDistance!.toStringAsFixed(1)} m > ${_officeRadius!.toStringAsFixed(0)} m'
            : 'You must be inside the geofence to check in';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      return;
    }
    final user = FirebaseAuth.instance.currentUser!;
    final officeSnap = await FirebaseFirestore.instance
        .collection('offices')
        .limit(1)
        .get();
    if (officeSnap.docs.isEmpty) return;
    final officeId = officeSnap.docs.first.id;
    final id = await AttendanceService(
      FirebaseFirestore.instance,
    ).checkIn(userId: user.uid, officeId: officeId);
    setState(() => _activeRecordId = id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Checked in')));
    }
  }

  Future<void> _manualCheckout() async {
    if (_activeRecordId == null) return;
    await AttendanceService(
      FirebaseFirestore.instance,
    ).checkOut(recordId: _activeRecordId!);
    setState(() => _activeRecordId = null);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Checked out')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit app?'),
            content: const Text('Do you want to close the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.employeeHome),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return _EmployeeHomeInherited(
              inside: _inside,
              child: _EmployeeActions(
                onCheckIn: () => _checkIn(),
                onCheckout: () => _manualCheckout(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _MapCard()),
                            const SizedBox(width: 16),
                            const Expanded(child: _ActionsCard()),
                          ],
                        )
                      : Column(
                          children: [
                            const Expanded(child: _MapCard()),
                            const SizedBox(height: 16),
                            const _ActionsCard(),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox.expand(
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('offices')
              .limit(1)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final office = snapshot.data!.docs.isNotEmpty
                ? snapshot.data!.docs.first.data()
                : null;
            final lat = office != null
                ? (office['latitude'] as num).toDouble()
                : 20.5937;
            final lng = office != null
                ? (office['longitude'] as num).toDouble()
                : 78.9629;
            final center = LatLng(lat, lng);
            return StreamBuilder<Position>(
              stream: Geolocator.getPositionStream(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 1,
                ),
              ),
              builder: (context, posSnap) {
                final markers = <Marker>[];
                if (posSnap.hasData) {
                  final p = posSnap.data!;
                  markers.add(
                    Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 18,
                      height: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  );
                }
                return FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: office != null ? 16 : 4,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.geofence',
                    ),
                    if (office != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: center,
                            radius: (office['radiusMeters'] as num).toDouble(),
                            useRadiusInMeter: true,
                            color: Colors.indigo.withOpacity(0.15),
                            borderColor: Colors.indigo,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    if (markers.isNotEmpty) MarkerLayer(markers: markers),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _EmployeeActions.of(context)?.onCheckIn,
                child: Text(t.checkIn),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _EmployeeActions.of(context)?.onCheckout,
                child: Text(t.checkOut),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: (_EmployeeHomeInherited.of(context)?.inside ?? false)
                        ? Colors.green
                        : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  (_EmployeeHomeInherited.of(context)?.inside ?? false)
                      ? 'Inside geofence'
                      : 'Outside geofence',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A tiny inherited widget to expose inside-state to actions card without tight coupling
class _EmployeeHomeInherited extends InheritedWidget {
  const _EmployeeHomeInherited({required Widget child, required this.inside})
    : super(child: child);
  final bool inside;
  static _EmployeeHomeInherited? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EmployeeHomeInherited>();
  @override
  bool updateShouldNotify(_EmployeeHomeInherited oldWidget) =>
      oldWidget.inside != inside;
}

class _EmployeeActions extends InheritedWidget {
  const _EmployeeActions({
    required Widget child,
    required this.onCheckIn,
    required this.onCheckout,
  }) : super(child: child);
  final VoidCallback onCheckIn;
  final VoidCallback onCheckout;
  static _EmployeeActions? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EmployeeActions>();
  @override
  bool updateShouldNotify(_EmployeeActions oldWidget) => false;
}
