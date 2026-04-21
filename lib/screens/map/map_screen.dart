import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _fallbackCenter = LatLng(41.8818, -87.6231);

  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d2c4d"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1a3646"}]},
  {"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},
  {"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#64779e"}]},
  {"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#4b6878"}]},
  {"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#334e87"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#023e58"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#283d6a"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#6f9ba5"}]},
  {"featureType":"poi","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},
  {"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#023e58"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#3C7680"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#304a7d"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},
  {"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2c6675"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#255763"}]},
  {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#b0d5ce"}]},
  {"featureType":"road.highway","elementType":"labels.text.stroke","stylers":[{"color":"#023e58"}]},
  {"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#98a5be"}]},
  {"featureType":"transit","elementType":"labels.text.stroke","stylers":[{"color":"#1d2c4d"}]},
  {"featureType":"transit.line","elementType":"geometry.fill","stylers":[{"color":"#283d6a"}]},
  {"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#3a4762"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1626"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4e6d70"}]}
]
''';

  final Completer<GoogleMapController> _mapController = Completer();

  LatLng _cameraTarget = _fallbackCenter;
  LatLng? _userLatLng;
  String? _errorText;
  bool _isLoadingLocation = true;
  bool _hasLocationPermission = false;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
        _errorText = null;
      });
    }

    try {
      final hasPermission = await _handleLocationPermission();
      if (!mounted) {
        return;
      }

      if (!hasPermission) {
        setState(() {
          _hasLocationPermission = false;
          _isLoadingLocation = false;
          _errorText =
              'Location access is required. Turn on permission and location services.';
        });
        return;
      }

      final position = await _getBestAvailablePosition();

      if (position == null) {
        setState(() {
          _hasLocationPermission = true;
          _isLoadingLocation = false;
          _errorText = 'Unable to get your location. Try again.';
        });
        return;
      }

      final target = LatLng(position.latitude, position.longitude);

      if (!mounted) {
        return;
      }
      setState(() {
        _hasLocationPermission = true;
        _userLatLng = target;
        _cameraTarget = target;
        _isLoadingLocation = false;
        _errorText = null;
      });

      await _centerOnUser();
      await _startLiveLocationUpdates();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasLocationPermission = false;
        _isLoadingLocation = false;
        _errorText = 'Unable to fetch current location.';
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> _getBestAvailablePosition() async {
    Position? current;
    try {
      current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      current = await Geolocator.getLastKnownPosition();
    }

    if (current == null) {
      return null;
    }

    // If accuracy is already good, use it immediately.
    if (current.accuracy <= 35) {
      return current;
    }

    // Otherwise, wait briefly for a better live fix (GPS may need a few seconds).
    try {
      final better = await Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).firstWhere((position) => position.accuracy <= 35).timeout(
        const Duration(seconds: 12),
      );
      return better;
    } on TimeoutException {
      return current;
    }
  }

  Future<void> _centerOnUser() async {
    final target = _userLatLng;
    if (target == null || !_mapController.isCompleted) {
      return;
    }

    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(target, 16),
    );
  }

  Future<void> _startLiveLocationUpdates() async {
    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((position) {
      if (!mounted) {
        return;
      }

      final updated = LatLng(position.latitude, position.longitude);
      final previous = _userLatLng;
      final isMoreAccurate = position.accuracy <= 35;
      final changed = previous == null ||
          (previous.latitude != updated.latitude ||
              previous.longitude != updated.longitude);

      if (!changed) {
        return;
      }

      setState(() {
        _userLatLng = updated;
        if (isMoreAccurate) {
          _cameraTarget = updated;
        }
      });

      if (isMoreAccurate) {
        _centerOnUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPosition = _userLatLng;

    final markers = <Marker>{
      if (userPosition != null)
        Marker(
          markerId: const MarkerId('user_location'),
          position: userPosition,
        ),
    };

    final circles = <Circle>{
      if (userPosition != null)
        Circle(
          circleId: const CircleId('user_glow'),
          center: userPosition,
          radius: 45,
          fillColor: Colors.lightBlueAccent.withValues(alpha: 0.25),
          strokeColor: Colors.lightBlueAccent.withValues(alpha: 0.8),
          strokeWidth: 2,
        ),
    };

    return Scaffold(
      body: GoogleMap(
        style: _darkMapStyle,
        initialCameraPosition: CameraPosition(
          target: _cameraTarget,
          zoom: 13.7,
        ),
        myLocationEnabled: _hasLocationPermission,
        myLocationButtonEnabled: _hasLocationPermission,
        markers: markers,
        circles: circles,
        onMapCreated: (controller) async {
          if (!_mapController.isCompleted) {
            _mapController.complete(controller);
          }

          if (_userLatLng != null) {
            await controller.animateCamera(
              CameraUpdate.newLatLngZoom(_userLatLng!, 16),
            );
          }
        },
      ),
      floatingActionButton: _isLoadingLocation
          ? const FloatingActionButton.small(
              onPressed: null,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_userLatLng != null) ...[
                  FloatingActionButton.small(
                    heroTag: 'center_on_user',
                    onPressed: _centerOnUser,
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 8),
                ],
                FloatingActionButton.small(
                  heroTag: 'refresh_location',
                  onPressed: _initLocation,
                  child: Icon(
                    _errorText == null ? Icons.gps_fixed : Icons.refresh,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _errorText != null
          ? SafeArea(
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                padding: const EdgeInsets.all(12),
                child: Text(
                  _errorText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }
}
