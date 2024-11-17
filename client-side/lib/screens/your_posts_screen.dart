import 'package:flutter/material.dart';
import 'edit_post_screen.dart';
import '../widgets/menu_widget.dart';
import '../widgets/custom_appbar.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:intl/intl.dart';
import '../services/posts_service.dart';

class YourPostsScreen extends StatefulWidget {
  const YourPostsScreen({Key? key}) : super(key: key);

  @override
  _YourPostsScreenState createState() => _YourPostsScreenState();
}

class _YourPostsScreenState extends State<YourPostsScreen> {
  List<dynamic> _yourPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsersJourneys();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null); // Initialize Turkish locale
  }

  Future<void> _fetchUsersJourneys() async {
    try {
      final journeys = await PostsService.getUsersJourneys();
      setState(() {
        _yourPosts = journeys;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching journeys: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deletePost(int index) async {
    final post = _yourPosts[index];

    try {
      await PostsService.deleteJourney(post['journeyId']);
      setState(() {
        _yourPosts.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşım başarıyla silindi!')),
      );
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silme işlemi başarısız oldu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Paylaşımlarım'),
      drawer: const Menu(),
      body: Container(
      color: const Color.fromARGB(255,54, 69, 74),
          child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _yourPosts.isEmpty
              ? const Center(child: Text('Henüz bir paylaşım oluşturmadınız.'))
              : ListView.builder(
                  itemCount: _yourPosts.length,
                  itemBuilder: (context, index) {

                    final post = _yourPosts[index];

                    final currentDistrict = post['map']?['currentDistrict'] ?? 'Unknown';
                    final destinationDistrict = post['map']?['destinationDistrict'] ?? 'Unknown';

                    final timeString = post['time'] ?? 'N/A';

                    String formattedTime;
                    if (timeString != 'N/A') {
                      final DateTime dateTime = DateTime.parse(timeString);
                      final DateFormat formatter = DateFormat('dd MMMM yyyy HH:mm', 'tr');
                      formattedTime = formatter.format(dateTime);
                    } else {
                      formattedTime = 'N/A';
                    }

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
                                        builder: (context) => EditPostScreen(journeyId: post['journeyId'],),
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
                                    'Düzenle',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _deletePost(index);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  child: const Text(
                                    'Sil',
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
    );
  }
}


