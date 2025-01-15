import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

enum SelectionStep {
  selectingOrigin,
  originSelected,
  selectingDestination,
  destinationSelected,
  selectingRoute,
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

  final String _apiKey = "AIzaSyCtTjLzchGpSEZHxTAgHVGBwQjwL4f9CVg";

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<Map<String, dynamic>> _alternativeRoutes = [];
  int? _selectedRouteIndex;

  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(40.8083, 29.3590), zoom: 10);

  String? get _lastSelectedLocationName {
    if (_currentStep == SelectionStep.selectingDestination ||
        _currentStep == SelectionStep.destinationSelected) {
      return _originName;
    } else if (_currentStep == SelectionStep.selectingRoute) {
      return _destinationName;
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
                  child: Text(
                    _lastSelectedLocationName!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          if (_currentStep == SelectionStep.selectingRoute)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _alternativeRoutes.length,
                  itemBuilder: (context, index) {
                    final route = _alternativeRoutes[index];
                    return ListTile(
                      title: Text('Rota ${index + 1}'),
                      subtitle: Text(
                          'Mesafe: ${route['distance']} - Süre: ${route['duration']}'),
                      trailing: _selectedRouteIndex == index
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () => _selectRoute(index),
                    );
                  },
                ),
              ),
            ),
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

  String _buttonLabel() {
    switch (_currentStep) {
      case SelectionStep.selectingOrigin:
        return 'Başlangıç Seç';
      case SelectionStep.originSelected:
        return 'Başlangıç Onayla';
      case SelectionStep.selectingDestination:
        return 'Hedef Seç';
      case SelectionStep.destinationSelected:
        return 'Hedef Onayla';
      case SelectionStep.selectingRoute:
        return 'Rota Seç';
      default:
        return 'Seç';
    }
  }

  void _buttonAction() async {
    switch (_currentStep) {
      case SelectionStep.selectingOrigin:
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
          _showSnackBar('Lütfen bir başlangıç noktası seçin.');
        }
        break;
      case SelectionStep.selectingDestination:
        setState(() {
          _currentStep = SelectionStep.destinationSelected;
        });
        break;
      case SelectionStep.destinationSelected:
        if (_destination != null) {
          await _fetchRoute();
          setState(() {
            _currentStep = SelectionStep.selectingRoute;
          });
        } else {
          _showSnackBar('Lütfen bir hedef seçin.');
        }
        break;
      case SelectionStep.selectingRoute:
        if (_selectedRouteIndex != null) {
          _confirmSelections();
        } else {
          _showSnackBar('Lütfen bir rota seçin.');
        }
        break;
      default:
        break;
    }
  }

  Future<void> _handleMapTap(LatLng location) async {
    switch (_currentStep) {
      case SelectionStep.selectingOrigin:
      case SelectionStep.originSelected:
        await _setOrigin(location);
        break;
      case SelectionStep.selectingDestination:
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
          String locationName = data['results'][0]['formatted_address'] ?? '';
          setState(() {
            if (isOrigin) {
              _originName = locationName;
            } else {
              _destinationName = locationName;
            }
          });
        }
      }
    } catch (e) {
      _showSnackBar('Konum ismi alınamadı.');
    }
  }

  Future<void> _fetchRoute() async {
    final encodedOrigin = Uri.encodeComponent(_originName!);
    final encodedDestination = Uri.encodeComponent(_destinationName!);
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$encodedOrigin'
      '&destination=$encodedDestination'
      '&alternatives=true'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          List<Map<String, dynamic>> routes = [];
          data['routes'].forEach((route) {
            routes.add({
              'polyline': route['overview_polyline']['points'],
              'distance': route['legs'][0]['distance']['text'],
              'duration': route['legs'][0]['duration']['text'],
            });
          });
          _displayAlternativeRoutes(routes);
        }
      }
    } catch (e) {
      _showSnackBar('Rota bilgisi alınamadı.');
    }
  }

  void _displayAlternativeRoutes(List<Map<String, dynamic>> routes) {
    _polylines.clear();
    List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    for (int i = 0; i < routes.length; i++) {
      final polyline = routes[i]['polyline'];
      final decodedPolyline = PolylinePoints()
          .decodePolyline(polyline)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route_$i'),
          points: decodedPolyline,
          color: colors[i % colors.length],
          width: 5,
        ),
      );
    }
    setState(() {
      _alternativeRoutes = routes;
    });
  }

  void _selectRoute(int index) {
    setState(() {
      _selectedRouteIndex = index;

      final updatedPolylines = <Polyline>{};
      for (int i = 0; i < _alternativeRoutes.length; i++) {
        final route = _alternativeRoutes[i];
        final decodedPolyline = PolylinePoints()
            .decodePolyline(route['polyline'])
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        updatedPolylines.add(
          Polyline(
            polylineId: PolylineId('route_$i'),
            points: decodedPolyline,
            color: i == index ? Colors.blueAccent : Colors.grey,
            width: 5,
          ),
        );
      }

      _polylines = updatedPolylines;
    });
  }

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
      'route': _selectedRouteIndex != null
          ? _alternativeRoutes[_selectedRouteIndex!]['polyline']
          : '',
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
