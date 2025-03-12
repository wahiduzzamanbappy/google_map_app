import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'location_services.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = LatLng(23.80680840148543, 90.3689306513461);
  final List<LatLng> _polylineCoordinates = [];
  final Set<Polyline> _polyline = {};
  final Set<Marker> _markers = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  Future<void> _getCurrentLocation() async {
    Position? position = await LocationService().getCurrentLocation();

    LatLng newPosition = LatLng(position.latitude, position.longitude);
    _updatePosition(newPosition, animate: true);
  }

  void _updatePosition(LatLng newPosition, {bool animate = false}) {
    setState(() {
      _polylineCoordinates.add(newPosition);
      _polyline.add(
        Polyline(
          polylineId: PolylineId("route"),
          color: Colors.blue,
          points: _polylineCoordinates,
          width: 5,
        ),
      );

      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId("current"),
          position: newPosition,
          infoWindow: InfoWindow(
            title: "My Current Location",
            snippet:
                "Lat: ${newPosition.latitude}, Lng: ${newPosition.longitude}",
          ),
        ),
      );
      _currentPosition = newPosition;
    });

    if (animate) {
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) async {
      _getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Real-time Location"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: GoogleMap(
        initialCameraPosition:
            CameraPosition(target: _currentPosition, zoom: 16),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: _polyline,
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
