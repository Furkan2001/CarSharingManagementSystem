import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';

class EditPostScreen extends StatefulWidget {
  final int journeyId;

  const EditPostScreen({Key? key, required this.journeyId}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentDistrict = TextEditingController();
  final TextEditingController _destinationDistrict = TextEditingController();
  DateTime? _selectedTime;
  bool _hasVehicle = true;
  bool _isOneTime = true;
  int _mapId = 0;

  bool _isLocaleInitialized = false;
  bool _isLoading = true;

  final Map<String, bool> _selectedDays = {
    "Monday": false,
    "Tuesday": false,
    "Wednesday": false,
    "Thursday": false,
    "Friday": false,
    "Saturday": false,
    "Sunday": false,
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

  Future<void> _fetchJourneyData() async {
    try {
      final journey = await PostsService.getJourneyById(widget.journeyId);

      setState(() {
        _currentDistrict.text = journey['map']?['currentDistrict'] ?? '';
        _destinationDistrict.text = journey['map']?['destinationDistrict'] ?? '';
        _selectedTime = DateTime.parse(journey['time']);
        _hasVehicle = journey['hasVehicle'];
        _isOneTime = journey['isOneTime'];
        _mapId =  journey['mapId'];

        // Populate selected days based on journeyDays
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
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      final updatedJourney = {
        "journeyId": widget.journeyId,
        "hasVehicle": _hasVehicle,
        "mapId": _mapId,
        "time": _selectedTime?.toIso8601String(),
        "isOneTime": _isOneTime,
        "userId": 2,
        "map": {
          "mapId": _mapId,
          "destinationLatitude": "41.008",
          "destinationLongitude": "29.345",
          "departureLatitude": "40.786",
          "departureLongitude": "29.678",
          "mapRoute": "Route",
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
        final success = await PostsService.updateJourney(widget.journeyId, updatedJourney);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paylaşım başarıyla güncellendi!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paylaşım güncellenemedi!')),
          );
        }
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
      case "Monday":
        return 1;
      case "Tuesday":
        return 2;
      case "Wednesday":
        return 3;
      case "Thursday":
        return 4;
      case "Friday":
        return 5;
      case "Saturday":
        return 6;
      case "Sunday":
        return 7;
      default:
        return 0;
    }
  }

  String? _getDayName(int dayId) {
    switch (dayId) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
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
      appBar: AppBar(
        title: const Text('Yolculuğu Düzenle'),
      ),
      drawer: const Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              _buildCoordinateField(_currentDistrict, 'Kalkış Yeri'),
              const SizedBox(height: 16),
              _buildCoordinateField(_destinationDistrict, 'Varış Yeri'),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedTime != null
                      ? DateFormat('dd MMMM yyyy HH:mm', 'tr').format(_selectedTime!)
                      : 'Kalkış Saati Seç',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aracınız var mı?'),
                value: _hasVehicle,
                onChanged: (value) {
                  setState(() {
                    _hasVehicle = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Tek Seferlik Mi?'),
                value: _isOneTime,
                onChanged: (value) {
                  setState(() {
                    _isOneTime = value;
                  });
                },
              ),
              if (!_isOneTime) ...[
                const SizedBox(height: 16),
                const Text(
                  'Günler:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._selectedDays.keys.map((day) {
                  return CheckboxListTile(
                    title: Text(day),
                    value: _selectedDays[day],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedDays[day] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Yolculuk Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen $label girin';
        }
        return null;
      },
    );
  }
}
