import 'package:flutter/material.dart';
import 'my_post_screen.dart';
import '../widgets/menu_widget.dart';

class YourPostsScreen extends StatefulWidget {
  const YourPostsScreen({Key? key}) : super(key: key);

  @override
  _YourPostsScreenState createState() => _YourPostsScreenState();
}

class _YourPostsScreenState extends State<YourPostsScreen> {
  
  final List<Map<String, String>> _yourPosts = [
    {
      'name': 'Hasan Kardak',
      'departure place': 'GTÜ',
      'destination': 'Kadıköy',
      'departure': '12:00'
    },
    {
      'name': 'Hasan Kardak',
      'departure place': 'GTÜ',
      'destination': 'Taksim',
      'departure': '14:30'
    },
  ];

  
  void _deletePost(int index) {
    setState(() {
      _yourPosts.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşım başarıyla silindi!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaşımlarım'),
      ),
      drawer: const Menu(),
      body: _yourPosts.isEmpty
          ? const Center(child: Text('Henüz bir paylaşım oluşturmadınız.'))
          : ListView.builder(
              itemCount: _yourPosts.length,
              itemBuilder: (context, index) {
                final post = _yourPosts[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.directions_car),
                    ),
                    title: Text(post['destination']!),
                    subtitle: Text('Kalkış Saati: ${post['departure']}'),
                    onTap: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyPostScreen(post: post, index: index, updatePost: _updatePost),
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

  
  void _updatePost(int index, Map<String, String> updatedPost) {
    setState(() {
      _yourPosts[index] = updatedPost;
    });
  }
}
