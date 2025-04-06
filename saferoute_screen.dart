
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;

class SafeRouteScreen extends StatefulWidget {
  @override
  _SafeRouteScreenState createState() => _SafeRouteScreenState();
}
//to run this page we have to use this flutter run -d chrome --web-browser-flag "--disable-web-security" to disable our window security and run this
class _SafeRouteScreenState extends State<SafeRouteScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  String _startLocation = "";
  String _endLocation = "";
  Set<Polyline> _polylines = {};
  final googlePlace = GooglePlace("AIzaSyBYcJfrlaPzs9YTI0XhGvDn9A5oaNQVB5M");

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get User's Live Location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 15),
    ));
  }

  // Fetch Directions from Google API
  Future<void> _getDirections(String start, String end) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=$start&destination=$end&key=AIzaSyBYcJfrlaPzs9YTI0XhGvDn9A5oaNQVB5M");
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["routes"].isNotEmpty) {
        _drawRoute(data["routes"][0]["overview_polyline"]["points"]);
      }
    }
  }

  // Draw Route on the Map
  void _drawRoute(String encodedPolyline) {
    List<LatLng> routeCoords = _decodePolyline(encodedPolyline);
    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: PolylineId("route"),
        points: routeCoords,
        color: Colors.blue,
        width: 5,
      ));
    });
  }

  // Decode Google Polyline
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Safe Route Finder")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Enter Starting Location"),
                    onChanged: (value) => _startLocation = value,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Enter Destination"),
                    onChanged: (value) => _endLocation = value,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _getDirections(_startLocation, _endLocation);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_currentPosition != null) {
                  _mapController.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: _currentPosition!, zoom: 15),
                  ));
                }
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? LatLng(37.7749, -122.4194),
                zoom: 12,
              ),
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
