import 'dart:async'; // Add this import for Completer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

enum SelectionStep {
  selectingOrigin,
  originSelected,
  selectingDestination,
  routeFetched,
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  SelectionStep _currentStep = SelectionStep.selectingOrigin;

  LatLng? _origin;
  LatLng? _destination;
  String? _originName;
  String? _destinationName;
  String? _encodedPolyline;

  final String _apiKey = "AIzaSyCtTjLzchGpSEZHxTAgHVGBwQjwL4f9CVg";

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  Completer<GoogleMapController> _mapController = Completer();

  // To control the camera movement
  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(40.8083, 29.3590), zoom: 10);

  // Getter to retrieve the last selected location name
  String? get _lastSelectedLocationName {
    if (_currentStep == SelectionStep.routeFetched) {
      return _destinationName;
    } else if (_currentStep == SelectionStep.originSelected) {
      return _originName;
    }
    return null;
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konum Seç'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialCameraPosition,
            onTap: _handleMapTap,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // Positioned card to show the last selected location
          if (_lastSelectedLocationName != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                color: Colors.white70,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _lastSelectedLocationName!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Positioned button at the bottom for selection and confirmation
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _buttonAction,
              child: Text(_buttonLabel()),
            ),
          ),
        ],
      ),
    );
  }

  // Determine the button label based on the current step
  String _buttonLabel() {
    switch (_currentStep) {
      case SelectionStep.selectingOrigin:
        return 'Başlangıç Seç';
      case SelectionStep.originSelected:
        return 'Başlangıç Onayla';
      case SelectionStep.selectingDestination:
        return 'Hedef Seç';
      case SelectionStep.routeFetched:
        return 'Konum ve Rota Onayla';
      default:
        return 'Seç';
    }
  }

  // Handle button press based on the current step
  void _buttonAction() async {
    switch (_currentStep) {
      case SelectionStep.selectingOrigin:
        // Next step is to confirm origin after selecting
        setState(() {
          _currentStep = SelectionStep.originSelected;
        });
        break;
      case SelectionStep.originSelected:
        if (_origin != null) {
          setState(() {
            _currentStep = SelectionStep.selectingDestination;
          });
        } else {
          // Handle error if origin is not selected
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Lütfen bir başlangıç noktası seçin.')),
          );
        }
        break;
      case SelectionStep.selectingDestination:
        break;
      case SelectionStep.routeFetched:
        // Confirm and navigate back with data
        _confirmSelections();
        break;
      default:
        break;
    }
  }

  // Handle map taps based on the current step
  Future<void> _handleMapTap(LatLng location) async {
    switch (_currentStep) {
      case SelectionStep.selectingOrigin:
      case SelectionStep.originSelected:
        await _setOrigin(location);
        break;
      case SelectionStep.selectingDestination:
      case SelectionStep.routeFetched:
        await _setDestination(location);
        break;
      default:
        break;
    }
  }

  Future<void> _setOrigin(LatLng location) async {
    setState(() {
      _origin = location;
      _originName = null;
      _markers.removeWhere((m) => m.markerId.value == 'origin');
      _polylines.clear();
    });
    _markers.add(
      Marker(
        markerId: MarkerId('origin'),
        position: location,
        infoWindow: InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    await _fetchLocationName(location, isOrigin: true);
  }

  Future<void> _setDestination(LatLng location) async {
    setState(() {
      _destination = location;
      _destinationName = null;
      _markers.removeWhere((m) => m.markerId.value == 'destination');
      _polylines.clear();
    });
    _markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: location,
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    await _fetchLocationName(location, isOrigin: false);
    // After setting destination, fetch the route automatically
    await _fetchRoute();
    setState(() {
      _currentStep = SelectionStep.routeFetched;
    });
  }

  Future<void> _fetchLocationName(LatLng location,
      {required bool isOrigin}) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          String locationName;
          if (data['results'][0]['formatted_address'] != null) {
            locationName = data['results'][0]['formatted_address'];
          } else {
            locationName = 'Unknown location';
          }

          setState(() {
            if (isOrigin) {
              _originName = locationName;
            } else {
              _destinationName = locationName;
            }
          });
        } else {
          setState(() {
            if (isOrigin) {
              _originName = 'Unknown location';
            } else {
              _destinationName = 'Unknown location';
            }
          });
        }
      } else {
        setState(() {
          if (isOrigin) {
            _originName = 'Failed to fetch location name';
          } else {
            _destinationName = 'Failed to fetch location name';
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isOrigin) {
          _originName = 'Error fetching location';
        } else {
          _destinationName = 'Error fetching location';
        }
      });
    }
  }

  Future<void> _fetchRoute() async {
    // Check if both origin and destination names are available
    if (_originName == null || _destinationName == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Origin or destination name is not available.'),
      ));
      return;
    }

    print("Fetching route using location names");

    // URL encode the location names to handle spaces and special characters
    final encodedOrigin = Uri.encodeComponent(_originName!);
    final encodedDestination = Uri.encodeComponent(_destinationName!);

    // Construct the Directions API request URL using location names
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$encodedOrigin'
      '&destination=$encodedDestination'
      '&key=$_apiKey',
    );

    print('Directions API Request URL: $url');

    try {
      final response = await http.get(url);
      print('Directions API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Directions API Response Data: $data');

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polyline = route['overview_polyline']['points'];
          _addPolyline(polyline);
        } else {
          // Handle cases where no route is found
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No route found: ${data['status']}'),
          ));
          print('No route found: ${data['status']}');
        }
      } else {
        // Handle HTTP errors
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to fetch route: ${response.statusCode}'),
        ));
        print(
            'Failed to fetch route: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle exceptions such as network issues
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching route: $e'),
      ));
      print('Exception while fetching route: $e');
    }
  }

  void _addPolyline(String encodedPolyline) {
    _encodedPolyline = encodedPolyline; // Store the encoded polyline

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyline =
        polylinePoints.decodePolyline(encodedPolyline);

    List<LatLng> polylineCoordinates = decodedPolyline
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });

    _adjustCameraBounds(polylineCoordinates);
  }

  Future<void> _adjustCameraBounds(List<LatLng> polylineCoordinates) async {
    if (polylineCoordinates.isEmpty) return;

    double minLat = polylineCoordinates.first.latitude;
    double maxLat = polylineCoordinates.first.latitude;
    double minLng = polylineCoordinates.first.longitude;
    double maxLng = polylineCoordinates.first.longitude;

    for (var coord in polylineCoordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  // Confirm selections and navigate back with data
  void _confirmSelections() {
    Navigator.pop(context, {
      'origin': {
        'coordinates': {
          'latitude': _origin!.latitude,
          'longitude': _origin!.longitude,
        },
        'name': _originName,
      },
      'destination': {
        'coordinates': {
          'latitude': _destination!.latitude,
          'longitude': _destination!.longitude,
        },
        'name': _destinationName,
      },
      'route': _encodedPolyline ?? '', // Send the encoded polyline string
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
