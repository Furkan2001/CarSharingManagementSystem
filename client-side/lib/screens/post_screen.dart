import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import 'chat_screen.dart';

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
    _fetchJourney();
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
      appBar: AppBar(
        title: const Text('Journey Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
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
    );
  }

  // Build the main journey details card
  Widget _buildJourneyCard() {
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
                const Icon(Icons.person, size: 28, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  _journey!['userName'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'From:', _journey!['beginning']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.flag, 'To:', _journey!['destination']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Time:', _journey!['time']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blueAccent),
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
                    ChatScreen(postOwnerName: _journey!['userName']),
              ),
            );
          },
          icon: const Icon(Icons.chat),
          label: const Text('Chat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}
