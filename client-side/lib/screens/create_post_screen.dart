import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // For initializing locale data
import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentDistrict = TextEditingController();
  final TextEditingController _destinationDistrict = TextEditingController();
  DateTime? _selectedTime;
  bool _hasVehicle = true;
  bool _isOneTime = true;
  bool _isLocaleInitialized = false;

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

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate() && _selectedTime != null) {
    // Collect all data in the required format
    final newJourney = {
      "journeyId": 0,
      "hasVehicle": _hasVehicle,
      "mapId": 0,
      "time": _selectedTime?.toIso8601String(),
      "isOneTime": _isOneTime,
      "userId": 2, // Use a specific userId here
      "map": {
        "mapId": 0,
        "destinationLatitude": "41.008",  // Replace with actual input if needed
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
                    "journeyId": 0,
                    "dayId": _getDayId(entry.key) // Maps day to dayId
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
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paylaşım oluşturulamadı!')),
        );
      }
    } catch (e) {
      print('Error creating journey: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu.')),
      );
    }
  }
}

// Helper function to get dayId based on the day name
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


  @override
  Widget build(BuildContext context) {
    if (!_isLocaleInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Paylaşım Oluştur'),
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
                child: const Text('Yolculuk Oluştur'),
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
