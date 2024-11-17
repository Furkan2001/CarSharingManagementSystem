import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:intl/date_symbol_data_local.dart'; // Initialize locale data

import '../services/posts_service.dart';
import 'chat_screen.dart';
import '../widgets/custom_appbar.dart';

class PostScreen extends StatefulWidget {
  final int journeyId;

  const PostScreen({Key? key, required this.journeyId}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  Map<String, dynamic>? _journey;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchJourney();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('tr', null); // Initialize Turkish locale
  }

  Future<void> _fetchJourney() async {
    try {
      final journey = await PostsService.getJourneyById(widget.journeyId);
      setState(() {
        _journey = journey;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching journey: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'İlan Detayları'),
      body: Container(
        color: const Color.fromARGB(255, 54, 69, 74),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJourneyCard(),
                        ],
                      ),
                    ),
                    _buildChatButton(), // Chat button at the bottom left
                  ],
                ),
          )
      );
  }

  // Build the main journey details card
  Widget _buildJourneyCard() {
    // Format the time in Turkish locale
    String formattedTime = 'N/A';
    if (_journey?['time'] != null) {
      final DateTime dateTime = DateTime.parse(_journey!['time']);
      final DateFormat formatter = DateFormat('dd MMMM yyyy HH:mm', 'tr');
      formattedTime = formatter.format(dateTime);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 28, color: Color.fromARGB(255, 6, 30, 69)),
                const SizedBox(width: 8),
                Text(
                  _journey?['user']?['username'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              'Başlangıç:',
              '${_journey?['map']?['currentDistrict'] ?? 'Unknown'}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.flag,
              'Hedef:',
              '${_journey?['map']?['destinationDistrict'] ?? 'Unknown'}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Tarih:', formattedTime),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: const Color.fromARGB(255, 6, 30, 69)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(postOwnerName: _journey?['user']?['username'] ?? 'Unknown'),
              ),
            );
          },
          icon: const Icon(Icons.chat, color: Colors.white,),
          label: const Text('Chat', style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 6, 30, 69),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}
