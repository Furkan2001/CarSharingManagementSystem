import 'package:flutter/material.dart';
import '../services/posts_service.dart';

class MyPostScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final int index;
  final Function(int, Map<String, dynamic>) updatePost;

  const MyPostScreen({
    Key? key,
    required this.post,
    required this.index,
    required this.updatePost,
  }) : super(key: key);

  @override
  _MyPostScreenState createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  late TextEditingController _departurePlaceController;
  late TextEditingController _destinationController;
  late TextEditingController _departureTimeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _departurePlaceController =
        TextEditingController(text: widget.post['beginning']);
    _destinationController =
        TextEditingController(text: widget.post['destination']);
    _departureTimeController =
        TextEditingController(text: widget.post['time']);
  }

  @override
  void dispose() {
    _departurePlaceController.dispose();
    _destinationController.dispose();
    _departureTimeController.dispose();
    super.dispose();
  }

  void _saveChanges() async{
    final updatedPost = {
      'id': widget.post['id'],
      'name': widget.post['name'],
      'beginning': _departurePlaceController.text,
      'destination': _destinationController.text,
      'time': _departureTimeController.text,
    };

    try {
      // Call the update API
      bool success = await PostsService.updateJourney(widget.post['id'], updatedPost);

      if (success) {
        widget.updatePost(widget.index, updatedPost);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paylaşım başarıyla güncellendi!')),
        );

        Navigator.pop(context, updatedPost);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güncelleme başarısız oldu.')),
        );
      }
    } catch (e) {
      print('Error updating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaşımı düzenleyin'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _departurePlaceController,
                    decoration: const InputDecoration(
                    labelText: 'Kalkış Yeri',
                    border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Hedef',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _departureTimeController,
                decoration: const InputDecoration(
                  labelText: 'Kalkış Saati',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Değişiklikleri kaydet'),
              ),
            ],
          ),
        ),
    );
  }
}
