import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';
import '../screens/post_screen.dart';


class VehiclePostsScreen extends StatefulWidget {
  const VehiclePostsScreen({Key? key}) : super(key: key);

  @override
  _VehiclePostsScreenState createState() => _VehiclePostsScreenState();
}

class _VehiclePostsScreenState extends State<VehiclePostsScreen> {
  List<dynamic> _journeys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJourneys();
  }

  Future<void> _fetchJourneys() async {
    try {
      final journeys = await PostsService.getAllJourneys();
      setState(() {
        _journeys = journeys;
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
        title: const Text('Vehicle Sharing Posts'),
      ),
      drawer: const Menu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _journeys.length,
              itemBuilder: (context, index) {
                final journey = _journeys[index];

                // Handle possible null values
                final beginning = journey['beginning'] ?? 'Unknown';
                final destination = journey['destination'] ?? 'Unknown';
                final time = journey['time'] ?? 'N/A';
                final id = journey['Id'] ?? -1;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text('$beginning → $destination'),
                    subtitle: Text('Time: $time'),
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
