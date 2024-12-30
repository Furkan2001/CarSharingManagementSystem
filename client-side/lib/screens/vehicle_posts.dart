import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';
import '../widgets/custom_appbar.dart';
import '../screens/post_screen.dart';

class VehiclePostsScreen extends StatefulWidget {
  const VehiclePostsScreen({Key? key}) : super(key: key);

  @override
  _VehiclePostsScreenState createState() => _VehiclePostsScreenState();
}

class _VehiclePostsScreenState extends State<VehiclePostsScreen> {
  List<dynamic> _journeys = [];
  List<dynamic> _filteredJourneys = [];
  bool _isLoading = true;
  String _searchQuery = '';

  final FocusNode _searchFocusNode =
      FocusNode(); // FocusNode for the search bar
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search bar

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchJourneys();
  }

  @override
  void dispose() {
    // Dispose of the FocusNode and TextEditingController when no longer needed
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null); // Initialize Turkish locale
  }

  Future<void> _fetchJourneys() async {
    try {
      int currentUserId = 2;
      final journeys = await PostsService.getAllJourneys();
      setState(() {
        _journeys = journeys
            .where((journey) =>
                journey['hasVehicle'] == true &&
                journey['userId'] != currentUserId)
            .toList();
        _filteredJourneys = _journeys;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching journeys: $e');
    }
  }

  void _filterJourneys(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredJourneys = _journeys.where((journey) {
        final departure =
            (journey['map']?['currentDistrict'] ?? '').toLowerCase();
        final destination =
            (journey['map']?['destinationDistrict'] ?? '').toLowerCase();
        return departure.contains(_searchQuery) ||
            destination.contains(_searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Araç Paylaşımları'),
      drawer: const Menu(),
      body: Container(
        color: const Color.fromARGB(255, 54, 69, 74),
        child: Column(
          children: [
            _buildSearchBar(), // Keeps the search bar outside the rebuilds
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredJourneys.length,
                      itemBuilder: (context, index) {
                        final journey = _filteredJourneys[index];

                        final currentDistrict =
                            journey['map']?['currentDistrict'] ?? 'Unknown';
                        final destinationDistrict =
                            journey['map']?['destinationDistrict'] ?? 'Unknown';

                        final timeString = journey['time'] ?? 'N/A';

                        String formattedTime;
                        if (timeString != 'N/A') {
                          final DateTime dateTime = DateTime.parse(timeString);
                          final DateFormat formatter =
                              DateFormat('dd MMMM yyyy HH:mm', 'tr');
                          formattedTime = formatter.format(dateTime);
                        } else {
                          formattedTime = 'N/A';
                        }

                        final id = journey['journeyId'] ?? -1;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
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
                                      const Icon(Icons.location_on,
                                          color: Color.fromARGB(255, 6, 30, 69),
                                          size: 30),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Başlangıç: ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: currentDistrict,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Hedef: ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: destinationDistrict,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: Color.fromARGB(255, 6, 30, 69),
                                          size: 24),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PostScreen(journeyId: id),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          backgroundColor: const Color.fromARGB(
                                              255, 6, 30, 69),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        focusNode: _searchFocusNode,
        controller: _searchController,
        onChanged: _filterJourneys,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Başlangıç veya Hedef Ara',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
