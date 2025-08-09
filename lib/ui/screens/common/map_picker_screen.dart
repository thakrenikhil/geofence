import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _selected;
  double _radius = 100;

  @override
  void initState() {
    super.initState();
    _radius = widget.initialRadius;
  }

  @override
  Widget build(BuildContext context) {
    final initial = CameraPosition(
      target: LatLng(widget.initialLatitude, widget.initialLongitude),
      zoom: 4,
    );

    final markers = <Marker>{};
    final circles = <Circle>{};
    if (_selected != null) {
      markers.add(
        Marker(markerId: const MarkerId('selected'), position: _selected!),
      );
      circles.add(
        Circle(
          circleId: const CircleId('radius'),
          center: _selected!,
          radius: _radius,
          strokeColor: Colors.indigo,
          fillColor: Colors.indigo.withOpacity(0.15),
          strokeWidth: 2,
        ),
      );
    }

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
            child: GoogleMap(
              initialCameraPosition: initial,
              onMapCreated: (c) => _controller.complete(c),
              onTap: (latLng) => setState(() => _selected = latLng),
              markers: markers,
              circles: circles,
              myLocationButtonEnabled: true,
              myLocationEnabled: false,
              zoomControlsEnabled: true,
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
