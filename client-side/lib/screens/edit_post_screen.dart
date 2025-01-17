import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';
import '../widgets/custom_appbar.dart';
import '../services/auth_service.dart';
import 'map_screen.dart';

class EditPostScreen extends StatefulWidget {
  final int journeyId;

  const EditPostScreen({Key? key, required this.journeyId}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _currentDistrict = TextEditingController();
  TextEditingController _destinationDistrict = TextEditingController();
  DateTime? _selectedTime;
  bool _hasVehicle = true;
  bool _isOneTime = true;
  int _mapId = 0;

  bool _isLocaleInitialized = false;
  bool _isLoading = true;

  String? _departureLatitude;
  String? _departureLongitude;
  String? _destinationLatitude;
  String? _destinationLongitude;

  String? _encodedRoute; // To store the encoded route string
  List<LatLng> _routePoints = []; // To store decoded route points for display

  int userId = AuthService().userId ?? -1;

  DateTime eventStart = DateTime.now();
  DateTime eventEnd = DateTime.now();

  final Map<String, bool> _selectedDays = {
    "Pazartesi": false,
    "Salı": false,
    "Çarşamba": false,
    "Perşembe": false,
    "Cuma": false,
    "Cumartesi": false,
    "Pazar": false,
  };

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchJourneyData(); // Fetch journey data on initialization
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null);
    setState(() {
      _isLocaleInitialized = true;
    });
  }

  Future<void> _launchMap() async {
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );

    if (result != null) {
      setState(() {
        // Handle Origin
        if (result['origin'] != null) {
          final origin = result['origin'];
          _currentDistrict.text = origin['name'] ?? 'Unknown location';
          _departureLatitude = origin['coordinates']['latitude'].toString();
          _departureLongitude = origin['coordinates']['longitude'].toString();
        }

        // Handle Destination
        if (result['destination'] != null) {
          final destination = result['destination'];
          _destinationDistrict.text = destination['name'] ?? 'Unknown location';
          _destinationLatitude =
              destination['coordinates']['latitude'].toString();
          _destinationLongitude =
              destination['coordinates']['longitude'].toString();
        }

        // Handle Route
        if (result['route'] != null &&
            result['route'] is String &&
            (result['route'] as String).isNotEmpty) {
          _encodedRoute = result['route'];

          // Decode the polyline string to get the list of LatLng points
          PolylinePoints polylinePoints = PolylinePoints();
          List<PointLatLng> decodedPolyline =
              polylinePoints.decodePolyline(_encodedRoute!);

          _routePoints = decodedPolyline
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        }

        print('Origin: $_departureLatitude, $_departureLongitude');
        print('Destination: $_destinationLatitude, $_destinationLongitude');
        print('Encoded Route: $_encodedRoute');
        print('Decoded Route Points: $_routePoints');
      });
    }
  }

  Future<void> _fetchJourneyData() async {
    try {
      final journey = await PostsService.getJourneyById(widget.journeyId);

      setState(() {
        _currentDistrict.text = journey['map']?['currentDistrict'] ?? '';
        _destinationDistrict.text =
            journey['map']?['destinationDistrict'] ?? '';
        _selectedTime = DateTime.parse(journey['time']);
        _hasVehicle = journey['hasVehicle'];
        _isOneTime = journey['isOneTime'];
        _mapId = journey['mapId'];
        _departureLatitude = journey['map']?['departureLatitude'];
        _departureLongitude = journey['map']?['departureLongitude'];
        _destinationLatitude = journey['map']?['destinationLatitude'];
        _destinationLongitude = journey['map']?['destinationLongitude'];
        _encodedRoute = journey['map']?['mapRoute'];

        journey['journeyDays'].forEach((day) {
          final dayName = _getDayName(day['dayId']);
          if (dayName != null) {
            _selectedDays[dayName] = true;
          }
        });

        _isLoading = false; // Data has been loaded
      });
    } catch (e) {
      print('Error fetching journey data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yolculuk verileri alınamadı.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    DateTime eventStart = DateTime.now();
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      final updatedJourney = {
        "journeyId": widget.journeyId,
        "hasVehicle": _hasVehicle,
        "mapId": _mapId,
        "time": _selectedTime?.toIso8601String(),
        "isOneTime": _isOneTime,
        "userId": userId,
        "map": {
          "mapId": _mapId,
          "destinationLatitude": _destinationLatitude,
          "destinationLongitude": _destinationLongitude,
          "departureLatitude": _departureLatitude,
          "departureLongitude": _departureLongitude,
          "mapRoute": _encodedRoute,
          "currentDistrict": _currentDistrict.text,
          "destinationDistrict": _destinationDistrict.text,
        },
        "journeyDays": _isOneTime
            ? []
            : _selectedDays.entries
                .where((entry) => entry.value)
                .map((entry) => {
                      "journeyDayId": 0,
                      "journeyId": widget.journeyId,
                      "dayId": _getDayId(entry.key)
                    })
                .toList(),
      };

      try {
        final success =
            await PostsService.updateJourney(widget.journeyId, updatedJourney);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paylaşım başarıyla güncellendi!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paylaşım güncellenemedi!')),
          );
        }
        eventEnd = DateTime.now();
        Duration difference = eventEnd.difference(eventStart);
        print("Paylaşımı Düzenle button clicked at $eventStart\n"
            "Post updated at $eventEnd\n"
            "Miliseconds updating post: ${difference.inMilliseconds}");
      } catch (e) {
        print('Error updating journey: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bir hata oluştu.')),
        );
      }
    }
  }

  int _getDayId(String dayName) {
    switch (dayName) {
      case "Pazartesi":
        return 1;
      case "Salı":
        return 2;
      case "Çarşamba":
        return 3;
      case "Perşembe":
        return 4;
      case "Cuma":
        return 5;
      case "Cumartesi":
        return 6;
      case "Pazar":
        return 7;
      default:
        return 0;
    }
  }

  String? _getDayName(int dayId) {
    switch (dayId) {
      case 1:
        return "Pazartesi";
      case 2:
        return "Salı";
      case 3:
        return "Çarşamba";
      case 4:
        return "Perşembe";
      case 5:
        return "Cuma";
      case 6:
        return "Cumartesi";
      case 7:
        return "Pazar";
      default:
        return null;
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized || _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Yolculuğu Düzenle'),
      drawer: const Menu(),
      body: Container(
        color: const Color.fromARGB(255, 54, 69, 74),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildFormSection(
                  label: 'Kalkış Yeri',
                  child: Row(
                    children: [
                      Expanded(child: _buildCoordinateField(_currentDistrict)),
                    ],
                  ),
                ),
                _buildFormSection(
                  label: 'Varış Yeri',
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildCoordinateField(_destinationDistrict)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_location_alt,
                          color: Colors.white),
                      onPressed: () {
                        _launchMap();
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ListTile(
                    tileColor: const Color(
                        0xFF2E3B4E), // Optional background color for consistency
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(
                      _selectedTime != null
                          ? DateFormat('dd MMMM yyyy HH:mm', 'tr')
                              .format(_selectedTime!)
                          : 'Kalkış Saati Seç',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing:
                        const Icon(Icons.access_time, color: Colors.white),
                    onTap: () => _selectDateTime(context),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormSwitch(
                  label: 'Aracınız var mı?',
                  value: _hasVehicle,
                  onChanged: (value) => setState(() => _hasVehicle = value),
                ),
                _buildFormSwitch(
                  label: 'Tek Seferlik Mi?',
                  value: _isOneTime,
                  onChanged: (value) => setState(() => _isOneTime = value),
                ),
                if (!_isOneTime)
                  _buildFormSection(
                    label: 'Günler',
                    child: Column(
                      children: _selectedDays.keys.map((day) {
                        return CheckboxListTile(
                          title: Text(
                            day,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: _selectedDays[day],
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedDays[day] = value ?? false;
                            });
                          },
                          checkColor: Colors
                              .white, // Color for the check inside the box
                          activeColor: const Color.fromARGB(
                              255, 6, 30, 69), // Color when checked
                          tileColor: const Color(
                              0xFF2E3B4E), // Background color for the tile
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(
                              color: Colors.white), // Makes unchecked box white
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color.fromARGB(255, 6, 30, 69),
                  ),
                  child: const Text(
                    'Yolculuğu Güncelle',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinateField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Color(0xFF6F8695),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bilgiyi girin';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildFormSection({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildFormSwitch({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color.fromARGB(255, 6, 30, 69),
    );
  }
}
