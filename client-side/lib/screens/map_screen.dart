import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  String? _locationName;
  final String _apiKey = 'AIzaSyCtTjLzchGpSEZHxTAgHVGBwQjwL4f9CVg';

  Future<void> _fetchLocationName(LatLng location) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        String? locationName;
        if (data['results'][0]['name'] != null) {
          locationName = data['results'][0]['name'];
        } else {
          locationName = data['results'][0]['formatted_address'];
        }

        setState(() {
          _locationName = locationName ?? 'Unknown location';
        });
      } else {
        setState(() {
          _locationName = 'Unknown location';
        });
      }
    } else {
      setState(() {
        _locationName = 'Failed to fetch location name';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(40.8083, 29.3590),
              zoom: 10,
            ),
            onTap: (LatLng location) async {
              setState(() {
                _pickedLocation = location;
              });
              await _fetchLocationName(location);
            },
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked-location'),
                      position: _pickedLocation!,
                    ),
                  }
                : {},
          ),
          if (_pickedLocation != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _locationName ?? 'Fetching location name...',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _pickedLocation != null
                  ? () => Navigator.pop(context, {
                        'coordinates': {
                          'latitude': _pickedLocation!.latitude,
                          'longitude': _pickedLocation!.longitude,
                        },
                        'locationName': _locationName,
                      })
                  : null,
              child: const Text('Confirm Location'),
            ),
          ),
        ],
      ),
    );
  }
}
