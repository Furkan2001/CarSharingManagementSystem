import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';
import '../widgets/custom_appbar.dart';
import 'map_screen.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/auth_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _currentDistrict = TextEditingController();
  TextEditingController _destinationDistrict = TextEditingController();
  DateTime? _selectedTime;
  bool _hasVehicle = true;
  bool _isOneTime = true;
  bool _isLocaleInitialized = false;

  String? _departureLatitude;
  String? _departureLongitude;
  String? _destinationLatitude;
  String? _destinationLongitude;

  int userId = AuthService().userId ?? -1;

  String? _encodedRoute; // To store the encoded route string
  List<LatLng> _routePoints = []; // To store decoded route points for display

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
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null);
    setState(() {
      _isLocaleInitialized = true;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  Future<void> _submitForm() async {
    eventStart = DateTime.now();

    if (_formKey.currentState!.validate()) {
      // Check if the user has selected a date and time
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lütfen kalkış saati seçin!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                Colors.red, // Optional: Highlight with a red background
          ),
        );
        return; // Exit the function if the date and time are not selected
      }

      final newJourney = {
        "journeyId": 0,
        "hasVehicle": _hasVehicle,
        "mapId": 0,
        "time": _selectedTime?.toIso8601String(),
        "isOneTime": _isOneTime,
        "userId": userId,
        "map": {
          "mapId": 0,
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
                      "journeyId": 0,
                      "dayId": _getDayId(entry.key),
                    })
                .toList(),
      };

      try {
        final success = await PostsService.createJourney(newJourney);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paylaşım başarıyla oluşturuldu!')),
          );

          _formKey.currentState!.reset();
          _currentDistrict.clear();
          _destinationDistrict.clear();
          setState(() {
            _selectedTime = null;
            _hasVehicle = true;
            _isOneTime = true;
            _selectedDays.updateAll((key, value) => false);
            _departureLatitude = null;
            _departureLongitude = null;
            _destinationLatitude = null;
            _destinationLongitude = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paylaşım oluşturulamadı!')),
          );
        }
        eventEnd = DateTime.now();
        Duration difference = eventEnd.difference(eventStart);
        print("Paylaşım oluştur button clicked at $eventStart\n"
            "Post created at $eventEnd\n"
            "Milliseconds creating post: ${difference.inMilliseconds}");
      } catch (e) {
        print('Error creating journey: $e');
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

  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Yeni Paylaşım Oluştur'),
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
                    'Yolculuk Oluştur',
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
