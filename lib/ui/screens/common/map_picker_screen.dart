import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerResult {
  MapPickerResult({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });
  final double latitude;
  final double longitude;
  final double radiusMeters;
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    this.initialLatitude = 20.5937,
    this.initialLongitude = 78.9629,
    this.initialRadius = 100,
  });

  final double initialLatitude;
  final double initialLongitude;
  final double initialRadius;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _controller = MapController();
  LatLng? _selected;
  double _radius = 100;

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadius;
  }

  @override
  Widget build(BuildContext context) {
    final initial = LatLng(widget.initialLatitude, widget.initialLongitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick office location'),
        actions: [
          TextButton(
            onPressed: _selected == null
                ? null
                : () {
                    Navigator.of(context).pop(
                      MapPickerResult(
                        latitude: _selected!.latitude,
                        longitude: _selected!.longitude,
                        radiusMeters: _radius,
                      ),
                    );
                  },
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: initial,
                initialZoom: 4,
                onTap: (tapPosition, latLng) =>
                    setState(() => _selected = latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.geofence',
                ),
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 24,
                        height: 24,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                if (_selected != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _selected!,
                        radius: _radius,
                        useRadiusInMeter: true,
                        color: Colors.indigo.withOpacity(0.15),
                        borderColor: Colors.indigo,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Radius'),
                Expanded(
                  child: Slider(
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    label: '${_radius.toStringAsFixed(0)} m',
                    value: _radius,
                    onChanged: (v) => setState(() => _radius = v),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${_radius.toStringAsFixed(0)} m',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
