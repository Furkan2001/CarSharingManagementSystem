import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 

import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';
import '../screens/post_screen.dart';

class VehicleRequestsScreen extends StatefulWidget {
  const VehicleRequestsScreen({Key? key}) : super(key: key);

  @override
  _VehicleRequestsScreenState createState() => _VehicleRequestsScreenState();
}

class _VehicleRequestsScreenState extends State<VehicleRequestsScreen> {
  List<dynamic> _journeys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchJourneys();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null); // Initialize Turkish locale
  }

  Future<void> _fetchJourneys() async {
    try {
      final journeys = await PostsService.getAllJourneys();
      setState(() {
        _journeys = journeys.where((journey) => journey['hasVehicle'] == false).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching journeys: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç İstekleri'),
      ),
      drawer: const Menu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _journeys.length,
              itemBuilder: (context, index) {
                final journey = _journeys[index];

                final currentDistrict = journey['map']?['currentDistrict'] ?? 'Unknown';
                final destinationDistrict = journey['map']?['destinationDistrict'] ?? 'Unknown';

                final timeString = journey['time'] ?? 'N/A';

                String formattedTime;
                if (timeString != 'N/A') {
                  final DateTime dateTime = DateTime.parse(timeString);
                  final DateFormat formatter = DateFormat('dd MMMM yyyy HH:mm', 'tr');
                  formattedTime = formatter.format(dateTime);
                } else {
                  formattedTime = 'N/A';
                }

                final id = journey['journeyId'] ?? -1;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text('$currentDistrict → $destinationDistrict'),
                    subtitle: Text('$formattedTime'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreen(journeyId: id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
