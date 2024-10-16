import 'package:flutter/material.dart';
import '../services/posts_service.dart';
import '../widgets/menu_widget.dart';
import 'post_screen.dart';

class VehiclePostsScreen extends StatelessWidget {
  const VehiclePostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> posts = PostsService.getPosts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Paylaşımları'),
      ),
      drawer: const Menu(),
      body: _buildPostsList(context, posts),
    );
  }

  
  Widget _buildPostsList(BuildContext context, List<Map<String, String>> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.directions_car),
            ),
            title: Text(post['destination']!),
            subtitle: Text('Kalkış: ${post['departure']}'),
            onTap: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostScreen(post: post),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
