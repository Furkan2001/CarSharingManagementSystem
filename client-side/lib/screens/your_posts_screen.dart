import 'package:flutter/material.dart';
import 'my_post_screen.dart';
import '../widgets/menu_widget.dart';
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
      await PostsService.deleteJourney(post['id']);
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

  void _updatePost(int index, Map<String, dynamic> updatedPost) {

    setState(() {
      _yourPosts[index] = updatedPost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaşımlarım'),
      ),
      drawer: const Menu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _yourPosts.isEmpty
              ? const Center(child: Text('Henüz bir paylaşım oluşturmadınız.'))
              : ListView.builder(
                  itemCount: _yourPosts.length,
                  itemBuilder: (context, index) {
                    final post = _yourPosts[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text('${post['beginning']} → ${post['destination']}'),
                        subtitle: Text('Kalkış Saati: ${post['time'] ?? 'N/A'}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyPostScreen(
                                post: {
                                  'id': post['id'] ?? 0,
                                  'name': post['userName'] ?? 'Unknown',
                                  'beginning': post['beginning'] ?? '',
                                  'destination': post['destination'] ?? '',
                                  'time': post['time'] ?? 'N/A',
                                },
                                index: index,
                                updatePost: _updatePost,
                              ),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePost(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
