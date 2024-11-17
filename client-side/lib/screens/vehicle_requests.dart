import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';
import '../widgets/custom_appbar.dart';
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
    await initializeDateFormatting('tr', null);
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
      appBar: const CustomAppBar(title: 'Araç İstekleri'),
      drawer: const Menu(),
      body: Container(
      color: const Color.fromARGB(255,54, 69, 74), 
      child: _isLoading
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Color.fromARGB(255, 6, 30, 69), size: 30),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$currentDistrict → $destinationDistrict',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Color.fromARGB(255, 6, 30, 69), size: 24),
                              const SizedBox(width: 8),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostScreen(journeyId: id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  backgroundColor: const Color.fromARGB(255, 6, 30, 69),
                                ),
                                child: const Text(
                                  'Detaylar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      )
    );
  }
}
